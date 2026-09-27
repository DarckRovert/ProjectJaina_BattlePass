--[[
    ========================================================================
    WoW Perú - Pase de Batalla (Config.lua)
    Reino: Reino Andino | Servidor: https://wow-peru.lat/
    Cliente Compatible: World of Warcraft 3.3.5a (Build 12340)
    ========================================================================
    Configuración de Temporadas, Niveles (1-50), Recompensas y Misiones.
]]

WoWPeru_BattlePass = WoWPeru_BattlePass or {}
local BP = WoWPeru_BattlePass

BP.Config = {
    -- Información de la Temporada
    SeasonId = 1,
    SeasonName = "Temporada 1: El Despertar Andino",
    SeasonDaysTotal = 60,
    XPPerLevel = 1000,
    MaxLevel = 50,

    -- Comunicación de Red
    AddonPrefix = "WP_BP",
    Command = ".bp",
    Debug = false,

    -- Sonidos de interfaz
    SoundOpen = "Sound\\Interface\\iQuestLogOpen.wav",
    SoundLevelUp = "Sound\\Interface\\LevelUp.wav",
    SoundClaim = "Sound\\Interface\\LootCoinSmall.wav",

    -- Catálogo de Misiones Diarias y Semanales
    Quests = {
        -- Misiones Diarias (Reseteo a las 04:00 AM)
        Daily = {
            {
                id = 1,
                title = "Mazmorra Diaria",
                desc = "Completa 1 mazmorra aleatoria con tu grupo.",
                icon = "Interface\\Icons\\INV_Helmet_08",
                target = 1,
                xpReward = 250,
                category = "PVE",
            },
            {
                id = 2,
                title = "Gloria en Batalla",
                desc = "Gana 1 Campo de Batalla (CFBG).",
                icon = "Interface\\Icons\\INV_BannerPVP_02",
                target = 1,
                xpReward = 300,
                category = "PVP",
            },
            {
                id = 3,
                title = "Duelo de Titanes",
                desc = "Participa en 2 arenas 1v1 en el Reino Andino.",
                icon = "Interface\\Icons\\Ability_Warrior_ChallengingShout",
                target = 2,
                xpReward = 200,
                category = "PVP",
            },
            {
                id = 4,
                title = "Cazador de Monstruos",
                desc = "Derrota a 25 criaturas de tu nivel o superior.",
                icon = "Interface\\Icons\\Ability_Hunter_Snipershot",
                target = 25,
                xpReward = 150,
                category = "MUNDO",
            },
            {
                id = 5,
                title = "Artesano Andino",
                desc = "Fabrica 5 objetos de profesión o recolecta 10 recursos.",
                icon = "Interface\\Icons\\Trade_BlackSmithing",
                target = 5,
                xpReward = 150,
                category = "PROFESION",
            },
        },

        -- Retos Semanales (Mayor valor de XP)
        Weekly = {
            {
                id = 101,
                title = "Azote de Bandas",
                desc = "Derrota a 3 jefes de estancia de banda.",
                icon = "Interface\\Icons\\Achievement_Boss_LichKing",
                target = 3,
                xpReward = 650,
                category = "RAID",
            },
            {
                id = 102,
                title = "Héroe del Reino",
                desc = "Completa 15 misiones de cualquier zona de Azeroth.",
                icon = "Interface\\Icons\\INV_Misc_Book_07",
                target = 15,
                xpReward = 500,
                category = "MISIONES",
            },
            {
                id = 103,
                title = "Veterano de Guerra",
                desc = "Consigue 40 muertes con honor en campos de batalla o mundo.",
                icon = "Interface\\Icons\\Spell_Holy_ChampionsGrace",
                target = 40,
                xpReward = 550,
                category = "PVP",
            },
        },
    },

    -- Generador de Recompensas de Niveles 1 al 50
    -- (Estructura: [nivel] = { free = {...}, premium = {...} })
    Levels = {
        [1] = {
            free = { name = "10x Poción de Maná/Vida", icon = "Interface\\Icons\\INV_Potion_131", desc = "Consumibles útiles para tu viaje.", count = 10 },
            premium = { name = "Tabardo del Protector Andino", icon = "Interface\\Icons\\INV_Shirt_GuildTabard_01", desc = "Tabardo exclusivo de la Temporada 1.", count = 1, isExclusive = true }
        },
        [2] = {
            free = { name = "50 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Bolsa con fondos para entrenar habilidades.", count = 50 },
            premium = { name = "Bolsa de Seda de Ébano (20 casillas)", icon = "Interface\\Icons\\INV_Misc_Bag_19", desc = "Bolsa espaciosa de alta capacidad.", count = 1 }
        },
        [3] = {
            free = { name = "5x Fuego artificial de celebración", icon = "Interface\\Icons\\INV_Misc_Firework_01", desc = "Fuegos artificiales para festejar.", count = 5 },
            premium = { name = "5x Emblema de Escarcha", icon = "Interface\\Icons\\Spell_Frost_FrozenCore", desc = "Moneda de equipamiento para PvE avanzado.", count = 5 }
        },
        [4] = {
            free = { name = "Bolsa de Cuero (14 casillas)", icon = "Interface\\Icons\\INV_Misc_Bag_10_Green", desc = "Espacio adicional para tu inventario.", count = 1 },
            premium = { name = "Mascota: Cachorro Andino", icon = "Interface\\Icons\\Ability_Hunter_Pet_Wolf", desc = "Compañero leal que te sigue a donde vayas.", count = 1, isExclusive = true }
        },
        [5] = { -- HITO 5
            free = { name = "100 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Recompensa de hito nivel 5.", count = 100 },
            premium = { name = "Ilusión Visual: Llamas del Reino", icon = "Interface\\Icons\\Spell_Fire_Immolation", desc = "Efecto de fuego ardiente para tus armas.", count = 1, isExclusive = true }
        },
        [6] = {
            free = { name = "20x Comida de Festín", icon = "Interface\\Icons\\INV_Misc_Food_64", desc = "Restaura salud y maná con estadísticas extra.", count = 20 },
            premium = { name = "100 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Oro para consumibles de raid.", count = 100 }
        },
        [7] = {
            free = { name = "Gema Rara: Rubí escarlata", icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_28", desc = "Gema roja lista para engarzar.", count = 1 },
            premium = { name = "Gema Épica: Ojo de Zul", icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_39", desc = "Gema verde de calidad épica.", count = 1 }
        },
        [8] = {
            free = { name = "5x Elixir de velocidad", icon = "Interface\\Icons\\INV_Potion_105", desc = "Aumenta la velocidad de movimiento.", count = 5 },
            premium = { name = "Mascota: Minipet Mecánico", icon = "Interface\\Icons\\INV_Misc_Toy_07", desc = "Un divertido autómata de ingeniería.", count = 1 }
        },
        [9] = {
            free = { name = "75 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Oro para reparaciones.", count = 75 },
            premium = { name = "10x Frasco de la Ira Helada", icon = "Interface\\Icons\\INV_Alchemy_Elixir_02", desc = "Frascos de raid que persisten tras la muerte.", count = 10 }
        },
        [10] = { -- HITO 10
            free = { name = "Mascota: Halcón del Altiplano", icon = "Interface\\Icons\\Ability_Hunter_Pet_Owl", desc = "Compañero ave rapaz.", count = 1 },
            premium = { name = "Montura Terrestre: Sable de Obsidiana", icon = "Interface\\Icons\\Ability_Mount_BlackPanther", desc = "Montura felina veloz (100% velocidad).", count = 1, isExclusive = true }
        },
        [11] = {
            free = { name = "15x Poción de Maná Rúnica", icon = "Interface\\Icons\\INV_Potion_137", desc = "Restaura gran cantidad de maná.", count = 15 },
            premium = { name = "100 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Bolsa de oro de nivel 11.", count = 100 }
        },
        [12] = {
            free = { name = "Bolsa de 16 casillas", icon = "Interface\\Icons\\INV_Misc_Bag_11", desc = "Capacidad básica de inventario.", count = 1 },
            premium = { name = "Gema Épica: Rubí del Cardenal", icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_37", desc = "La gema roja épica más cotizada.", count = 1 }
        },
        [13] = {
            free = { name = "100 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Oro para profesiones.", count = 100 },
            premium = { name = "10x Emblema de Triunfo", icon = "Interface\\Icons\\Spell_Holy_SummonChampion", desc = "Moneda PvE para armaduras de nivel 232.", count = 10 }
        },
        [14] = {
            free = { name = "5x Pergamino de Agilidad/Fuerza", icon = "Interface\\Icons\\INV_Scroll_02", desc = "Buff temporal para combate.", count = 5 },
            premium = { name = "Transformación: Disfraz de Titán", icon = "Interface\\Icons\\Spell_Magic_LesserInvisibilty", desc = "Te transforma en un avatar de piedra.", count = 1 }
        },
        [15] = { -- HITO 15
            free = { name = "Título: 'El Caminante'", icon = "Interface\\Icons\\INV_Misc_Note_01", desc = "Título permanente visible sobre tu nombre.", count = 1 },
            premium = { name = "Aura Visual: Alas Espirituales", icon = "Interface\\Icons\\Spell_Holy_AngelicGlow", desc = "Efecto cosmético permanente para tu personaje.", count = 1, isExclusive = true }
        },
        [16] = {
            free = { name = "20x Poción de Salud Rúnica", icon = "Interface\\Icons\\INV_Potion_131", desc = "Pociones para emergencias en combate.", count = 20 },
            premium = { name = "150 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Oro de temporada.", count = 150 }
        },
        [17] = {
            free = { name = "Gema Rara: Zafiro celestial", icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_30", desc = "Gema azul para resistencia y aguante.", count = 1 },
            premium = { name = "Gema Épica: Ámbar del Rey", icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_41", desc = "Gema amarilla épica.", count = 1 }
        },
        [18] = {
            free = { name = "150 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Oro para subastas.", count = 150 },
            premium = { name = "Bolsa de 22 casillas: Tejido de Hielo", icon = "Interface\\Icons\\INV_Misc_Bag_25", desc = "Bolsa superior de tela de escarcha.", count = 1 }
        },
        [19] = {
            free = { name = "5x Elixir de Puntería", icon = "Interface\\Icons\\INV_Potion_108", desc = "Mejora tu índice de golpe.", count = 5 },
            premium = { name = "Mascota: Diablillo Nevado", icon = "Interface\\Icons\\Spell_Shadow_SummonImp", desc = "Criatura invocada que te acompaña.", count = 1 }
        },
        [20] = { -- HITO 20
            free = { name = "200 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Recompensa de hito nivel 20.", count = 200 },
            premium = { name = "Montura Terrestre: Oso Blindado Andino", icon = "Interface\\Icons\\Ability_Mount_PolarBear_Black", desc = "Oso de batalla con armadura ceremonial.", count = 1, isExclusive = true }
        },
        [21] = {
            free = { name = "10x Comida de Pescado del Norte", icon = "Interface\\Icons\\INV_Misc_Fish_52", desc = "Buff para todo tu grupo de raid.", count = 10 },
            premium = { name = "10x Emblema de Escarcha", icon = "Interface\\Icons\\Spell_Frost_FrozenCore", desc = "Emblemas para equipo Tier 10.", count = 10 }
        },
        [22] = {
            free = { name = "Gema Rara: Topacio monarca", icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_31", desc = "Gema naranja para celeridad y golpe.", count = 1 },
            premium = { name = "200 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Oro de recompensa.", count = 200 }
        },
        [23] = {
            free = { name = "250 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Oro para gemas y encantamientos.", count = 250 },
            premium = { name = "Ilusión Visual: Rayo Estelar", icon = "Interface\\Icons\\Spell_Arcane_StarFire", desc = "Partículas de magia arcana en tus armas.", count = 1 }
        },
        [24] = {
            free = { name = "Bolsa de 18 casillas", icon = "Interface\\Icons\\INV_Misc_Bag_14", desc = "Ampliación de espacio de mochila.", count = 1 },
            premium = { name = "Mascota: Dragontino Celeste", icon = "Interface\\Icons\\INV_Misc_Head_Dragon_01", desc = "Cría de dragón azul.", count = 1 }
        },
        [25] = { -- HITO 25 (Mitad de Temporada)
            free = { name = "Mascota: Cría de Raptor Feroz", icon = "Interface\\Icons\\Ability_Mount_Raptor", desc = "Compañero reptil rápido.", count = 1 },
            premium = { name = "Montura Voladora: Protodraco Escarlata", icon = "Interface\\Icons\\Ability_Mount_RedProtoDrake", desc = "Majestuosa montura voladora (280% vel.).", count = 1, isExclusive = true }
        },
        [26] = {
            free = { name = "25x Poción de Maná Rúnica", icon = "Interface\\Icons\\INV_Potion_137", desc = "Lote de maná para raid.", count = 25 },
            premium = { name = "Gema Épica: Ametrino", icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_40", desc = "Gema naranja épica.", count = 1 }
        },
        [27] = {
            free = { name = "Gema Rara: Ópalo crepuscular", icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_32", desc = "Gema púrpura para ranuras mixtas.", count = 1 },
            premium = { name = "250 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Oro para equipo.", count = 250 }
        },
        [28] = {
            free = { name = "300 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Oro para subastas.", count = 300 },
            premium = { name = "15x Emblema de Escarcha", icon = "Interface\\Icons\\Spell_Frost_FrozenCore", desc = "Fondo de emblemas de alta gama.", count = 15 }
        },
        [29] = {
            free = { name = "10x Frasco de Poder Puro", icon = "Interface\\Icons\\INV_Alchemy_Elixir_04", desc = "Frascos para daño con hechizos y sanación.", count = 10 },
            premium = { name = "Bolsa Portátil de 24 casillas", icon = "Interface\\Icons\\INV_Misc_Bag_28", desc = "Bolsa gigante para coleccionistas.", count = 1 }
        },
        [30] = { -- HITO 30
            free = { name = "Título: 'El Explorador Andino'", icon = "Interface\\Icons\\INV_Misc_Map02", desc = "Título de veterano del reino.", count = 1 },
            premium = { name = "Aura Visual: Corona Astral", icon = "Interface\\Icons\\Spell_Holy_HolyGuidance", desc = "Halo de luz sagrada que corona a tu héroe.", count = 1, isExclusive = true }
        },
        [31] = {
            free = { name = "350 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Oro de nivel 31.", count = 350 },
            premium = { name = "300 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Oro de bonificación.", count = 300 }
        },
        [32] = {
            free = { name = "10x Pergamino de Protección", icon = "Interface\\Icons\\INV_Scroll_05", desc = "Aumento de armadura para tanques.", count = 10 },
            premium = { name = "Gema Épica: Piedra de Terror", icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_38", desc = "Gema púrpura épica.", count = 1 }
        },
        [33] = {
            free = { name = "400 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Oro para encantamientos.", count = 400 },
            premium = { name = "Mascota: Cría de Fénix Ígneo", icon = "Interface\\Icons\\Spell_Fire_SoulBurn", desc = "Fénix en miniatura que emite chispas.", count = 1 }
        },
        [34] = {
            free = { name = "2x Gema Rara a elección", icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_28", desc = "Bolsa de gemas raras.", count = 2 },
            premium = { name = "350 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Oro para el personaje.", count = 350 }
        },
        [35] = { -- HITO 35
            free = { name = "500 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Gran fondo de oro.", count = 500 },
            premium = { name = "Montura Terrestre: Mamut de Asedio", icon = "Interface\\Icons\\Ability_Mount_Mammoth_Black", desc = "Enorme mamut de batalla blindado.", count = 1, isExclusive = true }
        },
        [36] = {
            free = { name = "15x Frascos a elección", icon = "Interface\\Icons\\INV_Alchemy_Elixir_01", desc = "Suministros de raid completos.", count = 15 },
            premium = { name = "20x Emblema de Escarcha", icon = "Interface\\Icons\\Spell_Frost_FrozenCore", desc = "Emblemas para piezas Tier 10 santificadas.", count = 20 }
        },
        [37] = {
            free = { name = "550 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Oro de nivel 37.", count = 550 },
            premium = { name = "Gema Meta: Diamante de Asedio", icon = "Interface\\Icons\\INV_Jewelcrafting_Shadowspirit_02", desc = "Gema meta para el casco.", count = 1 }
        },
        [38] = {
            free = { name = "Gema Rara: Rubí escarlata x2", icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_28", desc = "Gemas rojas de fuerza/poder con hechizos.", count = 2 },
            premium = { name = "400 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Oro de alto nivel.", count = 400 }
        },
        [39] = {
            free = { name = "600 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Oro para profesiones secundarias.", count = 600 },
            premium = { name = "Ilusión Visual: Alma en Pena", icon = "Interface\\Icons\\Spell_Shadow_Haunting", desc = "Vapores de sombras espectrales en armas.", count = 1 }
        },
        [40] = { -- HITO 40
            free = { name = "Mascota: Cría de Dracohalcón Solar", icon = "Interface\\Icons\\Ability_Mount_DragonHawk", desc = "Exótico compañero volador.", count = 1 },
            premium = { name = "Montura Voladora: Draco Crepuscular", icon = "Interface\\Icons\\Ability_Mount_TwilightDrake", desc = "Draco de piel oscura y ojos violetas (280%).", count = 1, isExclusive = true }
        },
        [41] = {
            free = { name = "700 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Oro para el banco de hermandad.", count = 700 },
            premium = { name = "500 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Bolsa de oro pesado.", count = 500 }
        },
        [42] = {
            free = { name = "20x Poción de Magia Salvaje", icon = "Interface\\Icons\\INV_Potion_109", desc = "Aumento masivo de golpe crítico para casters.", count = 20 },
            premium = { name = "Gema Épica: Ojo de Zul x2", icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_39", desc = "Dos gemas épicas verdes.", count = 2 }
        },
        [43] = {
            free = { name = "800 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Oro de nivel 43.", count = 800 },
            premium = { name = "25x Emblema de Escarcha", icon = "Interface\\Icons\\Spell_Frost_FrozenCore", desc = "Lote grande de emblemas.", count = 25 }
        },
        [44] = {
            free = { name = "Bolsa de 20 casillas", icon = "Interface\\Icons\\INV_Misc_Bag_19", desc = "Bolsa de tela de escarcha.", count = 1 },
            premium = { name = "Mascota: Espectro de Hielo", icon = "Interface\\Icons\\Spell_Frost_FrostArmor", desc = "Elemental de hielo miniatura.", count = 1 }
        },
        [45] = { -- HITO 45
            free = { name = "1000 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Recompensa de hito nivel 45.", count = 1000 },
            premium = { name = "Aura Visual: Alas de la Muerte", icon = "Interface\\Icons\\Spell_Fire_FelfireSpellBurn", desc = "Alas llameantes de destrucción pura.", count = 1, isExclusive = true }
        },
        [46] = {
            free = { name = "1200 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Oro de nivel 46.", count = 1200 },
            premium = { name = "750 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Oro para consumibles.", count = 750 }
        },
        [47] = {
            free = { name = "3x Gema Rara a elección", icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_37", desc = "Lote de gemas raras.", count = 3 },
            premium = { name = "Gema Épica: Rubí del Cardenal x2", icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_37", desc = "Dos gemas rojas épicas.", count = 2 }
        },
        [48] = {
            free = { name = "1500 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Oro para montura voladora experta.", count = 1500 },
            premium = { name = "Bolsa de 28 casillas: Alforja de Titán", icon = "Interface\\Icons\\INV_Misc_Bag_30", desc = "La bolsa de mayor capacidad del juego.", count = 1 }
        },
        [49] = {
            free = { name = "2000 Monedas de Oro", icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Premio de ante-último nivel.", count = 2000 },
            premium = { name = "Título Épico: 'El Conquistador de los Andes'", icon = "Interface\\Icons\\Achievement_Zone_Northrend_01", desc = "Título legendario exclusivo de Temporada 1.", count = 1, isExclusive = true }
        },
        [50] = { -- NIVEL FINAL (GRAN PREMIO)
            free = {
                name = "Montura Terrestre: Lobo del Viento Glacial",
                icon = "Interface\\Icons\\Ability_Mount_BlackDireWolf",
                desc = "Montura de lobo ártico acorazado para todos los que completen el pase.",
                count = 1,
                isExclusive = true
            },
            premium = {
                name = "Montura Legendaria: Fénix de Fuego Celestial (310% vel.)",
                icon = "Interface\\Icons\\Ability_Mount_FlightFormCrucible",
                desc = "El máximo trofeo de la Temporada 1: Fénix llameante con 310% de velocidad voladora.",
                count = 1,
                isExclusive = true
            }
        },
    }
}
