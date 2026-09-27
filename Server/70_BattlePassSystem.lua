--[[
    ========================================================================
    WoW Perú - Pase de Batalla (70_BattlePassSystem.lua)
    Reino: Reino Andino | Servidor: https://wow-peru.lat/
    Motor: AzerothCore / TrinityCore con Eluna Lua Engine
    ========================================================================
    Backend de Servidor: Gestión de niveles (1-50), persistencia en MySQL,
    cálculo de XP por eventos del juego, entrega idempotente de recompensas,
    prevención de desbordamiento de bolsas (envío por correo) y API para tienda.
]]

local SEASON_ID = 1
local XP_PER_LEVEL = 1000
local MAX_LEVEL = 50
local ADDON_PREFIX = "WP_BP"

local HEX_CHARS = "0123456789ABCDEF"
local HEX_MAP = {}
for i = 1, #HEX_CHARS do
    HEX_MAP[HEX_CHARS:sub(i, i)] = i - 1
end

-- Caché en memoria de jugadores conectados: [guidLow] = { ... }
local BP_CACHE = {}

-- ========================================================================
-- TABLA DE RECOMPENSAS DEL SERVIDOR (Consistente con Config.lua)
-- ========================================================================
local REWARDS = {
    [1]  = { free = { type = "item", id = 2070, count = 5 },   prem = { type = "item", id = 13335, count = 1 } },
    [2]  = { free = { type = "item", id = 118, count = 10 },   prem = { type = "item", id = 38082, count = 1 } },
    [3]  = { free = { type = "item", id = 148, count = 1 },    prem = { type = "item", id = 38186, count = 2 } },
    [4]  = { free = { type = "money", copper = 100000 },       prem = { type = "item", id = 43499, count = 1 } },
    [5]  = { free = { type = "item", id = 49426, count = 5 },  prem = { type = "item", id = 49426, count = 15 } },
    [6]  = { free = { type = "item", id = 33448, count = 20 }, prem = { type = "item", id = 44430, count = 1 } },
    [7]  = { free = { type = "item", id = 33470, count = 10 }, prem = { type = "item", id = 37012, count = 1 } },
    [8]  = { free = { type = "item", id = 43345, count = 5 },  prem = { type = "item", id = 43571, count = 1 } },
    [9]  = { free = { type = "money", copper = 250000 },       prem = { type = "item", id = 34057, count = 10 } },
    [10] = { free = { type = "item", id = 43300, count = 1 },  prem = { type = "item", id = 44558, count = 1 } },
    [15] = { free = { type = "item", id = 49426, count = 10 }, prem = { type = "item", id = 49284, count = 1 } },
    [20] = { free = { type = "item", id = 44149, count = 1 },  prem = { type = "item", id = 49283, count = 1 } },
    [25] = { free = { type = "money", copper = 500000 },       prem = { type = "item", id = 49290, count = 1 } },
    [30] = { free = { type = "item", id = 49426, count = 15 }, prem = { type = "item", id = 49343, count = 1 } },
    [35] = { free = { type = "item", id = 47241, count = 5 },  prem = { type = "item", id = 49286, count = 1 } },
    [40] = { free = { type = "item", id = 34052, count = 1 },  prem = { type = "item", id = 54068, count = 1 } },
    [45] = { free = { type = "item", id = 49426, count = 20 }, prem = { type = "item", id = 49285, count = 1 } },
    [50] = { free = { type = "item", id = 49426, count = 30 }, prem = { type = "item", id = 50818, count = 1 } },
}

-- Rellenar niveles intermedios con emblemas / oro si no están explícitos
for lvl = 1, MAX_LEVEL do
    if not REWARDS[lvl] then
        REWARDS[lvl] = {
            free = { type = "item", id = 49426, count = 2 },
            prem = { type = "item", id = 49426, count = 6 }
        }
    end
end

-- ========================================================================
-- FUNCIONES DE BITMASK HEXADECIMAL (100% IDÉNTICAS AL CLIENTE)
-- ========================================================================
local function IsLevelClaimedInHex(hexStr, level)
    if not hexStr or type(hexStr) ~= "string" or level < 1 or level > MAX_LEVEL then
        return false
    end
    local charIdx = math.floor((level - 1) / 4) + 1
    if charIdx > #hexStr then return false end

    local char = hexStr:sub(charIdx, charIdx):upper()
    local val = HEX_MAP[char] or 0
    local bitInNibble = (level - 1) % 4
    local bitVal = 2 ^ bitInNibble

    return (math.floor(val / bitVal) % 2) == 1
end

local function SetLevelClaimedInHex(hexStr, level)
    if not hexStr or type(hexStr) ~= "string" then
        hexStr = "0000000000000"
    end
    while #hexStr < 13 do
        hexStr = hexStr .. "0"
    end

    if level < 1 or level > MAX_LEVEL then
        return hexStr
    end

    local charIdx = math.floor((level - 1) / 4) + 1
    local char = hexStr:sub(charIdx, charIdx):upper()
    local val = HEX_MAP[char] or 0
    local bitInNibble = (level - 1) % 4
    local bitVal = 2 ^ bitInNibble

    if (math.floor(val / bitVal) % 2) == 0 then
        val = val + bitVal
    end

    local newChar = HEX_CHARS:sub(val + 1, val + 1)
    local result = ""
    if charIdx > 1 then
        result = result .. hexStr:sub(1, charIdx - 1)
    end
    result = result .. newChar
    if charIdx < #hexStr then
        result = result .. hexStr:sub(charIdx + 1)
    end

    return result
end

-- ========================================================================
-- COMUNICACIÓN DE RED (SENDADDONMESSAGE)
-- ========================================================================
local function SendClientPacket(player, payload)
    if not player or not payload then return end
    -- Tipo 0 = Normal / Whisper al jugador
    player:SendAddonMessage(ADDON_PREFIX, payload, 0, player)
end

local function SendSync(player)
    local guid = player:GetGUIDLow()
    local data = BP_CACHE[guid]
    if not data then return end

    local vipFlag = data.is_premium and "1" or "0"
    local payload = string.format("BP_RES_SYNC:%d:%d:%d:%s:%s:%s",
        SEASON_ID, data.level, data.xp, vipFlag, data.claimed_free, data.claimed_premium)
    SendClientPacket(player, payload)
end

-- ========================================================================
-- PERSISTENCIA EN BASE DE DATOS (MYSQL)
-- ========================================================================
local function LoadPlayerData(player)
    local guid = player:GetGUIDLow()
    local q = CharDBQuery(string.format(
        "SELECT level, xp, is_premium, claimed_free, claimed_premium FROM character_battlepass WHERE guid = %d AND season_id = %d",
        guid, SEASON_ID))

    if q then
        BP_CACHE[guid] = {
            level = q:GetUInt32(0),
            xp = q:GetUInt32(1),
            is_premium = (q:GetUInt8(2) == 1),
            claimed_free = q:GetString(3),
            claimed_premium = q:GetString(4),
        }
    else
        -- Crear registro inicial
        BP_CACHE[guid] = {
            level = 1,
            xp = 0,
            is_premium = false,
            claimed_free = "0000000000000",
            claimed_premium = "0000000000000",
        }
        CharDBExecute(string.format(
            "INSERT INTO character_battlepass (guid, season_id, level, xp, is_premium, claimed_free, claimed_premium) VALUES (%d, %d, 1, 0, 0, '0000000000000', '0000000000000')",
            guid, SEASON_ID))
    end
end

local function SavePlayerData(guid)
    local data = BP_CACHE[guid]
    if not data then return end

    local vipFlag = data.is_premium and 1 or 0
    CharDBExecute(string.format(
        "UPDATE character_battlepass SET level = %d, xp = %d, is_premium = %d, claimed_free = '%s', claimed_premium = '%s' WHERE guid = %d AND season_id = %d",
        data.level, data.xp, vipFlag, data.claimed_free, data.claimed_premium, guid, SEASON_ID))
end

-- ========================================================================
-- ENTREGA SEGURA E IDEMPOTENTE DE RECOMPENSAS
-- ========================================================================
local function DeliverReward(player, rewardDef, level)
    if not rewardDef then return true end

    if rewardDef.type == "item" then
        local itemId = rewardDef.id
        local count = rewardDef.count or 1

        -- Intentar añadir a las bolsas
        local addedItem = player:AddItem(itemId, count)
        if not addedItem then
            -- BOLSAS LLENAS: Respaldo por correo dentro del juego
            local subject = string.format("Pase de Batalla - Recompensa Nivel %d", level)
            local body = string.format("¡Felicidades por alcanzar el Nivel %d!\n\nTus bolsas estaban llenas al momento de reclamar, por lo que te enviamos tu recompensa adjunta a este correo.\n\nAtte: Staff de WoW Perú.", level)
            SendMail(subject, body, player:GetGUIDLow(), 0, 61, 0, 0, 0, itemId, count)
            return "MAIL"
        end
        return "BAG"

    elseif rewardDef.type == "money" then
        player:ModifyMoney(rewardDef.copper or 0)
        return "MONEY"

    elseif rewardDef.type == "title" then
        player:SetKnownTitle(rewardDef.titleId)
        return "TITLE"
    end

    return "OK"
end

-- ========================================================================
-- GESTIÓN DE EXPERIENCIA Y PROGRESIÓN DE NIVELES
-- ========================================================================
local function AddBattlePassXP(player, amount, reason)
    if not player or amount <= 0 then return end
    local guid = player:GetGUIDLow()
    local data = BP_CACHE[guid]
    if not data or data.level >= MAX_LEVEL then return end

    data.xp = data.xp + amount
    local leveledUp = false

    while data.xp >= XP_PER_LEVEL and data.level < MAX_LEVEL do
        data.xp = data.xp - XP_PER_LEVEL
        data.level = data.level + 1
        leveledUp = true
    end

    if data.level >= MAX_LEVEL then
        data.xp = 0
    end

    SavePlayerData(guid)

    local payload = string.format("BP_RES_XP:%d:%d:%d:%s", data.level, data.xp, amount, reason or "Actividad")
    SendClientPacket(player, payload)

    if leveledUp then
        player:SendBroadcastMessage(string.format("|cFFD4AF37[Pase de Batalla]|r ¡Has subido al |cFF00FF00Nivel %d|r! Abre /bp para ver tus recompensas.", data.level))
    end
end

-- ========================================================================
-- PROCESAMIENTO DE PETICIONES DE CLIENTE (WP_BP)
-- ========================================================================
local function ProcessAddonMessage(player, message)
    if not player or not message then return end
    local guid = player:GetGUIDLow()
    local data = BP_CACHE[guid]
    if not data then return end

    local parts = {}
    for p in string.gmatch(message, "[^:]+") do
        table.insert(parts, p)
    end

    local opCode = parts[1]

    -- Petición de Sincronización
    if opCode == "BP_REQ_SYNC" then
        SendSync(player)

    -- Petición de Reclamo
    elseif opCode == "BP_CLAIM" then
        local level = tonumber(parts[2]) or 0
        local track = (parts[3] or ""):lower()

        if level < 1 or level > MAX_LEVEL or (track ~= "free" and track ~= "premium") then
            SendClientPacket(player, string.format("BP_RES_CLAIM:%d:%s:0:INVALID_PARAM", level, track))
            return
        end

        if level > data.level then
            SendClientPacket(player, string.format("BP_RES_CLAIM:%d:%s:0:LEVEL_NOT_REACHED", level, track))
            return
        end

        if track == "premium" and not data.is_premium then
            SendClientPacket(player, string.format("BP_RES_CLAIM:%d:%s:0:VIP_REQUIRED", level, track))
            return
        end

        local hexStr = (track == "free") and data.claimed_free or data.claimed_premium
        if IsLevelClaimedInHex(hexStr, level) then
            SendClientPacket(player, string.format("BP_RES_CLAIM:%d:%s:0:ALREADY_CLAIMED", level, track))
            return
        end

        -- Actualizar bitmask y base de datos
        if track == "free" then
            data.claimed_free = SetLevelClaimedInHex(data.claimed_free, level)
        else
            data.claimed_premium = SetLevelClaimedInHex(data.claimed_premium, level)
        end
        SavePlayerData(guid)

        -- Despachar ítem de forma segura
        local rInfo = REWARDS[level]
        local rewardDef = (track == "free") and rInfo.free or rInfo.prem
        local status = DeliverReward(player, rewardDef, level)

        SendClientPacket(player, string.format("BP_RES_CLAIM:%d:%s:1:%s", level, track, status))
    end
end

-- ========================================================================
-- HOOKS DE EVENTOS DEL JUEGO (ELUNA)
-- ========================================================================
-- 1. Al Iniciar Sesión (Login)
local function OnPlayerLogin(event, player)
    LoadPlayerData(player)
    SendSync(player)
end
RegisterPlayerEvent(3, OnPlayerLogin)

-- 2. Al Cerrar Sesión (Logout)
local function OnPlayerLogout(event, player)
    local guid = player:GetGUIDLow()
    SavePlayerData(guid)
    BP_CACHE[guid] = nil
end
RegisterPlayerEvent(4, OnPlayerLogout)

-- 3. Al Derrotar Criaturas (Bosses y Élite)
local function OnCreatureKill(event, player, creature)
    if not player or not creature then return end
    -- Jefes de mazmorra o banda
    if creature:IsDungeonBoss() then
        AddBattlePassXP(player, 100, "Jefe de Mazmorra")
    elseif creature:GetLevel() >= 80 and creature:IsElite() then
        AddBattlePassXP(player, 25, "Criatura Élite")
    else
        -- Chance de XP por monstruo normal
        if math.random(1, 10) == 1 then
            AddBattlePassXP(player, 5, "Enemigo Derrotado")
        end
    end
end
RegisterPlayerEvent(7, OnCreatureKill)

-- 4. Al Completar Misiones del Mundo
local function OnQuestComplete(event, player, quest)
    if player then
        AddBattlePassXP(player, 35, "Misión Completada")
    end
end
RegisterPlayerEvent(28, OnQuestComplete)

-- 5. Captura de Mensajes del Addon (RegisterServerEvent 30)
local function OnServerAddonMessage(event, player, type, prefix, target, message)
    if prefix == ADDON_PREFIX then
        ProcessAddonMessage(player, message)
    end
end
RegisterServerEvent(30, OnServerAddonMessage)

-- ========================================================================
-- COMANDOS PARA EL STAFF Y TIENDA WEB (.bp)
-- ========================================================================
local function OnStaffCommand(event, player, command)
    local args = {}
    for w in command:gmatch("%S+") do table.insert(args, w) end

    if args[1] == "bp" then
        local sub = args[2]

        -- .bp sync
        if sub == "sync" then
            SendSync(player)
            return false

        -- .bp vip <jugador> <1|0>
        elseif sub == "vip" then
            if player:GetGMRank() < 2 then return false end
            local targetName = args[3]
            local flag = tonumber(args[4]) or 1

            local target = GetPlayerByName(targetName)
            if target then
                local tGuid = target:GetGUIDLow()
                if BP_CACHE[tGuid] then
                    BP_CACHE[tGuid].is_premium = (flag == 1)
                    SavePlayerData(tGuid)
                    SendSync(target)
                    target:SendBroadcastMessage(flag == 1 and "|cFFD4AF37[WoW Perú]|r ¡Pase VIP activado!" or "|cFFFF4444[WoW Perú]|r Pase VIP revocado.")
                end
                player:SendBroadcastMessage("Estado VIP actualizado para " .. targetName)
            else
                CharDBExecute(string.format("UPDATE character_battlepass SET is_premium = %d WHERE guid = (SELECT guid FROM characters WHERE name = '%s')", flag, targetName))
                player:SendBroadcastMessage("Estado VIP actualizado en base de datos para " .. targetName)
            end
            return false

        -- .bp addxp <jugador> <cantidad>
        elseif sub == "addxp" then
            if player:GetGMRank() < 2 then return false end
            local targetName = args[3]
            local amount = tonumber(args[4]) or 100
            local target = GetPlayerByName(targetName)
            if target then
                AddBattlePassXP(target, amount, "Comando Staff")
                player:SendBroadcastMessage(string.format("Se otorgaron %d XP a %s", amount, targetName))
            else
                player:SendBroadcastMessage("Jugador no encontrado.")
            end
            return false
        end
    end
    return true
end
RegisterPlayerEvent(42, OnStaffCommand)
