--[[
    ========================================================================
    WoW Perú - Pase de Batalla (Core.lua)
    Reino: Reino Andino | Servidor: https://wow-peru.lat/
    Cliente Compatible: World of Warcraft 3.3.5a (Build 12340)
    ========================================================================
    Motor central: Máquina de estados, codificador/decodificador bitmask hex,
    despacho de red seguro (SendAddonMessage 255-safe) y sincronización.
]]

WoWPeru_BattlePass = WoWPeru_BattlePass or {}
local BP = WoWPeru_BattlePass
local L = BP.L or {}

-- ========================================================================
-- ESTADO EN MEMORIA Y VALORES POR DEFECTO
-- ========================================================================
BP.Data = {
    seasonId = 1,
    level = 1,
    xp = 0,
    isPremium = false,
    claimedFree = "0000000000000", -- 13 caracteres hex = 52 bits para 50 niveles
    claimedPrem = "0000000000000",
    quests = {},
    lastSyncTime = 0,
    hasSyncedOnce = false,
}

local HEX_CHARS = "0123456789ABCDEF"
local HEX_MAP = {}
for i = 1, #HEX_CHARS do
    HEX_MAP[HEX_CHARS:sub(i, i)] = i - 1
end

-- ========================================================================
-- UTILIDADES DE BITMASK HEXADECIMAL (100% LUA 5.1 SEGURO, CERO OVERFLOW)
-- ========================================================================
-- Cada caracter representa 4 bits (1 nibble). Nivel 1 = bit 0 del caracter 1.
-- Nivel 50 = bit 1 del caracter 13.
function BP:IsLevelClaimedInHex(hexStr, level)
    if not hexStr or type(hexStr) ~= "string" or level < 1 or level > BP.Config.MaxLevel then
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

function BP:SetLevelClaimedInHex(hexStr, level)
    if not hexStr or type(hexStr) ~= "string" then
        hexStr = "0000000000000"
    end
    while #hexStr < 13 do
        hexStr = hexStr .. "0"
    end

    if level < 1 or level > BP.Config.MaxLevel then
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

function BP:IsClaimed(track, level)
    if track == "free" then
        return self:IsLevelClaimedInHex(self.Data.claimedFree, level)
    elseif track == "premium" then
        return self:IsLevelClaimedInHex(self.Data.claimedPrem, level)
    end
    return false
end

-- ========================================================================
-- FUNCIONES DE COMUNICACIÓN DE RED (SENDADDONMESSAGE RESILIENTE)
-- ========================================================================
function BP:Print(msg)
    local chatFrame = DEFAULT_CHAT_FRAME or ChatFrame1
    if chatFrame and chatFrame.AddMessage then
        chatFrame:AddMessage("|cFFD4AF37[WoW Perú BP]|r " .. tostring(msg))
    end
end

function BP:DebugPrint(msg)
    if BP.Config and BP.Config.Debug then
        local chatFrame = DEFAULT_CHAT_FRAME or ChatFrame1
        if chatFrame and chatFrame.AddMessage then
            chatFrame:AddMessage("|cFF888888[BP Debug]|r " .. tostring(msg))
        end
    end
end

function BP:SendPacket(payload)
    if not payload or payload == "" then return false end
    self:DebugPrint("Enviando paquete: " .. payload)

    local prefix = (BP.Config and BP.Config.AddonPrefix) or "WP_BP"
    local playerName = UnitName("player")
    if not playerName or playerName == "" or playerName == UNKNOWNOBJECT then
        self:DebugPrint("UnitName('player') aún no disponible, paquete pospuesto.")
        return false
    end

    SendAddonMessage(prefix, payload, "WHISPER", playerName)
    return true
end

function BP:RequestSync()
    local now = GetTime()
    if now - self.Data.lastSyncTime < 2 then
        self:DebugPrint("Sincronización en cooldown.")
        return
    end
    if self:SendPacket("BP_REQ_SYNC") then
        self.Data.lastSyncTime = now
    end
end

function BP:ClaimReward(level, track)
    if level < 1 or level > BP.Config.MaxLevel then return false end
    if track ~= "free" and track ~= "premium" then return false end

    -- Validaciones locales preventivas
    if level > self.Data.level then
        self:Print("Aún no alcanzas el Nivel " .. level .. " para reclamar esta recompensa.")
        return false
    end

    if track == "premium" and not self.Data.isPremium then
        self:Print("Esta recompensa requiere el Pase VIP.")
        return false
    end

    if self:IsClaimed(track, level) then
        self:Print("Ya has reclamado la recompensa del Nivel " .. level .. ".")
        return false
    end

    -- Envío de paquete seguro
    local payload = string.format("BP_CLAIM:%d:%s", level, track:upper())
    return self:SendPacket(payload)
end

-- ========================================================================
-- MANEJADOR DE MENSAJES DE ENTRADA (PARSER DE PROTOCOLO WP_BP)
-- ========================================================================
function BP:OnAddonMessage(prefix, message, channel, sender)
    if prefix ~= BP.Config.AddonPrefix then return end
    self:DebugPrint("Recibido de " .. tostring(sender) .. ": " .. tostring(message))

    local parts = {}
    for part in string.gmatch(message, "[^:]+") do
        table.insert(parts, part)
    end

    local opCode = parts[1]
    if not opCode then return end

    -- 1. RESPUESTA DE SINCRONIZACIÓN COMPLETA
    -- BP_RES_SYNC:<SEASON>:<LEVEL>:<XP>:<IS_PREMIUM>:<HEX_FREE>:<HEX_PREM>
    if opCode == "BP_RES_SYNC" then
        self.Data.seasonId = tonumber(parts[2]) or 1
        local isInitialSync = not self.Data.hasSyncedOnce
        self.Data.hasSyncedOnce = true
        local oldLevel = self.Data.level
        self.Data.level = tonumber(parts[3]) or 1
        self.Data.xp = tonumber(parts[4]) or 0
        self.Data.isPremium = (parts[5] == "1" or parts[5] == "true")
        self.Data.claimedFree = parts[6] or "0000000000000"
        self.Data.claimedPrem = parts[7] or "0000000000000"

        self:SaveToCharDB()
        self:OnDataUpdated()

        if not isInitialSync and oldLevel and self.Data.level > oldLevel then
            PlaySoundFile(BP.Config.SoundLevelUp)
            self:Print(string.format(L["MSG_LEVEL_UP"], self.Data.level))
        end

    -- 2. RESPUESTA DE RECLAMO DE RECOMPENSA
    -- BP_RES_CLAIM:<LEVEL>:<TRACK>:<SUCCESS>:<MSG_CODE>
    elseif opCode == "BP_RES_CLAIM" then
        local lvl = tonumber(parts[2]) or 0
        local trk = (parts[3] or ""):lower()
        local success = (parts[4] == "1")
        local msgCode = parts[5] or "OK"

        if success and lvl >= 1 then
            PlaySoundFile(BP.Config.SoundClaim)
            if trk == "free" then
                self.Data.claimedFree = self:SetLevelClaimedInHex(self.Data.claimedFree, lvl)
            elseif trk == "premium" then
                self.Data.claimedPrem = self:SetLevelClaimedInHex(self.Data.claimedPrem, lvl)
            end
            self:SaveToCharDB()
            self:OnDataUpdated()

            local trackName = (trk == "premium") and L["TRACK_PREMIUM"] or L["TRACK_FREE"]
            if msgCode == "MAIL" then
                self:Print(L["MSG_CLAIM_MAIL"])
            else
                self:Print(string.format(L["MSG_CLAIM_SUCCESS"], lvl, trackName))
            end
        else
            self:Print("No se pudo reclamar la recompensa: " .. tostring(msgCode))
            self:OnDataUpdated()
        end

    -- 3. ACTUALIZACIÓN DE EXPERIENCIA / SUBIDA DE NIVEL
    -- BP_RES_XP:<LEVEL>:<XP>:<GAINED>:<REASON>
    elseif opCode == "BP_RES_XP" then
        local prevLevel = self.Data.level
        self.Data.level = tonumber(parts[2]) or self.Data.level
        self.Data.xp = tonumber(parts[3]) or self.Data.xp
        local gained = tonumber(parts[4]) or 0
        local reason = parts[5] or "Actividad"

        if gained > 0 then
            self:Print(string.format("+%d XP del Pase de Batalla (%s)", gained, reason))
        end

        if self.Data.level > prevLevel then
            PlaySoundFile(BP.Config.SoundLevelUp)
            self:Print(string.format(L["MSG_LEVEL_UP"], self.Data.level))
        end

        self:SaveToCharDB()
        self:OnDataUpdated()

    -- 4. ACTUALIZACIÓN DE PROGRESO DE MISIÓN
    -- BP_RES_QUEST:<QUEST_ID>:<PROGRESS>:<COMPLETED>
    elseif opCode == "BP_RES_QUEST" then
        local qId = tonumber(parts[2]) or 0
        local prog = tonumber(parts[3]) or 0
        local comp = (parts[4] == "1")

        if qId > 0 then
            self.Data.quests[qId] = { progress = prog, completed = comp }
            self:SaveToCharDB()
            self:OnDataUpdated()
        end
    end
end

-- ========================================================================
-- PERSISTENCIA LOCAL (SAVEDVARIABLES)
-- ========================================================================
function BP:LoadFromCharDB()
    WoWPeru_BattlePass_CharDB = WoWPeru_BattlePass_CharDB or {}
    local db = WoWPeru_BattlePass_CharDB

    local currentSeason = BP.Config.SeasonId or 1

    -- Detección de cambio de temporada: Reinicio atómico de estado local obsoleto
    if db.seasonId and db.seasonId ~= currentSeason then
        db.seasonId = currentSeason
        db.level = 1
        db.xp = 0
        db.isPremium = false
        db.claimedFree = "0000000000000"
        db.claimedPrem = "0000000000000"
        db.quests = {}
    end

    self.Data.seasonId = db.seasonId or currentSeason
    self.Data.level = db.level or 1
    self.Data.xp = db.xp or 0
    self.Data.isPremium = db.isPremium or false
    self.Data.claimedFree = db.claimedFree or "0000000000000"
    self.Data.claimedPrem = db.claimedPrem or "0000000000000"
    self.Data.quests = db.quests or {}
end

function BP:SaveToCharDB()
    WoWPeru_BattlePass_CharDB = WoWPeru_BattlePass_CharDB or {}
    local db = WoWPeru_BattlePass_CharDB

    db.seasonId = self.Data.seasonId or BP.Config.SeasonId or 1
    db.level = self.Data.level
    db.xp = self.Data.xp
    db.isPremium = self.Data.isPremium
    db.claimedFree = self.Data.claimedFree
    db.claimedPrem = self.Data.claimedPrem
    db.quests = self.Data.quests
end

function BP:OnDataUpdated()
    if BP.UI and BP.UI.Refresh then
        BP.UI:Refresh()
    end
    if BP.Minimap and BP.Minimap.UpdateTooltip then
        BP.Minimap:UpdateTooltip()
    end
end

-- ========================================================================
-- REGISTRO DE EVENTOS DEL CLIENTE
-- ========================================================================
local eventFrame = CreateFrame("Frame", "WoWPeru_BattlePass_EventFrame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("CHAT_MSG_ADDON")
eventFrame:RegisterEvent("PLAYER_LOGOUT")

-- Temporizador estático reciclable para sincronización inicial segura (1.5s post-carga)
local syncDelayFrame = CreateFrame("Frame")
syncDelayFrame:Hide()
local syncDelayElapsed = 0
syncDelayFrame:SetScript("OnUpdate", function(self, elapsed)
    syncDelayElapsed = syncDelayElapsed + elapsed
    if syncDelayElapsed >= 1.5 then
        self:Hide()
        BP:RequestSync()
    end
end)

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "WoWPeru_BattlePass" then
            BP:LoadFromCharDB()
            BP:DebugPrint("Addon cargado con éxito.")
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        if RegisterAddonMessagePrefix then
            RegisterAddonMessagePrefix(BP.Config.AddonPrefix)
        end
        -- Solicitar estado del pase al servidor tras breve delay seguro (1.5s)
        syncDelayElapsed = 0
        syncDelayFrame:Show()

    elseif event == "CHAT_MSG_ADDON" then
        local prefix, message, channel, sender = ...
        BP:OnAddonMessage(prefix, message, channel, sender)

    elseif event == "PLAYER_LOGOUT" then
        BP:SaveToCharDB()
    end
end)

-- ========================================================================
-- COMANDOS SLASH (/bp, /pase, /battlepass)
-- ========================================================================
SLASH_WOWPERUBP1 = "/bp"
SLASH_WOWPERUBP2 = "/pase"
SLASH_WOWPERUBP3 = "/battlepass"

SlashCmdList["WOWPERUBP"] = function(msg)
    local args = {}
    for w in (msg or ""):gmatch("%S+") do
        table.insert(args, w)
    end
    local sub = (args[1] or ""):lower()

    if sub == "" or sub == "toggle" then
        if BP.UI and BP.UI.Toggle then
            BP.UI:Toggle()
        else
            BP:Print("La interfaz de usuario no está cargada.")
        end
    elseif sub == "claim" then
        local lvl = tonumber(args[2])
        local trk = (args[3] or "free"):lower()
        if trk == "vip" or trk == "prem" then trk = "premium" end
        if trk == "gratis" then trk = "free" end

        if lvl and lvl >= 1 and lvl <= BP.Config.MaxLevel then
            if trk == "free" or trk == "premium" then
                BP:ClaimReward(lvl, trk)
            else
                BP:Print("Vía de pase inválida. Usa: |cFFFFD100free|r o |cFFFFD100premium|r.")
            end
        else
            BP:Print("Uso: /bp claim <nivel 1-" .. BP.Config.MaxLevel .. "> [free|premium]")
        end
    elseif sub == "sync" then
        BP:Print("Solicitando sincronización al servidor...")
        BP:RequestSync()
    elseif sub == "minimap" then
        if BP.Minimap and BP.Minimap.Toggle then
            BP.Minimap:Toggle()
        end
    elseif sub == "reset" then
        if BP.UI and BP.UI.ResetPosition then
            BP.UI:ResetPosition()
        end
    elseif sub == "debug" then
        BP.Config.Debug = not BP.Config.Debug
        BP:Print("Modo depuración: " .. (BP.Config.Debug and "|cFF00FF00ACTIVO|r" or "|cFFFF0000INACTIVO|r"))
    else
        BP:Print(L["MSG_COMMAND_HELP"])
    end
end
