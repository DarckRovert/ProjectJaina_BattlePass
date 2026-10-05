--[[
    ========================================================================
    WoW Perú - Pase de Batalla (MinimapButton.lua)
    Reino: Reino Andino | Servidor: https://wow-peru.lat/
    Cliente Compatible: World of Warcraft 3.3.5a (Build 12340)
    ========================================================================
    Botón circular para el Minimapa con órbita matemática libre,
    persistencia de ángulo y tooltip reactivo con el estado del pase.
]]

WoWPeru_BattlePass = WoWPeru_BattlePass or {}
local BP = WoWPeru_BattlePass
local L = BP.L or {}

BP.Minimap = {}
local MM = BP.Minimap

local DEFAULT_ANGLE = 220
local RADIUS = 80

-- ========================================================================
-- CÁLCULO DE POSICIÓN Y MOVIMIENTO CIRCULAR
-- ========================================================================
local function UpdatePosition(button, angle)
    local rad = math.rad(angle)
    local x = math.cos(rad) * RADIUS
    local y = math.sin(rad) * RADIUS
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

-- ========================================================================
-- CONSTRUCCIÓN DEL BOTÓN DE MINIMAPA
-- ========================================================================
local btn = CreateFrame("Button", "WoWPeru_BattlePass_MinimapBtn", Minimap)
btn:SetFrameStrata("MEDIUM")
btn:SetWidth(32)
btn:SetHeight(32)
btn:SetFrameLevel(8)
btn:EnableMouse(true)
btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
btn:RegisterForDrag("RightButton")
btn:SetMovable(true)

-- Icono Central (Blasón Dorado / Escudo Épico)
local icon = btn:CreateTexture(nil, "BACKGROUND")
icon:SetWidth(20)
icon:SetHeight(20)
icon:SetPoint("CENTER", btn, "CENTER", 0, 0)
icon:SetTexture("Interface\\Icons\\Achievement_Zone_TolBarad")
icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
btn.icon = icon

-- Borde Circular Clásico de WotLK
local border = btn:CreateTexture(nil, "OVERLAY")
border:SetWidth(54)
border:SetHeight(54)
border:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
btn.border = border

-- Brillo / Highlight al pasar el cursor
local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
highlight:SetWidth(32)
highlight:SetHeight(32)
highlight:SetPoint("CENTER", btn, "CENTER", 0, 0)
highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
btn.highlight = highlight

-- ========================================================================
-- EVENTOS DE RATÓN (ARRASTRE EFICIENTE Y CLIC)
-- ========================================================================
local wasDragged = false
local dragStartX, dragStartY = 0, 0
local DRAG_THRESHOLD_SQ = 16 -- 4 píxeles de tolerancia física para diferenciar clic de arrastre

local function OnDragUpdate(self)
    local curX, curY = GetCursorPosition()
    if not wasDragged then
        local dx = curX - dragStartX
        local dy = curY - dragStartY
        if (dx * dx + dy * dy) < DRAG_THRESHOLD_SQ then
            return
        end
        wasDragged = true
    end

    local mx, my = Minimap:GetCenter()
    local scale = Minimap:GetEffectiveScale()
    local px, py = curX / scale, curY / scale

    local angle = math.deg(math.atan2(py - my, px - mx))
    if angle < 0 then angle = angle + 360 end

    WoWPeru_BattlePass_CharDB = WoWPeru_BattlePass_CharDB or {}
    WoWPeru_BattlePass_CharDB.minimapAngle = angle

    UpdatePosition(self, angle)
end

btn:SetScript("OnDragStart", function(self)
    wasDragged = false
    dragStartX, dragStartY = GetCursorPosition()
    self:LockHighlight()
    self:SetScript("OnUpdate", OnDragUpdate)
end)

btn:SetScript("OnDragStop", function(self)
    self:UnlockHighlight()
    self:SetScript("OnUpdate", nil)
end)

btn:SetScript("OnClick", function(self, button)
    if button == "LeftButton" then
        if BP.UI and BP.UI.Toggle then
            BP.UI:Toggle()
        end
    elseif button == "RightButton" and not wasDragged then
        BP:Print("Sincronizando con el servidor...")
        BP:RequestSync()
    end
    wasDragged = false
end)

-- ========================================================================
-- TOOLTIP DINÁMICO
-- ========================================================================
btn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:ClearLines()

    -- Título
    GameTooltip:AddLine(L["MINIMAP_TOOLTIP_TITLE"], 1, 0.82, 0)

    -- Nivel actual
    local lvlText = string.format(L["MINIMAP_TOOLTIP_LEVEL"], BP.Data.level or 1)
    if (BP.Data.level or 1) >= BP.Config.MaxLevel then
        lvlText = lvlText .. " |cFF00FF00(" .. L["MAX_LEVEL_REACHED"] .. ")|r"
    end
    GameTooltip:AddLine(lvlText, 1, 1, 1)

    -- Barra de Progreso XP
    local curLvl = BP.Data.level or 1
    local curXp = BP.Data.xp or 0
    local reqXp = BP.Config.XPPerLevel or 1000

    if curLvl >= BP.Config.MaxLevel then
        GameTooltip:AddLine("Progreso XP: |cFF00FF00" .. L["MAX_LEVEL_REACHED"] .. "|r", 0.8, 0.8, 0.8)
    else
        local pct = math.floor((curXp / reqXp) * 100)
        GameTooltip:AddLine(string.format(L["MINIMAP_TOOLTIP_XP"], curXp, reqXp, pct), 0.8, 0.8, 0.8)
    end

    -- Estado VIP
    local vipStatus = BP.Data.isPremium and "|cFF00FF00VIP ACTIVO|r" or "|cFFFF4444VIP INACTIVO|r"
    GameTooltip:AddLine(string.format(L["MINIMAP_TOOLTIP_VIP"], vipStatus), 1, 1, 1)

    -- Resumen de Misiones Diarias
    local dailyQuests = BP.Config.Quests and BP.Config.Quests.Daily or {}
    local totalDaily = #dailyQuests
    local completedDaily = 0
    for _, q in ipairs(dailyQuests) do
        local qState = BP.Data.quests and BP.Data.quests[q.id]
        if qState and qState.completed then
            completedDaily = completedDaily + 1
        end
    end
    GameTooltip:AddLine(string.format(L["MINIMAP_TOOLTIP_DAILY"], completedDaily, totalDaily), 1, 1, 1)

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(L["MINIMAP_TOOLTIP_DESC"], 0.6, 0.6, 0.6)
    GameTooltip:AddLine("|cFF888888Clic derecho para sincronizar con el servidor.|r", 0.5, 0.5, 0.5)
    GameTooltip:AddLine("|cFFD4AF37Desarrollo:|r DarckRovert (Elnazzareno)", 0.8, 0.7, 0.3)

    GameTooltip:Show()
end)

btn:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

-- ========================================================================
-- INICIALIZACIÓN Y CONTROL PÚBLICO
-- ========================================================================
function MM:Init()
    WoWPeru_BattlePass_CharDB = WoWPeru_BattlePass_CharDB or {}
    local angle = WoWPeru_BattlePass_CharDB.minimapAngle or DEFAULT_ANGLE
    UpdatePosition(btn, angle)

    if WoWPeru_BattlePass_CharDB.hideMinimap then
        btn:Hide()
    else
        btn:Show()
    end
end

function MM:UpdateTooltip()
    if btn:IsShown() and btn:IsMouseOver() then
        local onEnter = btn:GetScript("OnEnter")
        if onEnter then
            onEnter(btn)
        end
    end
end

function MM:Toggle()
    WoWPeru_BattlePass_CharDB = WoWPeru_BattlePass_CharDB or {}
    if btn:IsShown() then
        btn:Hide()
        WoWPeru_BattlePass_CharDB.hideMinimap = true
        BP:Print("Botón del minimapa oculto. Usa /bp minimap para volver a mostrarlo.")
    else
        btn:Show()
        WoWPeru_BattlePass_CharDB.hideMinimap = false
        BP:Print("Botón del minimapa visible.")
    end
end

-- Cargar posición al iniciar
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")
loader:SetScript("OnEvent", function(self, event)
    MM:Init()
    self:UnregisterAllEvents()
end)
