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
    [1] = { free = { type = "item", id = 33448, count = 10 }, prem = { type = "item", id = 35280, count = 1 } },
    [2] = { free = { type = "money", copper = 500000, count = 50 }, prem = { type = "item", id = 41599, count = 1 } },
    [3] = { free = { type = "item", id = 21713, count = 5 }, prem = { type = "item", id = 49426, count = 5 } },
    [4] = { free = { type = "item", id = 3914, count = 1 }, prem = { type = "item", id = 4401, count = 1 } },
    [5] = { free = { type = "money", copper = 1000000, count = 100 }, prem = { type = "item", id = 22999, count = 1 } },
    [6] = { free = { type = "item", id = 43015, count = 20 }, prem = { type = "money", copper = 1000000, count = 100 } },
    [7] = { free = { type = "item", id = 37711, count = 1 }, prem = { type = "item", id = 40119, count = 1 } },
    [8] = { free = { type = "item", id = 33470, count = 10 }, prem = { type = "item", id = 44822, count = 1 } },
    [9] = { free = { type = "money", copper = 750000, count = 75 }, prem = { type = "item", id = 46377, count = 5 } },
    [10] = { free = { type = "item", id = 39896, count = 1 }, prem = { type = "item", id = 43908, count = 1 } },
    [11] = { free = { type = "item", id = 33448, count = 15 }, prem = { type = "money", copper = 1000000, count = 100 } },
    [12] = { free = { type = "item", id = 41599, count = 1 }, prem = { type = "item", id = 40111, count = 1 } },
    [13] = { free = { type = "money", copper = 1000000, count = 100 }, prem = { type = "item", id = 47241, count = 10 } },
    [14] = { free = { type = "item", id = 40093, count = 10 }, prem = { type = "item", id = 46376, count = 5 } },
    [15] = { free = { type = "item", id = 49426, count = 5 }, prem = { type = "item", id = 38082, count = 1 } },
    [16] = { free = { type = "item", id = 33447, count = 20 }, prem = { type = "money", copper = 1500000, count = 150 } },
    [17] = { free = { type = "item", id = 40125, count = 1 }, prem = { type = "item", id = 40123, count = 1 } },
    [18] = { free = { type = "money", copper = 1500000, count = 150 }, prem = { type = "item", id = 41600, count = 1 } },
    [19] = { free = { type = "item", id = 33470, count = 10 }, prem = { type = "item", id = 49426, count = 10 } },
    [20] = { free = { type = "money", copper = 2000000, count = 200 }, prem = { type = "item", id = 49284, count = 1 } },
    [21] = { free = { type = "item", id = 43015, count = 20 }, prem = { type = "item", id = 49426, count = 10 } },
    [22] = { free = { type = "item", id = 40121, count = 1 }, prem = { type = "item", id = 40111, count = 1 } },
    [23] = { free = { type = "money", copper = 1500000, count = 150 }, prem = { type = "money", copper = 2000000, count = 200 } },
    [24] = { free = { type = "item", id = 33448, count = 15 }, prem = { type = "item", id = 41600, count = 1 } },
    [25] = { free = { type = "money", copper = 2500000, count = 250 }, prem = { type = "item", id = 49286, count = 1 } },
    [26] = { free = { type = "item", id = 46377, count = 5 }, prem = { type = "item", id = 47241, count = 10 } },
    [27] = { free = { type = "item", id = 40127, count = 1 }, prem = { type = "item", id = 40111, count = 1 } },
    [28] = { free = { type = "money", copper = 2000000, count = 200 }, prem = { type = "money", copper = 2500000, count = 250 } },
    [29] = { free = { type = "item", id = 33447, count = 20 }, prem = { type = "item", id = 46376, count = 10 } },
    [30] = { free = { type = "item", id = 49426, count = 10 }, prem = { type = "item", id = 44794, count = 1 } },
    [31] = { free = { type = "money", copper = 2000000, count = 200 }, prem = { type = "money", copper = 2500000, count = 250 } },
    [32] = { free = { type = "item", id = 40123, count = 1 }, prem = { type = "item", id = 40119, count = 1 } },
    [33] = { free = { type = "item", id = 33470, count = 15 }, prem = { type = "item", id = 47241, count = 15 } },
    [34] = { free = { type = "item", id = 41600, count = 1 }, prem = { type = "item", id = 51809, count = 1 } },
    [35] = { free = { type = "item", id = 49426, count = 10 }, prem = { type = "item", id = 44083, count = 1 } },
    [36] = { free = { type = "money", copper = 2500000, count = 250 }, prem = { type = "money", copper = 3000000, count = 300 } },
    [37] = { free = { type = "item", id = 40111, count = 1 }, prem = { type = "item", id = 40111, count = 2 } },
    [38] = { free = { type = "item", id = 33448, count = 20 }, prem = { type = "item", id = 46377, count = 10 } },
    [39] = { free = { type = "item", id = 40093, count = 10 }, prem = { type = "item", id = 49426, count = 15 } },
    [40] = { free = { type = "money", copper = 3000000, count = 300 }, prem = { type = "item", id = 44413, count = 1 } },
    [41] = { free = { type = "item", id = 43015, count = 20 }, prem = { type = "money", copper = 3500000, count = 350 } },
    [42] = { free = { type = "item", id = 40125, count = 1 }, prem = { type = "item", id = 40123, count = 1 } },
    [43] = { free = { type = "money", copper = 3000000, count = 300 }, prem = { type = "item", id = 49426, count = 15 } },
    [44] = { free = { type = "item", id = 41600, count = 1 }, prem = { type = "item", id = 51809, count = 1 } },
    [45] = { free = { type = "item", id = 49426, count = 15 }, prem = { type = "item", id = 40111, count = 2 } },
    [46] = { free = { type = "money", copper = 3500000, count = 350 }, prem = { type = "money", copper = 4000000, count = 400 } },
    [47] = { free = { type = "item", id = 40111, count = 1 }, prem = { type = "item", id = 40119, count = 1 } },
    [48] = { free = { type = "money", copper = 4000000, count = 400 }, prem = { type = "item", id = 49426, count = 20 } },
    [49] = { free = { type = "item", id = 33448, count = 20 }, prem = { type = "money", copper = 5000000, count = 500 } },
    [50] = { free = { type = "item", id = 49426, count = 25 }, prem = { type = "item", id = 32458, count = 1 } },
}

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

local GetOrRefreshQuestState -- Declaración previa para SendQuestSync
local GetOrLoadPlayerData   -- Declaración previa para SendSync y SendQuestSync

local ACTIVE_QUEST_IDS = { 1, 2, 3, 4, 5, 101, 102, 103 }

local function SendQuestSync(player)
    local guid = player:GetGUIDLow()
    local data = GetOrLoadPlayerData(player)
    if not data then return end
    data.quests = data.quests or {}

    for _, qId in ipairs(ACTIVE_QUEST_IDS) do
        local qData, wasReset = GetOrRefreshQuestState(data, qId)
        if wasReset then
            CharDBExecute(string.format(
                "UPDATE character_battlepass_quests SET progress = 0, completed = 0, reset_time = %d WHERE guid = %d AND quest_id = %d",
                qData.resetTime, guid, qId))
        end
        local compFlag = qData.completed and "1" or "0"
        local payload = string.format("BP_RES_QUEST:%d:%d:%s", qId, qData.progress, compFlag)
        SendClientPacket(player, payload)
    end
end

local function SendSync(player)
    local guid = player:GetGUIDLow()
    local data = GetOrLoadPlayerData(player)
    if not data then return end

    local vipFlag = data.is_premium and "1" or "0"
    local cFree = (data.claimed_free and data.claimed_free ~= "") and data.claimed_free or "0000000000000"
    local cPrem = (data.claimed_premium and data.claimed_premium ~= "") and data.claimed_premium or "0000000000000"
    local payload = string.format("BP_RES_SYNC:%d:%d:%d:%s:%s:%s",
        SEASON_ID, data.level, data.xp, vipFlag, cFree, cPrem)
    SendClientPacket(player, payload)
    SendQuestSync(player)
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
        local cFree = q:GetString(3)
        if not cFree or cFree == "" then cFree = "0000000000000" end
        while #cFree < 13 do cFree = cFree .. "0" end

        local cPrem = q:GetString(4)
        if not cPrem or cPrem == "" then cPrem = "0000000000000" end
        while #cPrem < 13 do cPrem = cPrem .. "0" end

        BP_CACHE[guid] = {
            level = q:GetUInt32(0),
            xp = q:GetUInt32(1),
            is_premium = (q:GetUInt8(2) == 1),
            claimed_free = cFree,
            claimed_premium = cPrem,
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

-- ========================================================================
-- CÁLCULO DE RESÉTEOS DIARIOS (04:00 AM) Y SEMANALES (MIÉRCOLES 04:00 AM)
-- ========================================================================
local function GetNextDailyResetTime()
    local t = os.date("*t")
    local resetToday = os.time({ year = t.year, month = t.month, day = t.day, hour = 4, min = 0, sec = 0 })
    if os.time() >= resetToday then
        return resetToday + 86400 -- Mañana a las 04:00 AM
    else
        return resetToday -- Hoy a las 04:00 AM
    end
end

local function GetNextWeeklyResetTime()
    local t = os.date("*t")
    -- t.wday: 1 = Domingo, 4 = Miércoles
    local daysUntilWed = (4 - t.wday) % 7
    if daysUntilWed == 0 and t.hour >= 4 then
        daysUntilWed = 7
    end
    local targetTimestamp = os.time({ year = t.year, month = t.month, day = t.day + daysUntilWed, hour = 4, min = 0, sec = 0 })
    return targetTimestamp
end

local function IsWeeklyQuest(questId)
    return questId >= 100
end

GetOrRefreshQuestState = function(data, questId)
    data.quests = data.quests or {}
    local qState = data.quests[questId]
    local now = os.time()

    if not qState then
        local rTime = IsWeeklyQuest(questId) and GetNextWeeklyResetTime() or GetNextDailyResetTime()
        qState = { progress = 0, completed = false, resetTime = rTime }
        data.quests[questId] = qState
        return qState, false
    end

    if not qState.resetTime or qState.resetTime == 0 or now >= qState.resetTime then
        qState.progress = 0
        qState.completed = false
        qState.resetTime = IsWeeklyQuest(questId) and GetNextWeeklyResetTime() or GetNextDailyResetTime()
        return qState, true
    end

    return qState, false
end

-- ========================================================================
-- CARGA CON RESETEO AUTOMÁTICO DE MISIONES AL INICIAR SESIÓN
-- ========================================================================
local function LoadPlayerQuests(player)
    local guid = player:GetGUIDLow()
    if not BP_CACHE[guid] then return end
    BP_CACHE[guid].quests = {}

    local now = os.time()
    local nextDaily = GetNextDailyResetTime()
    local nextWeekly = GetNextWeeklyResetTime()

    local qQuests = CharDBQuery(string.format(
        "SELECT quest_id, progress, completed, reset_time FROM character_battlepass_quests WHERE guid = %d", guid))
    if qQuests then
        repeat
            local qId = qQuests:GetUInt32(0)
            local prog = qQuests:GetUInt32(1)
            local comp = (qQuests:GetUInt8(2) == 1)
            local rTime = qQuests:GetUInt32(3)

            -- Si el tiempo de reseteo ya venció (o estaba en 0), reinicia la misión
            if rTime == 0 or now >= rTime then
                prog = 0
                comp = false
                rTime = IsWeeklyQuest(qId) and nextWeekly or nextDaily
                CharDBExecute(string.format(
                    "UPDATE character_battlepass_quests SET progress = 0, completed = 0, reset_time = %d WHERE guid = %d AND quest_id = %d",
                    rTime, guid, qId))
            end

            BP_CACHE[guid].quests[qId] = { progress = prog, completed = comp, resetTime = rTime }
        until not qQuests:NextRow()
    end
end

GetOrLoadPlayerData = function(player)
    if not player then return nil end
    local guid = player:GetGUIDLow()
    if not BP_CACHE[guid] then
        LoadPlayerData(player)
        LoadPlayerQuests(player)
    end
    return BP_CACHE[guid]
end

local function SavePlayerData(guid)
    local data = BP_CACHE[guid]
    if not data then return end

    local vipFlag = data.is_premium and 1 or 0
    local cFree = (data.claimed_free and data.claimed_free ~= "") and data.claimed_free or "0000000000000"
    local cPrem = (data.claimed_premium and data.claimed_premium ~= "") and data.claimed_premium or "0000000000000"
    CharDBExecute(string.format(
        "UPDATE character_battlepass SET level = %d, xp = %d, is_premium = %d, claimed_free = '%s', claimed_premium = '%s' WHERE guid = %d AND season_id = %d",
        data.level, data.xp, vipFlag, cFree, cPrem, guid, SEASON_ID))
end

-- ========================================================================
-- COMPATIBILIDAD FACCIONARIA RESILIENTE (TRINITYCORE / AZEROTHCORE / ELUNA)
-- ========================================================================
-- En TrinityCore C++, player->GetTeam() retorna Team (469: Alianza, 67: Horda).
-- En AzerothCore / ALE, player->GetTeam() retorna TeamId (0: Alianza, 1: Horda).
-- En Eluna API, player:IsAlliance() y player:IsHorde() son métodos canónicos universales.
local function IsPlayerHorde(player)
    if not player then return false end
    if player.IsHorde then
        return player:IsHorde()
    end
    local t = player:GetTeam()
    return t == 1 or t == 67
end

local function IsPlayerAlliance(player)
    if not player then return false end
    if player.IsAlliance then
        return player:IsAlliance()
    end
    local t = player:GetTeam()
    return t == 0 or t == 469
end

local function DidPlayerWinBG(player, winnerTeamId)
    if not player or winnerTeamId == nil then return false end
    -- winnerTeamId en BG_EVENT_ON_END: 0 = Alianza, 1 = Horda
    if winnerTeamId == 0 then
        return IsPlayerAlliance(player)
    elseif winnerTeamId == 1 then
        return IsPlayerHorde(player)
    end
    return false
end

-- ========================================================================
-- ENTREGA SEGURA E IDEMPOTENTE DE RECOMPENSAS
-- ========================================================================
local function DeliverReward(player, rewardDef, level)
    if not rewardDef then return "OK" end

    if rewardDef.type == "item" then
        local itemId = rewardDef.id or rewardDef.itemId
        local count = rewardDef.count or 1

        -- Adaptación faccionaria automática para monturas con restricción de raza
        -- 44413 = Mekgineer's Chopper (Alianza) | 41508 = Mechano-hog (Horda)
        if itemId == 44413 and IsPlayerHorde(player) then
            itemId = 41508
        end

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
    local data = GetOrLoadPlayerData(player)
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
-- GESTIÓN Y PROGRESIÓN DE MISIONES DEL PASE (ELUNA + MYSQL)
-- ========================================================================
local function AdvanceQuestProgress(player, questId, amount, target, xpReward)
    if not player or amount <= 0 then return end
    local guid = player:GetGUIDLow()
    local data = GetOrLoadPlayerData(player)
    if not data then return end

    local qState, wasReset = GetOrRefreshQuestState(data, questId)
    if qState.completed then return end

    qState.progress = math.min(target, qState.progress + amount)
    local newlyCompleted = false

    if qState.progress >= target then
        qState.completed = true
        newlyCompleted = true
    end

    data.quests[questId] = qState

    -- Persistencia inmediata en BD con timestamp de reseteo
    local compFlag = qState.completed and 1 or 0
    CharDBExecute(string.format(
        "REPLACE INTO character_battlepass_quests (guid, quest_id, progress, completed, reset_time) VALUES (%d, %d, %d, %d, %d)",
        guid, questId, qState.progress, compFlag, qState.resetTime))

    -- Notificar al cliente
    local payload = string.format("BP_RES_QUEST:%d:%d:%d", questId, qState.progress, compFlag)
    SendClientPacket(player, payload)

    if newlyCompleted then
        AddBattlePassXP(player, xpReward, "Misión Completada")
        player:SendBroadcastMessage(string.format(
            "|cFFD4AF37[Pase de Batalla]|r ¡Misión de Pase completada! (+%d XP)", xpReward))
    end
end

-- ========================================================================
-- PROCESAMIENTO DE PETICIONES DE CLIENTE (WP_BP)
-- ========================================================================
local function ProcessAddonMessage(player, message)
    if not player or not message then return end
    local guid = player:GetGUIDLow()
    local data = GetOrLoadPlayerData(player)
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
        local rewardDef = (track == "free") and (rInfo and rInfo.free) or (rInfo and (rInfo.prem or rInfo.premium))
        local status = DeliverReward(player, rewardDef, level)

        SendClientPacket(player, string.format("BP_RES_CLAIM:%d:%s:1:%s", level, track, tostring(status or "OK")))
    end
end

-- ========================================================================
-- HOOKS DE EVENTOS DEL JUEGO (ELUNA)
-- ========================================================================
-- 1. Al Iniciar Sesión (Login)
local function OnPlayerLogin(event, player)
    LoadPlayerData(player)
    LoadPlayerQuests(player)
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

-- 2b. Al Eliminar Personaje (Eluna Event ID 2: PLAYER_EVENT_ON_CHARACTER_DELETE)
local function OnCharacterDelete(event, guid)
    if not guid or guid <= 0 then return end
    BP_CACHE[guid] = nil
    CharDBExecute(string.format("DELETE FROM character_battlepass WHERE guid = %d", guid))
    CharDBExecute(string.format("DELETE FROM character_battlepass_quests WHERE guid = %d", guid))
end
RegisterPlayerEvent(2, OnCharacterDelete)

-- 3. Al Derrotar Criaturas (Bosses y Élite con Soporte Grupal)
local function OnCreatureKill(event, player, creature)
    if not player or not creature then return end

    local isBoss = creature:IsDungeonBoss() or creature:IsWorldBoss()
    local isElite80 = (creature:GetLevel() >= 80 and creature:IsElite())
    local map = creature:GetMap()
    local isRaid = map and map:IsRaid()

    -- Determinar beneficiarios: Si está en grupo/banda, premiar a todos los miembros presentes en el combate
    local targets = {}
    local group = player:GetGroup()

    if group then
        local isRaidGroup = group.IsRaidGroup and group:IsRaidGroup()
        -- En bandas, solo bosses y élites comparten crédito (evita abusos de 40 jugadores)
        -- En grupos regulares (<= 5 jugadores), se comparte crédito con sanadores/tanques a rango de 60 yd
        if (isBoss or isElite80) or not isRaidGroup then
            local maxDist = (isBoss or isElite80) and 120 or 60
            local members = group:GetMembers()
            if members then
                for _, member in ipairs(members) do
                    if member and member:IsInWorld() and member:GetMapId() == creature:GetMapId() and (member == player or member:IsAlive()) and member:GetDistance(creature) <= maxDist then
                        table.insert(targets, member)
                    end
                end
            end
        end
    end

    -- Fallback si juega en solitario o no había miembros cercanos
    if #targets == 0 then
        table.insert(targets, player)
    end

    for _, p in ipairs(targets) do
        local pLvl = p:GetLevel()
        local cLvl = creature:GetLevel()
        local minLvl = (pLvl >= 80) and 75 or math.max(1, pLvl - 5)

        -- Jefes de mazmorra o banda (deben ser del nivel adecuado del jugador)
        if isBoss then
            if cLvl >= minLvl then
                if isRaid then
                    AddBattlePassXP(p, 150, "Jefe de Banda")
                    -- Progreso Misión Semanal #101: Azote de Bandas (target 3, +650 XP)
                    AdvanceQuestProgress(p, 101, 1, 3, 650)
                else
                    AddBattlePassXP(p, 100, "Jefe de Mazmorra")
                    -- Progreso Misión Diaria #1: Mazmorra Diaria (target 1, +250 XP)
                    AdvanceQuestProgress(p, 1, 1, 1, 250)
                end
            end
        elseif isElite80 then
            AddBattlePassXP(p, 25, "Criatura Élite")
            -- Progreso Misión Diaria #4: Cazador de Monstruos (target 25, +150 XP)
            AdvanceQuestProgress(p, 4, 1, 25, 150)
        else
            -- Criaturas normales del mundo
            local cType = creature:GetCreatureType()
            -- Excluir alimañas (8), tótems (11) y mascotas no-combativas (12)
            if cType ~= 8 and cType ~= 11 and cType ~= 12 then
                -- Validar que la criatura pertenezca al nivel del jugador (no trivial / no gris)
                if cLvl >= minLvl then
                    -- Progreso Misión Diaria #4: Cazador de Monstruos (target 25, +150 XP)
                    AdvanceQuestProgress(p, 4, 1, 25, 150)

                    -- Probabilidad de XP por monstruo normal desafiante
                    if math.random(1, 10) == 1 then
                        AddBattlePassXP(p, 5, "Enemigo Derrotado")
                    end
                end
            end
        end
    end
end
RegisterPlayerEvent(7, OnCreatureKill)

-- 4. Al Completar Misiones del Mundo (Eluna Event ID 54: PLAYER_EVENT_ON_QUEST_STATUS_CHANGED)
local function OnQuestStatusChanged(event, player, questId, status)
    if not player then return end

    -- Filtrar únicamente cuando la misión es entregada y recompensada (status 6 = QUEST_STATUS_REWARDED)
    -- Previene doble crédito (status 1 al completar objetivos + status 6 al entregar) y exploit por abandono
    if status and status ~= 6 then
        return
    end

    AddBattlePassXP(player, 35, "Misión Completada")
    -- Progreso Misión Semanal #102: Héroe del Reino (target 15, +500 XP)
    AdvanceQuestProgress(player, 102, 1, 15, 500)
end
RegisterPlayerEvent(54, OnQuestStatusChanged)

-- 5. Al Conseguir Muertes con Honor (PVP) con soporte para grupo/banda
local function OnPvpKill(event, killer, victim)
    if not killer or not victim or killer == victim then return end

    local targets = {}
    local group = killer:GetGroup()

    if group then
        local members = group:GetMembers()
        if members then
            for _, m in ipairs(members) do
                if m and m:IsInWorld() and m:GetMapId() == victim:GetMapId() then
                    -- El ejecutor siempre califica; compañeros deben estar vivos y a rango <= 60 yd
                    if m == killer or (m:IsAlive() and (m:GetDistance(victim) <= 60 or m:GetDistance(killer) <= 60)) then
                        table.insert(targets, m)
                    end
                end
            end
        end
    end

    if #targets == 0 then
        table.insert(targets, killer)
    end

    local vLvl = victim:GetLevel()

    for _, p in ipairs(targets) do
        local pLvl = p:GetLevel()
        local minLvl = (pLvl >= 80) and 72 or math.max(1, pLvl - 8)

        -- Exigir que la víctima sea un objetivo honorable para este miembro (no trivial / no gris)
        if vLvl >= minLvl then
            AddBattlePassXP(p, 15, "Muerte con Honor")
            -- Progreso Misión Semanal #103: Veterano de Guerra (target 40, +550 XP)
            AdvanceQuestProgress(p, 103, 1, 40, 550)
        end
    end
end
RegisterPlayerEvent(6, OnPvpKill)

-- 6. Al Concluir un Campo de Batalla o Arena (Eluna BG Event ID 2: BG_EVENT_ON_END)
local function OnBattlegroundEnd(event, bg, bgId, instanceId, winner)
    if not bg then return end
    local map = bg:GetMap()
    if not map then return end

    local players = map:GetPlayers()
    if not players then return end

    -- En Eluna API, IsArena() pertenece a la clase Map (map:IsArena())
    local isArena = false
    if map.IsArena then
        isArena = map:IsArena()
    elseif bg.IsArena then
        isArena = bg:IsArena()
    end

    if isArena then
        -- MODALIDAD ARENA (1v1, 2v2, 3v3) -> Misión Diaria #3: Duelo de Titanes
        -- Identificar ganadores de forma infalible (supervivientes y compañeros de grupo)
        local arenaWinners = {}
        for _, p in pairs(players) do
            if p and p:IsInWorld() and p:IsAlive() then
                arenaWinners[p:GetGUIDLow()] = true
                local grp = p:GetGroup()
                if grp then
                    local members = grp:GetMembers()
                    if members then
                        for _, m in ipairs(members) do
                            if m and m:IsInWorld() then
                                arenaWinners[m:GetGUIDLow()] = true
                            end
                        end
                    end
                end
            end
        end

        for _, p in pairs(players) do
            if p and p:IsInWorld() then
                AddBattlePassXP(p, 50, "Participación en Arena")
                -- Progreso Misión Diaria #3: Duelo de Titanes (target 2, +200 XP)
                AdvanceQuestProgress(p, 3, 1, 2, 200)

                -- Bonificación al ganador del encuentro
                if arenaWinners[p:GetGUIDLow()] then
                    AddBattlePassXP(p, 25, "Victoria en Arena")
                end
            end
        end
    else
        -- MODALIDAD CAMPO DE BATALLA (BG) -> Misión Diaria #2: Gloria en Batalla
        for _, p in pairs(players) do
            if p and p:IsInWorld() and DidPlayerWinBG(p, winner) then
                AddBattlePassXP(p, 75, "Victoria en Campo de Batalla")
                -- Progreso Misión Diaria #2: Gloria en Batalla (target 1, +300 XP)
                AdvanceQuestProgress(p, 2, 1, 1, 300)
            end
        end
    end
end
RegisterBGEvent(2, OnBattlegroundEnd)

-- 7. Al Recolectar Recursos o Materiales de Profesión (Eluna Event ID 32: PLAYER_EVENT_ON_LOOT_ITEM)
local function OnLootItem(event, player, item, count)
    if not player or not item then return end
    -- Clase de Ítem 7 = ITEM_CLASS_TRADE_GOODS (Gemas, menas, hierbas, cueros, paños, esencias)
    if item:GetClass() == 7 then
        local amount = math.max(1, tonumber(count) or 1)
        -- Progreso Misión Diaria #5: Artesano Andino (target 5, +150 XP)
        AdvanceQuestProgress(player, 5, amount, 5, 150)
    end
end
RegisterPlayerEvent(32, OnLootItem)

-- 8. Al Fabricar Objetos con Profesiones (Eluna Event ID 5: PLAYER_EVENT_ON_SPELL_CAST)
local function OnSpellCast(event, player, spell, skipCheck)
    if not player or not spell then return end

    local spellId = (type(spell) == "number") and spell or (spell.GetEntry and spell:GetEntry())
    if not spellId then return end

    local spellInfo = GetSpellInfo(spellId)
    if not spellInfo then return end

    local isCraft = false
    if spellInfo.IsLootCrafting and spellInfo:IsLootCrafting() then
        isCraft = true
    elseif spellInfo.IsAbilityLearnedWithProfession and spellInfo:IsAbilityLearnedWithProfession() then
        isCraft = true
    elseif spellInfo.GetEffectItemType and ((spellInfo:GetEffectItemType(0) or 0) > 0 or (spellInfo:GetEffectItemType(1) or 0) > 0 or (spellInfo:GetEffectItemType(2) or 0) > 0) then
        isCraft = true
    end

    if isCraft then
        -- Progreso Misión Diaria #5: Artesano Andino (target 5, +150 XP)
        AdvanceQuestProgress(player, 5, 1, 5, 150)
        AddBattlePassXP(player, 30, "Creación de Objeto")
    end
end
RegisterPlayerEvent(5, OnSpellCast)

-- 8. Captura de Mensajes del Addon (RegisterServerEvent 30)
local function OnServerAddonMessage(event, player, type, prefix, message, target)
    if prefix == ADDON_PREFIX then
        ProcessAddonMessage(player, message)
    elseif type == ADDON_PREFIX then
        ProcessAddonMessage(player, prefix)
    end
end
RegisterServerEvent(30, OnServerAddonMessage)

-- ========================================================================
-- COMANDOS PARA EL STAFF Y TIENDA WEB (.bp)
-- ========================================================================
local function OnStaffCommand(event, player, command)
    local args = {}
    for w in command:gmatch("%S+") do table.insert(args, w) end

    local cmd = (args[1] or ""):lower()
    if cmd == "bp" or cmd == ".bp" then
        local sub = (args[2] or ""):lower()

        -- Menú de ayuda interactivo (.bp o .bp help)
        if sub == "" or sub == "help" or sub == "ayuda" then
            player:SendBroadcastMessage("|cFFD4AF37=== Pase de Batalla (WoW Perú) ===|r")
            player:SendBroadcastMessage("  |cFFFFD100.bp sync|r - Sincroniza tu progreso con el servidor.")
            player:SendBroadcastMessage("  |cFFFFD100.bp claim <nivel> [free|premium]|r - Reclama una recompensa.")
            if player:GetGMRank() >= 2 then
                player:SendBroadcastMessage("  |cFFFF8000.bp vip <jugador> <1|0>|r - Activa/revoca el Pase VIP.")
                player:SendBroadcastMessage("  |cFFFF8000.bp addxp <jugador> <cantidad>|r - Otorga XP del Pase.")
            end
            return false

        -- .bp sync
        elseif sub == "sync" then
            SendSync(player)
            return false

        -- .bp claim <nivel> [free|premium] (Fallback seguro para jugadores solitarios o macros)
        elseif sub == "claim" then
            local lvl = tonumber(args[3]) or 0
            local trk = (args[4] or "free"):lower()
            if trk == "" or trk == "gratis" then trk = "free" end
            if trk == "vip" or trk == "prem" then trk = "premium" end
            ProcessAddonMessage(player, string.format("BP_CLAIM:%d:%s", lvl, trk))
            return false

        -- .bp vip <jugador> <1|0|on|off>
        elseif sub == "vip" then
            if player:GetGMRank() < 2 then
                player:SendBroadcastMessage("|cFFFF4444[WoW Perú]|r No tienes permisos para usar este comando.")
                return false
            end
            local targetName = args[3]
            if not targetName or targetName == "" then
                player:SendBroadcastMessage("|cFFFF4444[WoW Perú]|r Uso: .bp vip <nombre_jugador> <1|0|on|off>")
                return false
            end

            if targetName:find("['\"\\;%s]") or #targetName < 2 or #targetName > 24 then
                player:SendBroadcastMessage("|cFFFF4444[WoW Perú]|r Nombre de personaje inválido.")
                return false
            end

            local flagRaw = (args[4] or "1"):lower()
            local flag = 1
            if flagRaw == "0" or flagRaw == "off" or flagRaw == "no" or flagRaw == "false" or flagRaw == "revoke" or flagRaw == "desactivar" then
                flag = 0
            end

            local target = GetPlayerByName(targetName)
            if target then
                local tGuid = target:GetGUIDLow()
                local tData = GetOrLoadPlayerData(target)
                tData.is_premium = (flag == 1)
                SavePlayerData(tGuid)
                SendSync(target)
                target:SendBroadcastMessage(flag == 1 and "|cFFD4AF37[WoW Perú]|r ¡Pase VIP activado!" or "|cFFFF4444[WoW Perú]|r Pase VIP revocado.")
                player:SendBroadcastMessage(string.format("|cFFD4AF37[WoW Perú]|r Estado VIP actualizado a %d para %s (conectado).", flag, targetName))
            else
                -- Jugador desconectado: Validar existencia real en 'characters'
                local qChar = CharDBQuery(string.format("SELECT guid FROM characters WHERE name = '%s'", targetName))
                if not qChar then
                    player:SendBroadcastMessage(string.format("|cFFFF4444[WoW Perú]|r El personaje '%s' no existe en el reino.", targetName))
                    return false
                end
                local tGuid = qChar:GetUInt32(0)

                -- UPSERT seguro: Si no ha iniciado sesión en la temporada actual, crea el registro con VIP activo
                CharDBExecute(string.format([[
                    INSERT INTO character_battlepass (guid, season_id, level, xp, is_premium, claimed_free, claimed_premium)
                    VALUES (%d, %d, 1, 0, %d, '0000000000000', '0000000000000')
                    ON DUPLICATE KEY UPDATE is_premium = %d
                ]], tGuid, SEASON_ID, flag, flag))
                player:SendBroadcastMessage(string.format("|cFFD4AF37[WoW Perú]|r Estado VIP actualizado a %d para %s (desconectado, guardado en BD).", flag, targetName))
            end
            return false

        -- .bp addxp <jugador> <cantidad>
        elseif sub == "addxp" then
            if player:GetGMRank() < 2 then
                player:SendBroadcastMessage("|cFFFF4444[WoW Perú]|r No tienes permisos para usar este comando.")
                return false
            end
            local targetName = args[3]
            if not targetName or targetName == "" then
                player:SendBroadcastMessage("|cFFFF4444[WoW Perú]|r Uso: .bp addxp <nombre_jugador> <cantidad>")
                return false
            end

            if targetName:find("['\"\\;%s]") or #targetName < 2 or #targetName > 24 then
                player:SendBroadcastMessage("|cFFFF4444[WoW Perú]|r Nombre de personaje inválido.")
                return false
            end

            local amount = tonumber(args[4])
            if not amount or amount <= 0 then
                player:SendBroadcastMessage("|cFFFF4444[WoW Perú]|r Cantidad inválida. Debe ser un número mayor a 0.")
                return false
            end

            local target = GetPlayerByName(targetName)
            if target then
                AddBattlePassXP(target, amount, "Comando Staff")
                player:SendBroadcastMessage(string.format("|cFFD4AF37[WoW Perú]|r Se otorgaron %d XP a %s", amount, targetName))
            else
                player:SendBroadcastMessage(string.format("|cFFFF4444[WoW Perú]|r Jugador '%s' no encontrado o desconectado.", targetName))
            end
            return false

        -- Subcomando desconocido
        else
            player:SendBroadcastMessage("|cFFFF4444[WoW Perú]|r Subcomando desconocido. Usa |cFFFFD100.bp help|r.")
            return false
        end
    end
    return true
end
RegisterPlayerEvent(42, OnStaffCommand)

-- ========================================================================
-- INICIALIZACIÓN EN CALIENTE (.reload eluna SAFE)
-- ========================================================================
if GetPlayersInWorld then
    local onlinePlayers = GetPlayersInWorld()
    if type(onlinePlayers) == "table" then
        for _, p in pairs(onlinePlayers) do
            if p and p:IsInWorld() then
                GetOrLoadPlayerData(p)
            end
        end
    end
end
