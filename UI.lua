--[[
    ========================================================================
    WoW Perú - Pase de Batalla (UI.lua)
    Reino: Reino Andino | Servidor: https://wow-peru.lat/
    Cliente Compatible: World of Warcraft 3.3.5a (Build 12340)
    ========================================================================
    Interfaz de Usuario: Carrusel virtual de 5 slots reciclables (Cero lag),
    pestañas de Misiones Diarias/Semanales y Pase VIP, adaptativo a 800x600+.
]]

WoWPeru_BattlePass = WoWPeru_BattlePass or {}
local BP = WoWPeru_BattlePass
local L = BP.L or {}

BP.UI = {}
local UI = BP.UI

-- Constantes de Diseño
local FRAME_WIDTH = 750
local FRAME_HEIGHT = 520
local SLOTS_PER_PAGE = 5
local TOTAL_PAGES = 10 -- 50 niveles / 5 por página

UI.currentPage = 1
UI.activeTab = 1 -- 1: Recompensas, 2: Misiones, 3: VIP

-- ========================================================================
-- CREACIÓN DEL MARCO PRINCIPAL
-- ========================================================================
local mainFrame = CreateFrame("Frame", "WoWPeru_BattlePass_MainFrame", UIParent)
mainFrame:SetWidth(FRAME_WIDTH)
mainFrame:SetHeight(FRAME_HEIGHT)
mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
mainFrame:SetFrameStrata("HIGH")
mainFrame:SetToplevel(true)
mainFrame:EnableMouse(true)
mainFrame:SetMovable(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetClampedToScreen(true)
mainFrame:Hide()

mainFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 28,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})

mainFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
mainFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    WoWPeru_BattlePass_CharDB = WoWPeru_BattlePass_CharDB or {}
    WoWPeru_BattlePass_CharDB.pos = { point = point, relPoint = relPoint, x = x, y = y }
end)

UI.mainFrame = mainFrame

-- Adaptador de escala para monitores de cabina (800x600 / 1024x768)
function UI:AdjustScale()
    local screenH = UIParent:GetHeight() or 768
    local targetScale = math.min(1.0, (screenH - 50) / FRAME_HEIGHT)
    mainFrame:SetScale(math.max(0.75, targetScale))
end

-- Botón Cerrar (X)
local closeBtn = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -5, -5)
closeBtn:SetScript("OnClick", function() UI:Hide() end)

-- ========================================================================
-- CABECERA: TÍTULO, NIVEL, BARRA DE XP Y ESTADO VIP
-- ========================================================================
local header = CreateFrame("Frame", nil, mainFrame)
header:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 12, -12)
header:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -12, -12)
header:SetHeight(75)

-- Fondo decorativo oscuro para la cabecera
local headerBg = header:CreateTexture(nil, "BACKGROUND")
headerBg:SetAllPoints(header)
headerBg:SetTexture(0.05, 0.05, 0.08, 0.9)

-- Título Principal Dorado
local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
title:SetPoint("TOPLEFT", header, "TOPLEFT", 16, -10)
title:SetText("|cFFD4AF37WoW Perú|r - " .. L["TITLE"])

-- Subtítulo / Temporada
local seasonText = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
seasonText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -3)
seasonText:SetText(L["HEADER_SEASON"] .. "  |cFF888888•|r  |cFF00FF00" .. string.format(L["DAYS_REMAINING"], BP.Config.SeasonDaysTotal or 60) .. "|r")

-- Escudo / Insignia de Nivel Actual
local levelBadge = CreateFrame("Frame", nil, header)
levelBadge:SetWidth(50)
levelBadge:SetHeight(50)
levelBadge:SetPoint("TOPRIGHT", header, "TOPRIGHT", -16, -10)

local levelBg = levelBadge:CreateTexture(nil, "BACKGROUND")
levelBg:SetAllPoints(levelBadge)
levelBg:SetTexture("Interface\\Icons\\Achievement_Zone_TolBarad")
levelBg:SetTexCoord(0.08, 0.92, 0.08, 0.92)

local levelBorder = levelBadge:CreateTexture(nil, "OVERLAY")
levelBorder:SetPoint("TOPLEFT", levelBadge, "TOPLEFT", -6, 6)
levelBorder:SetPoint("BOTTOMRIGHT", levelBadge, "BOTTOMRIGHT", 6, -6)
levelBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

local levelNumber = levelBadge:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
levelNumber:SetPoint("CENTER", levelBadge, "CENTER", 0, 0)
levelNumber:SetTextColor(1, 0.9, 0.2)
levelNumber:SetText("1")
UI.levelNumber = levelNumber

local levelLabel = levelBadge:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
levelLabel:SetPoint("BOTTOM", levelBadge, "TOP", 0, 3)
levelLabel:SetText("|cFFFFD100NIVEL|r")

-- Barra de Experiencia (XP)
local xpBar = CreateFrame("StatusBar", nil, header)
xpBar:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -26)
xpBar:SetWidth(460)
xpBar:SetHeight(16)
xpBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
xpBar:SetStatusBarColor(0.85, 0.65, 0.15) -- Dorado brillante

local xpBg = xpBar:CreateTexture(nil, "BACKGROUND")
xpBg:SetAllPoints(xpBar)
xpBg:SetTexture(0.12, 0.12, 0.15, 0.9)

local xpText = xpBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
xpText:SetPoint("CENTER", xpBar, "CENTER", 0, 0)
xpText:SetText("0 / 1000 XP (0%)")
UI.xpBar = xpBar
UI.xpText = xpText

-- Distintivo VIP
local vipBadge = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
vipBadge:SetPoint("RIGHT", levelBadge, "LEFT", -15, 0)
vipBadge:SetText("|cFFFF4444VIP INACTIVO|r")
UI.vipBadge = vipBadge

-- ========================================================================
-- PESTAÑAS DE NAVEGACIÓN (TABS)
-- ========================================================================
local function CreateTab(id, text, xOffset)
    local tab = CreateFrame("Button", "WoWPeru_BP_Tab" .. id, mainFrame)
    tab:SetWidth(120)
    tab:SetHeight(26)
    tab:SetPoint("TOPLEFT", header, "BOTTOMLEFT", xOffset, -8)

    local tabBg = tab:CreateTexture(nil, "BACKGROUND")
    tabBg:SetAllPoints(tab)
    tabBg:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight")
    tabBg:SetAlpha(0.2)
    tab.bg = tabBg

    local tabText = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tabText:SetPoint("CENTER", tab, "CENTER", 0, 0)
    tabText:SetText(text)
    tab.text = tabText

    tab:SetScript("OnClick", function()
        UI:SelectTab(id)
    end)

    return tab
end

local tab1 = CreateTab(1, L["TAB_REWARDS"], 16)
local tab2 = CreateTab(2, L["TAB_QUESTS"], 142)
local tab3 = CreateTab(3, L["TAB_VIP"], 268)

UI.tabs = { tab1, tab2, tab3 }

-- Contenedores de cada pestaña
local rewardsContainer = CreateFrame("Frame", nil, mainFrame)
rewardsContainer:SetPoint("TOPLEFT", tab1, "BOTTOMLEFT", 0, -10)
rewardsContainer:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -16, 16)
UI.rewardsContainer = rewardsContainer

local questsContainer = CreateFrame("Frame", nil, mainFrame)
questsContainer:SetPoint("TOPLEFT", tab1, "BOTTOMLEFT", 0, -10)
questsContainer:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -16, 16)
questsContainer:Hide()
UI.questsContainer = questsContainer

local vipContainer = CreateFrame("Frame", nil, mainFrame)
vipContainer:SetPoint("TOPLEFT", tab1, "BOTTOMLEFT", 0, -10)
vipContainer:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -16, 16)
vipContainer:Hide()
UI.vipContainer = vipContainer

function UI:SelectTab(tabId)
    UI.activeTab = tabId
    for i, t in ipairs(UI.tabs) do
        if i == tabId then
            t.bg:SetAlpha(0.6)
            t.text:SetTextColor(1, 0.82, 0)
        else
            t.bg:SetAlpha(0.2)
            t.text:SetTextColor(0.7, 0.7, 0.7)
        end
    end

    rewardsContainer:Hide()
    questsContainer:Hide()
    vipContainer:Hide()

    if tabId == 1 then
        rewardsContainer:Show()
        UI:RenderPage(UI.currentPage)
    elseif tabId == 2 then
        questsContainer:Show()
        UI:RenderQuests()
    elseif tabId == 3 then
        vipContainer:Show()
        UI:RenderVIP()
    end
end

-- ========================================================================
-- PESTAÑA 1: CARRUSEL DE RECOMPENSAS (POOL DE 5 SLOTS RECICLABLES)
-- ========================================================================
-- Barra de Paginación Inferior
local paginationBar = CreateFrame("Frame", nil, rewardsContainer)
paginationBar:SetPoint("BOTTOMLEFT", rewardsContainer, "BOTTOMLEFT", 0, 0)
paginationBar:SetPoint("BOTTOMRIGHT", rewardsContainer, "BOTTOMRIGHT", 0, 0)
paginationBar:SetHeight(32)

local prevBtn = CreateFrame("Button", nil, paginationBar, "UIPanelButtonTemplate")
prevBtn:SetWidth(90)
prevBtn:SetHeight(24)
prevBtn:SetPoint("LEFT", paginationBar, "LEFT", 10, 0)
prevBtn:SetText("« " .. L["PREV_PAGE"])
prevBtn:SetScript("OnClick", function()
    if UI.currentPage > 1 then
        UI.currentPage = UI.currentPage - 1
        UI:RenderPage(UI.currentPage)
    end
end)
UI.prevBtn = prevBtn

local nextBtn = CreateFrame("Button", nil, paginationBar, "UIPanelButtonTemplate")
nextBtn:SetWidth(90)
nextBtn:SetHeight(24)
nextBtn:SetPoint("RIGHT", paginationBar, "RIGHT", -10, 0)
nextBtn:SetText(L["NEXT_PAGE"] .. " »")
nextBtn:SetScript("OnClick", function()
    if UI.currentPage < TOTAL_PAGES then
        UI.currentPage = UI.currentPage + 1
        UI:RenderPage(UI.currentPage)
    end
end)
UI.nextBtn = nextBtn

local pageIndicator = paginationBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
pageIndicator:SetPoint("CENTER", paginationBar, "CENTER", 0, 0)
pageIndicator:SetText("Página 1 de 10")
UI.pageIndicator = pageIndicator

-- Creación del Pool de 5 Columnas de Nivel (Reciclables)
local levelSlots = {}
local SLOT_WIDTH = 136
local SLOT_SPACING = 6

local function CreateRewardCard(parent, isPremium)
    local card = CreateFrame("Frame", nil, parent)
    card:SetWidth(SLOT_WIDTH)
    card:SetHeight(140)

    local cardBg = card:CreateTexture(nil, "BACKGROUND")
    cardBg:SetAllPoints(card)
    if isPremium then
        cardBg:SetTexture(0.12, 0.08, 0.16, 0.85) -- Tono púrpura sutil para VIP
    else
        cardBg:SetTexture(0.08, 0.08, 0.10, 0.85)
    end
    card.bg = cardBg

    -- Borde de la tarjeta
    local cardBorder = card:CreateTexture(nil, "BORDER")
    cardBorder:SetPoint("TOPLEFT", card, "TOPLEFT", 1, -1)
    cardBorder:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -1, 1)
    cardBorder:SetTexture(isPremium and "Interface\\Tooltips\\UI-Tooltip-Border" or "Interface\\Tooltips\\UI-Tooltip-Border")
    cardBorder:SetVertexColor(isPremium and 0.8 or 0.4, isPremium and 0.6 or 0.4, isPremium and 0.2 or 0.4, 0.6)

    -- Etiqueta de Pista (FREE vs VIP)
    local trackBadge = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    trackBadge:SetPoint("TOP", card, "TOP", 0, -6)
    trackBadge:SetText(isPremium and "|cFFFF8000★ VIP ★|r" or "|cFF888888GRATIS|r")

    -- Icono del ítem
    local iconBtn = CreateFrame("Button", nil, card)
    iconBtn:SetWidth(42)
    iconBtn:SetHeight(42)
    iconBtn:SetPoint("CENTER", card, "CENTER", 0, 10)

    local iconTex = iconBtn:CreateTexture(nil, "BACKGROUND")
    iconTex:SetAllPoints(iconBtn)
    iconTex:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    iconTex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    card.iconTex = iconTex

    local iconCount = iconBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    iconCount:SetPoint("BOTTOMRIGHT", iconBtn, "BOTTOMRIGHT", -2, 2)
    card.iconCount = iconCount

    -- Tooltip en el icono
    iconBtn:SetScript("OnEnter", function(self)
        if card.rewardData then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local r = card.rewardData
            if r.itemId and r.itemId > 0 then
                GameTooltip:SetHyperlink("item:" .. r.itemId)
            else
                GameTooltip:AddLine(r.name or "Recompensa", 1, 0.82, 0)
                GameTooltip:AddLine(r.desc or "", 1, 1, 1, true)
            end
            GameTooltip:Show()
        end
    end)
    iconBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Nombre de la recompensa
    local nameText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameText:SetPoint("TOP", iconBtn, "BOTTOM", 0, -4)
    nameText:SetWidth(SLOT_WIDTH - 10)
    nameText:SetHeight(14)
    nameText:SetText("Recompensa")
    card.nameText = nameText

    -- Botón de Acción / Reclamo
    local actionBtn = CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
    actionBtn:SetWidth(SLOT_WIDTH - 16)
    actionBtn:SetHeight(22)
    actionBtn:SetPoint("BOTTOM", card, "BOTTOM", 0, 6)
    actionBtn:SetText(L["CLAIM"])
    card.actionBtn = actionBtn

    return card
end

for i = 1, SLOTS_PER_PAGE do
    local col = CreateFrame("Frame", nil, rewardsContainer)
    col:SetWidth(SLOT_WIDTH)
    col:SetHeight(330)
    col:SetPoint("TOPLEFT", rewardsContainer, "TOPLEFT", (i - 1) * (SLOT_WIDTH + SLOT_SPACING), 0)

    -- Encabezado del Nivel
    local colHeader = col:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    colHeader:SetPoint("TOP", col, "TOP", 0, -2)
    colHeader:SetText("NIVEL " .. i)
    col.header = colHeader

    -- Tarjeta Superior: Vía Gratuita
    local freeCard = CreateRewardCard(col, false)
    freeCard:SetPoint("TOP", col, "TOP", 0, -20)
    col.freeCard = freeCard

    -- Tarjeta Inferior: Vía Premium VIP
    local premCard = CreateRewardCard(col, true)
    premCard:SetPoint("TOP", freeCard, "BOTTOM", 0, -8)
    col.premCard = premCard

    levelSlots[i] = col
end

UI.levelSlots = levelSlots

-- Renderizador de Página Virtual (Reciclaje Eficiente)
function UI:RenderPage(pageNum)
    if not BP.Config.Rewards then return end

    local startLvl = (pageNum - 1) * SLOTS_PER_PAGE + 1
    local endLvl = math.min(startLvl + SLOTS_PER_PAGE - 1, BP.Config.MaxLevel)

    pageIndicator:SetText(string.format(L["PAGE_FORMAT"], pageNum, TOTAL_PAGES, startLvl, endLvl))
    prevBtn:Enable()
    nextBtn:Enable()
    if pageNum <= 1 then prevBtn:Disable() end
    if pageNum >= TOTAL_PAGES then nextBtn:Disable() end

    local currentLvl = BP.Data.level or 1
    local isVip = BP.Data.isPremium or false

    for i = 1, SLOTS_PER_PAGE do
        local lvl = startLvl + (i - 1)
        local slot = levelSlots[i]

        if lvl <= BP.Config.MaxLevel then
            slot:Show()
            local rData = BP.Config.Rewards[lvl]

            -- Estilo del encabezado según si se alcanzó el nivel
            if lvl < currentLvl then
                slot.header:SetText("|cFF00FF00NIVEL " .. lvl .. " ✓|r")
            elseif lvl == currentLvl then
                slot.header:SetText("|cFFFFD100★ NIVEL " .. lvl .. " ★|r")
            else
                slot.header:SetText("|cFF888888Nivel " .. lvl .. "|r")
            end

            -- Actualizar Tarjeta Free
            if rData and rData.free then
                local f = rData.free
                slot.freeCard.rewardData = f
                slot.freeCard.iconTex:SetTexture(f.icon or "Interface\\Icons\\INV_Misc_Gift_01")
                slot.freeCard.iconCount:SetText((f.count and f.count > 1) and ("x" .. f.count) or "")
                slot.freeCard.nameText:SetText(f.name or "Recompensa")

                local isClaimed = BP:IsClaimed("free", lvl)
                if isClaimed then
                    slot.freeCard.actionBtn:Disable()
                    slot.freeCard.actionBtn:SetText("|cFF00FF00Reclamado|r")
                elseif lvl <= currentLvl then
                    slot.freeCard.actionBtn:Enable()
                    slot.freeCard.actionBtn:SetText(L["CLAIM"])
                    slot.freeCard.actionBtn:SetScript("OnClick", function(btn)
                        btn:Disable()
                        btn:SetText("...")
                        BP:ClaimReward(lvl, "free")
                    end)
                else
                    slot.freeCard.actionBtn:Disable()
                    slot.freeCard.actionBtn:SetText(L["LOCKED"])
                end
            end

            -- Actualizar Tarjeta Premium VIP
            if rData and rData.premium then
                local p = rData.premium
                slot.premCard.rewardData = p
                slot.premCard.iconTex:SetTexture(p.icon or "Interface\\Icons\\INV_Misc_Gift_05")
                slot.premCard.iconCount:SetText((p.count and p.count > 1) and ("x" .. p.count) or "")
                slot.premCard.nameText:SetText(p.name or "Recompensa VIP")

                local isClaimed = BP:IsClaimed("premium", lvl)
                if isClaimed then
                    slot.premCard.actionBtn:Disable()
                    slot.premCard.actionBtn:SetText("|cFF00FF00Reclamado|r")
                elseif not isVip then
                    slot.premCard.actionBtn:Disable()
                    slot.premCard.actionBtn:SetText("|cFFFF4444Requiere VIP|r")
                elseif lvl <= currentLvl then
                    slot.premCard.actionBtn:Enable()
                    slot.premCard.actionBtn:SetText(L["CLAIM"])
                    slot.premCard.actionBtn:SetScript("OnClick", function(btn)
                        btn:Disable()
                        btn:SetText("...")
                        BP:ClaimReward(lvl, "premium")
                    end)
                else
                    slot.premCard.actionBtn:Disable()
                    slot.premCard.actionBtn:SetText(L["LOCKED"])
                end
            end
        else
            slot:Hide()
        end
    end
end

-- ========================================================================
-- PESTAÑA 2: MISIONES DE TEMPORADA (DIARIAS Y SEMANALES)
-- ========================================================================
local questCards = {}

local function CreateQuestCard(parent, index)
    local qCard = CreateFrame("Frame", nil, parent)
    qCard:SetWidth(700)
    qCard:SetHeight(48)

    local qBg = qCard:CreateTexture(nil, "BACKGROUND")
    qBg:SetAllPoints(qCard)
    qBg:SetTexture(0.08, 0.08, 0.12, 0.8)
    qCard.bg = qBg

    local qBorder = qCard:CreateTexture(nil, "BORDER")
    qBorder:SetPoint("TOPLEFT", qCard, "TOPLEFT", 0, 0)
    qBorder:SetPoint("BOTTOMRIGHT", qCard, "BOTTOMRIGHT", 0, 0)
    qBorder:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    qBorder:SetVertexColor(0.4, 0.4, 0.5, 0.5)

    -- Icono
    local qIcon = qCard:CreateTexture(nil, "ARTWORK")
    qIcon:SetWidth(32)
    qIcon:SetHeight(32)
    qIcon:SetPoint("LEFT", qCard, "LEFT", 8, 0)
    qIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    qCard.icon = qIcon

    -- Título y Categoría
    local qTitle = qCard:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    qTitle:SetPoint("TOPLEFT", qIcon, "TOPRIGHT", 10, 0)
    qCard.title = qTitle

    -- Descripción
    local qDesc = qCard:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    qDesc:SetPoint("BOTTOMLEFT", qIcon, "BOTTOMRIGHT", 10, 0)
    qCard.desc = qDesc

    -- Recompensa XP
    local qXp = qCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    qXp:SetPoint("RIGHT", qCard, "RIGHT", -120, 0)
    qXp:SetTextColor(0, 1, 0)
    qCard.xp = qXp

    -- Estado / Barra de Progreso
    local qProg = qCard:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    qProg:SetPoint("RIGHT", qCard, "RIGHT", -16, 0)
    qCard.prog = qProg

    return qCard
end

function UI:RenderQuests()
    local dailyList = BP.Config.Quests and BP.Config.Quests.Daily or {}
    local weeklyList = BP.Config.Quests and BP.Config.Quests.Weekly or {}
    local allQuests = {}

    for _, q in ipairs(dailyList) do
        table.insert(allQuests, { data = q, isWeekly = false })
    end
    for _, q in ipairs(weeklyList) do
        table.insert(allQuests, { data = q, isWeekly = true })
    end

    for i, item in ipairs(allQuests) do
        local card = questCards[i]
        if not card then
            card = CreateQuestCard(questsContainer, i)
            questCards[i] = card
        end

        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", questsContainer, "TOPLEFT", 10, -((i - 1) * 54))
        card:Show()

        local q = item.data
        local qState = BP.Data.quests and BP.Data.quests[q.id] or { progress = 0, completed = false }

        card.icon:SetTexture(q.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
        local catTag = item.isWeekly and "|cFF00FFFF[SEMANAL]|r" or "|cFFFFD100[DIARIA]|r"
        card.title:SetText(catTag .. " " .. q.title)
        card.desc:SetText(q.desc)
        card.xp:SetText(string.format(L["QUEST_REWARD_XP"], q.xpReward or 0))

        if qState.completed then
            card.prog:SetText(L["QUEST_STATUS_COMPLETE"])
            card.bg:SetTexture(0.05, 0.15, 0.05, 0.8)
        else
            card.prog:SetText(string.format(L["QUEST_STATUS_PROGRESS"], qState.progress or 0, q.target or 1))
            card.bg:SetTexture(0.08, 0.08, 0.12, 0.8)
        end
    end

    -- Ocultar cards no usadas
    for i = #allQuests + 1, #questCards do
        questCards[i]:Hide()
    end
end

-- ========================================================================
-- PESTAÑA 3: INFORMACIÓN Y BENEFICIOS DEL PASE VIP
-- ========================================================================
local vipBanner = vipContainer:CreateTexture(nil, "BACKGROUND")
vipBanner:SetPoint("TOPLEFT", vipContainer, "TOPLEFT", 10, 0)
vipBanner:SetPoint("BOTTOMRIGHT", vipContainer, "BOTTOMRIGHT", -10, 0)
vipBanner:SetTexture(0.06, 0.04, 0.08, 0.9)

local vipTitle = vipContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
vipTitle:SetPoint("TOPLEFT", vipContainer, "TOPLEFT", 30, -20)
vipTitle:SetText("|cFFFF8000★ " .. L["VIP_TITLE"] .. " ★|r")

local vipStateText = vipContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
vipStateText:SetPoint("TOPLEFT", vipTitle, "BOTTOMLEFT", 0, -10)
UI.vipStateText = vipStateText

local vipDesc = vipContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
vipDesc:SetPoint("TOPLEFT", vipStateText, "BOTTOMLEFT", 0, -15)
vipDesc:SetPoint("RIGHT", vipContainer, "RIGHT", -30, 0)
vipDesc:SetJustifyH("LEFT")
vipDesc:SetText(L["VIP_DESCRIPTION"])

local vipLink = vipContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
vipLink:SetPoint("BOTTOMLEFT", vipContainer, "BOTTOMLEFT", 30, 30)
vipLink:SetText(L["VIP_STORE_LINK"])

function UI:RenderVIP()
    if BP.Data.isPremium then
        vipStateText:SetText("Estado: " .. L["VIP_STATUS_ACTIVE"])
    else
        vipStateText:SetText("Estado: " .. L["VIP_STATUS_INACTIVE"])
    end
end

-- ========================================================================
-- ACTUALIZACIÓN DINÁMICA DE LA INTERFAZ
-- ========================================================================
function UI:Refresh()
    if not mainFrame:IsShown() then return end

    -- Nivel actual
    local curLvl = BP.Data.level or 1
    levelNumber:SetText(tostring(curLvl))

    -- Barra XP
    local curXp = BP.Data.xp or 0
    local reqXp = BP.Config.XPPerLevel or 1000
    xpBar:SetMinMaxValues(0, reqXp)
    xpBar:SetValue(curXp)
    local pct = math.floor((curXp / reqXp) * 100)
    xpText:SetText(string.format(L["XP_FORMAT"], curXp, reqXp, pct))

    -- Distintivo VIP
    if BP.Data.isPremium then
        vipBadge:SetText("|cFF00FF00★ VIP ACTIVO ★|r")
    else
        vipBadge:SetText("|cFFFF4444VIP INACTIVO|r")
    end

    -- Pestaña activa
    if UI.activeTab == 1 then
        UI:RenderPage(UI.currentPage)
    elseif UI.activeTab == 2 then
        UI:RenderQuests()
    elseif UI.activeTab == 3 then
        UI:RenderVIP()
    end
end

function UI:Show()
    UI:AdjustScale()

    -- Al abrir, saltar automáticamente a la página del nivel del jugador
    local curLvl = BP.Data.level or 1
    UI.currentPage = math.min(TOTAL_PAGES, math.floor((curLvl - 1) / SLOTS_PER_PAGE) + 1)

    PlaySoundFile(BP.Config.SoundOpen)
    mainFrame:Show()
    UI:SelectTab(UI.activeTab)
    UI:Refresh()
end

function UI:Hide()
    mainFrame:Hide()
end

function UI:Toggle()
    if mainFrame:IsShown() then
        UI:Hide()
    else
        UI:Show()
    end
end

function UI:ResetPosition()
    mainFrame:ClearAllPoints()
    mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
    WoWPeru_BattlePass_CharDB = WoWPeru_BattlePass_CharDB or {}
    WoWPeru_BattlePass_CharDB.pos = nil
    BP:Print("Posición de la ventana restablecida.")
end

-- Restaurar posición guardada
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:SetScript("OnEvent", function(self)
    if WoWPeru_BattlePass_CharDB and WoWPeru_BattlePass_CharDB.pos then
        local p = WoWPeru_BattlePass_CharDB.pos
        mainFrame:ClearAllPoints()
        mainFrame:SetPoint(p.point or "CENTER", UIParent, p.relPoint or "CENTER", p.x or 0, p.y or 20)
    end
    self:UnregisterAllEvents()
end)
