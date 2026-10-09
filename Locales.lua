--[[
    ========================================================================
    Project Jaina - Pase de Batalla (Locales.lua)
    Reino: Project Jaina | Servidor: Portal Oficial de Project Jaina
    Cliente Compatible: World of Warcraft 3.3.5a (Build 12340)
    ========================================================================
    Localización en Español (esES/esMX) con fallback automático a Inglés.
]]

Jaina_BattlePass = Jaina_BattlePass or {}
local BP = Jaina_BattlePass

local L = {}

-- ========================================================================
-- IDIOMA POR DEFECTO: ESPAÑOL (Project Jaina)
-- ========================================================================
L["TITLE"] = "Pase de Batalla"
L["SUBTITLE"] = "Project Jaina - Temporada 2"
L["HEADER_SEASON"] = "Temporada 2: La Forja Andina"
L["DAYS_REMAINING"] = "%d días restantes"
L["LEVEL_FORMAT"] = "Nivel %d"
L["MAX_LEVEL_REACHED"] = "¡Nivel Máximo!"
L["XP_FORMAT"] = "%d / %d XP (%d%%)"
L["XP_TOTAL_FORMAT"] = "%d XP Total"

-- Pestañas
L["TAB_REWARDS"] = "Recompensas"
L["TAB_QUESTS"] = "Misiones"
L["TAB_VIP"] = "Pase VIP"

-- Pistas de Recompensas
L["TRACK_FREE"] = "Vía Gratuita"
L["TRACK_PREMIUM"] = "Vía Premium (VIP)"
L["CLAIM"] = "Reclamar"
L["CLAIMED"] = "Reclamado"
L["LOCKED"] = "Bloqueado"
L["REQUIRES_VIP"] = "Requiere VIP"
L["PAGE_FORMAT"] = "Página %d de %d (Niveles %d - %d)"
L["PREV_PAGE"] = "Anterior"
L["NEXT_PAGE"] = "Siguiente"

-- Misiones
L["QUESTS_DAILY_TITLE"] = "Misiones Diarias (Reseteo 04:00 AM)"
L["QUESTS_WEEKLY_TITLE"] = "Misiones Semanales (Reseteo Miércoles)"
L["QUEST_REWARD_XP"] = "+%d XP"
L["QUEST_STATUS_COMPLETE"] = "|cFF00FF00¡Completada!|r"
L["QUEST_STATUS_PROGRESS"] = "%d / %d"
L["NO_QUESTS_AVAILABLE"] = "No hay misiones disponibles en este momento."

-- Pase VIP
L["VIP_TITLE"] = "Beneficios del Pase Premium VIP"
L["VIP_STATUS_ACTIVE"] = "|cFF00FF00ACTIVO|r - Tienes acceso a todas las recompensas Premium."
L["VIP_STATUS_INACTIVE"] = "|cFFFF4444INACTIVO|r - Desbloquea el Pase VIP en la tienda web."
L["VIP_DESCRIPTION"] = "El Pase VIP te otorga acceso inmediato al carril inferior de recompensas en todos los 50 niveles:\n\n• Monturas exclusivas de temporada no obtenibles por otros medios.\n• Auras visuales y efectos épicos para tu personaje.\n• Ilusiones de armas y transformaciones únicas.\n• 100% de recompensas acumuladas: si compras el VIP en nivel 30, ¡desbloquearás al instante las recompensas VIP de los niveles 1 al 30!\n\nVisita nuestra página web oficial para adquirirlo y apoyar el crecimiento de Project Jaina."
L["VIP_STORE_LINK"] = "Visita: |cFFD4AF37Portal Oficial de Project Jaina|r"

-- Tooltip de Minimapa
L["MINIMAP_TOOLTIP_TITLE"] = "|cFFD4AF37Project Jaina|r - Pase de Batalla"
L["MINIMAP_TOOLTIP_DESC"] = "Haz clic izquierdo para abrir/cerrar la ventana.\nHaz clic derecho y arrastra para mover el botón."
L["MINIMAP_TOOLTIP_LEVEL"] = "Nivel del Pase: |cFFFFD100%d|r"
L["MINIMAP_TOOLTIP_XP"] = "Progreso XP: |cFFFFFFFF%d / %d (%d%%)|r"
L["MINIMAP_TOOLTIP_VIP"] = "Estado VIP: %s"
L["MINIMAP_TOOLTIP_DAILY"] = "Misiones de Hoy: |cFFFFD100%d / %d|r"

-- Notificaciones del Sistema en Chat
L["MSG_LEVEL_UP"] = "¡Felicidades! Has alcanzado el |cFF00FF00Nivel %d|r. ¡Revisa tus recompensas!"
L["MSG_CLAIM_SUCCESS"] = "Has reclamado la recompensa del Nivel %d (%s)."
L["MSG_CLAIM_MAIL"] = "Tus bolsas estaban llenas. La recompensa fue enviada a tu buzón de correo."
L["MSG_VIP_UNLOCKED"] = "¡Pase VIP activado! Todas las recompensas exclusivas están desbloqueadas."
L["MSG_QUEST_PROGRESS"] = "Misión: %s (%d/%d) (+%d XP)"
L["MSG_QUEST_COMPLETE"] = "¡Misión completada: %s! Ganaste %d XP."
L["MSG_COMMAND_HELP"] = "|cFFD4AF37Comandos del Pase de Batalla:|r\n  /bp o /pase - Abre o cierra la ventana principal.\n  /bp claim <nivel> [free|premium] - Reclama la recompensa del nivel indicado.\n  /bp sync - Sincroniza datos con el servidor.\n  /bp minimap - Muestra u oculta el botón del minimapa.\n  /bp reset - Restaura la posición de la ventana."

-- Idioma Inglés (Fallback)
local locale = GetLocale()
if locale ~= "esES" and locale ~= "esMX" then
    L["TITLE"] = "Battle Pass"
    L["SUBTITLE"] = "Project Jaina - Season 2"
    L["HEADER_SEASON"] = "Season 2: The Andean Forge"
    L["DAYS_REMAINING"] = "%d days remaining"
    L["LEVEL_FORMAT"] = "Level %d"
    L["MAX_LEVEL_REACHED"] = "Max Level Reached!"
    L["XP_FORMAT"] = "%d / %d XP (%d%%)"
    L["XP_TOTAL_FORMAT"] = "%d Total XP"
    L["TAB_REWARDS"] = "Rewards"
    L["TAB_QUESTS"] = "Quests"
    L["TAB_VIP"] = "VIP Pass"
    L["TRACK_FREE"] = "Free Track"
    L["TRACK_PREMIUM"] = "Premium Track (VIP)"
    L["CLAIM"] = "Claim"
    L["CLAIMED"] = "Claimed"
    L["LOCKED"] = "Locked"
    L["REQUIRES_VIP"] = "Requires VIP"
    L["PAGE_FORMAT"] = "Page %d of %d (Levels %d - %d)"
    L["PREV_PAGE"] = "Previous"
    L["NEXT_PAGE"] = "Next"
    L["QUESTS_DAILY_TITLE"] = "Daily Quests (Reset 04:00 AM)"
    L["QUESTS_WEEKLY_TITLE"] = "Weekly Quests (Reset Wednesday)"
    L["QUEST_REWARD_XP"] = "+%d XP"
    L["QUEST_STATUS_COMPLETE"] = "|cFF00FF00Completed!|r"
    L["QUEST_STATUS_PROGRESS"] = "%d / %d"
    L["NO_QUESTS_AVAILABLE"] = "No quests available at this moment."
    L["VIP_TITLE"] = "Premium VIP Pass Benefits"
    L["VIP_STATUS_ACTIVE"] = "|cFF00FF00ACTIVE|r - You have full access to all Premium rewards."
    L["VIP_STATUS_INACTIVE"] = "|cFFFF4444INACTIVE|r - Unlock your VIP Pass on our web store."
    L["VIP_DESCRIPTION"] = "The VIP Pass unlocks instant access to the lower reward track across all 50 levels:\n\n• Exclusive seasonal mounts not obtainable through other means.\n• Visual auras and epic character effects.\n• Unique weapon illusions and transformations.\n• 100% retroactive rewards: buy at level 30 and instantly unlock VIP rewards for levels 1 to 30!\n\nVisit our official website to acquire it and support Project Jaina."
    L["VIP_STORE_LINK"] = "Visit: |cFFD4AF37Portal Oficial de Project Jaina|r"
    L["MINIMAP_TOOLTIP_TITLE"] = "|cFFD4AF37Project Jaina|r - Battle Pass"
    L["MINIMAP_TOOLTIP_DESC"] = "Left click to toggle window.\nRight click and drag to move icon."
    L["MINIMAP_TOOLTIP_LEVEL"] = "Battle Pass Level: |cFFFFD100%d|r"
    L["MINIMAP_TOOLTIP_XP"] = "XP Progress: |cFFFFFFFF%d / %d (%d%%)|r"
    L["MINIMAP_TOOLTIP_VIP"] = "VIP Status: %s"
    L["MINIMAP_TOOLTIP_DAILY"] = "Today's Quests: |cFFFFD100%d / %d|r"
    L["MSG_LEVEL_UP"] = "Congratulations! You reached |cFF00FF00Level %d|r. Check your rewards!"
    L["MSG_CLAIM_SUCCESS"] = "You claimed Level %d reward (%s)."
    L["MSG_CLAIM_MAIL"] = "Bags full. Reward sent to your in-game mailbox."
    L["MSG_VIP_UNLOCKED"] = "VIP Pass active! All exclusive rewards unlocked."
    L["MSG_QUEST_PROGRESS"] = "Quest: %s (%d/%d) (+%d XP)"
    L["MSG_QUEST_COMPLETE"] = "Quest complete: %s! Gained %d XP."
    L["MSG_COMMAND_HELP"] = "|cFFD4AF37Battle Pass Commands:|r\n  /bp or /pase - Open or close the main window.\n  /bp claim <level> [free|premium] - Claim reward for the specified level.\n  /bp sync - Sync data with the server.\n  /bp minimap - Show or hide minimap button.\n  /bp reset - Reset window position."
end

BP.L = L
