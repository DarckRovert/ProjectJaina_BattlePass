--[[
    ========================================================================
    Project Jaina - Pase de Batalla (Config.lua)
    Reino: Project Jaina | Servidor: https://darckrovert.github.io/ProjectJaina_Web/
    Cliente Compatible: World of Warcraft 3.3.5a (Build 12340)
    ========================================================================
    Configuración de Temporadas, Niveles (1-50), Recompensas y Misiones.
]]

Jaina_BattlePass = Jaina_BattlePass or {}
local BP = Jaina_BattlePass

BP.Config = {
    -- Información de la Temporada
    SeasonId = 2,
    SeasonName = "Temporada 2: La Forja Andina",
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
                desc = "Participa en 2 arenas 1v1 en el Project Jaina.",
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

        -- Retos de Ecosistema (Temporada 2 — via ProjectJaina_RaidSuite)
        -- Estos IDs (201-210) son reportados automaticamente por EcosystemBridge.lua
        Ecosystem = {
            {
                id = 201,
                title = "Guardian de Banda",
                desc = "Completa 1 estancia de raid con tu banda del Project Jaina usando RaidSuite.",
                icon = "Interface\\Icons\\Achievement_Boss_LichKing",
                target = 1,
                xpReward = 400,
                category = "RAID",
                source = "RaidSuite",  -- Alimentado por EcosystemBridge
            },
            {
                id = 202,
                title = "Mazmorrista del Andino",
                desc = "Completa 3 mazmorras en una semana con el grupo.",
                icon = "Interface\\Icons\\INV_Helmet_08",
                target = 3,
                xpReward = 350,
                category = "PVE",
                source = "RaidSuite",
            },
            {
                id = 203,
                title = "Superviviente Hardcore",
                desc = "Completa 1 raid en modo Hardcore sin morir.",
                icon = "Interface\\Icons\\Spell_Holy_ChampionsGrace",
                target = 1,
                xpReward = 750,
                category = "RAID",
                source = "RaidSuite",
                requireMode = "HARDCORE",  -- Solo para jugadores Hardcore
            },
        },
    },

    -- Generador de Recompensas de Niveles 1 al 50
    -- (Estructura: [nivel] = { free = {...}, premium = {...} })
    Levels = {
        [1] = {
            free = { name = "10x Poción de Maná Rúnica", type = "item", itemId = 33448, count = 10, icon = "Interface\\Icons\\INV_Potion_137", desc = "Restaura 4200 a 4400 p. de maná." },
            premium = { name = "Tabardo de Furia del Sol", type = "item", itemId = 35280, count = 1, icon = "Interface\\Icons\\INV_Shirt_GuildTabard_01", desc = "Tabardo exclusivo de la Temporada 1.", isExclusive = true }
        },
        [2] = {
            free = { name = "50 Monedas de Oro", type = "money", copper = 500000, count = 50, icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Bolsa de fondos para entrenamiento de habilidades." },
            premium = { name = "Bolsa de tejido de escarcha (20 c.)", type = "item", itemId = 41599, count = 1, icon = "Interface\\Icons\\INV_Misc_Bag_19", desc = "Bolsa espaciosa de 20 casillas." }
        },
        [3] = {
            free = { name = "5x Fuego artificial de fiesta", type = "item", itemId = 21713, count = 5, icon = "Interface\\Icons\\INV_Misc_Firework_01", desc = "Fuegos artificiales de celebración." },
            premium = { name = "5x Emblema de Escarcha", type = "item", itemId = 49426, count = 5, icon = "Interface\\Icons\\Spell_Frost_FrozenCore", desc = "Moneda PvE para armaduras Tier 10." }
        },
        [4] = {
            free = { name = "Mochila de viajero (16 c.)", type = "item", itemId = 3914, count = 1, icon = "Interface\\Icons\\INV_Misc_Bag_10_Green", desc = "Espacio adicional para tu inventario." },
            premium = { name = "Mascota: Gatito atigrado", type = "item", itemId = 4401, count = 1, icon = "Interface\\Icons\\INV_Box_PetCarrier_01", desc = "Compañero felino leal que te acompaña.", isExclusive = true }
        },
        [5] = {
            free = { name = "100 Monedas de Oro", type = "money", copper = 1000000, count = 100, icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Recompensa de hito nivel 5." },
            premium = { name = "Tabardo de la Llama", type = "item", itemId = 22999, count = 1, icon = "Interface\\Icons\\INV_Shirt_GuildTabard_01", desc = "Efecto ardiente exclusivo para miembros VIP.", isExclusive = true }
        },
        [6] = {
            free = { name = "20x Festín de pescado", type = "item", itemId = 43015, count = 20, icon = "Interface\\Icons\\INV_Misc_Food_64", desc = "Restaura salud y otorga bonus de ataque y poder con hechizos a tu grupo." },
            premium = { name = "100 Monedas de Oro", type = "money", copper = 1000000, count = 100, icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Oro de temporada para consumibles." }
        },
        [7] = {
            free = { name = "Gema: Rubí ojo de rubí", type = "item", itemId = 37711, count = 1, icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_28", desc = "Gema roja de calidad lista para engarzar." },
            premium = { name = "Gema Épica: Ojo de Zul", type = "item", itemId = 40119, count = 1, icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_39", desc = "Gema verde épica codiciada para ranuras." }
        },
        [8] = {
            free = { name = "10x Poción de velocidad", type = "item", itemId = 33470, count = 10, icon = "Interface\\Icons\\INV_Potion_105", desc = "Aumenta la celeridad temporalmente." },
            premium = { name = "Mascota: Cría de draco albino", type = "item", itemId = 44822, count = 1, icon = "Interface\\Icons\\INV_Misc_Toy_07", desc = "Una cría de dragón mística que vuela junto a ti." }
        },
        [9] = {
            free = { name = "75 Monedas de Oro", type = "money", copper = 750000, count = 75, icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Oro para reparaciones y viajes." },
            premium = { name = "5x Frasco de ira infinita", type = "item", itemId = 46377, count = 5, icon = "Interface\\Icons\\INV_Alchemy_Elixir_02", desc = "Frascos de raid que persisten tras la muerte." }
        },
        [10] = {
            free = { name = "Mascota: Vermis de maná", type = "item", itemId = 39896, count = 1, icon = "Interface\\Icons\\Ability_Hunter_Pet_Owl", desc = "Compañero flotante de energía arcana." },
            premium = { name = "Montura: Oso de batalla negro", type = "item", itemId = 43908, count = 1, icon = "Interface\\Icons\\Ability_Mount_PolarBear_Black", desc = "Montura terrestre acorazada (100% vel).", isExclusive = true }
        },
        [11] = {
            free = { name = "15x Poción de Maná Rúnica", type = "item", itemId = 33448, count = 15, icon = "Interface\\Icons\\INV_Potion_137", desc = "Restaura maná en situaciones de emergencia." },
            premium = { name = "100 Monedas de Oro", type = "money", copper = 1000000, count = 100, icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Bolsa de oro de nivel 11." }
        },
        [12] = {
            free = { name = "Bolsa de tejido de escarcha (20 c.)", type = "item", itemId = 41599, count = 1, icon = "Interface\\Icons\\INV_Misc_Bag_11", desc = "Capacidad óptima de inventario." },
            premium = { name = "Gema Épica: Rubí del Cardenal", type = "item", itemId = 40111, count = 1, icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_37", desc = "La gema roja épica más cotizada de WotLK." }
        },
        [13] = {
            free = { name = "100 Monedas de Oro", type = "money", copper = 1000000, count = 100, icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Oro para profesiones y recetas." },
            premium = { name = "10x Emblema de Triunfo", type = "item", itemId = 47241, count = 10, icon = "Interface\\Icons\\Spell_Holy_SummonChampion", desc = "Moneda PvE para armaduras de nivel 232." }
        },
        [14] = {
            free = { name = "10x Poción de magia salvaje", type = "item", itemId = 40093, count = 10, icon = "Interface\\Icons\\INV_Scroll_02", desc = "Aumenta el poder de hechizo y golpe crítico." },
            premium = { name = "5x Frasco de la vermis de escarcha", type = "item", itemId = 46376, count = 5, icon = "Interface\\Icons\\INV_Alchemy_Elixir_02", desc = "Frascos de raid para hechiceros y sanadores." }
        },
        [15] = {
            free = { name = "5x Emblema de Escarcha", type = "item", itemId = 49426, count = 5, icon = "Interface\\Icons\\Spell_Frost_FrozenCore", desc = "Emblemas para equipo Tier 10." },
            premium = { name = "Mascota Rara: Cría de fénix", type = "item", itemId = 38082, count = 1, icon = "Interface\\Icons\\Spell_Holy_AngelicGlow", desc = "Cría ardiente de fénix exclusiva.", isExclusive = true }
        },
        [16] = {
            free = { name = "20x Poción de Salud Rúnica", type = "item", itemId = 33447, count = 20, icon = "Interface\\Icons\\INV_Potion_131", desc = "Pociones para emergencias en combate." },
            premium = { name = "150 Monedas de Oro", type = "money", copper = 1500000, count = 150, icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Oro de temporada." }
        },
        [17] = {
            free = { name = "Gema Épica: Zafiro majestuoso", type = "item", itemId = 40125, count = 1, icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_30", desc = "Gema azul para resistencia y aguante." },
            premium = { name = "Gema Épica: Ámbar del Rey", type = "item", itemId = 40123, count = 1, icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_41", desc = "Gema amarilla épica para celeridad y crítico." }
        },
        [18] = {
            free = { name = "150 Monedas de Oro", type = "money", copper = 1500000, count = 150, icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Oro para subastas e instrucción." },
            premium = { name = "Bolsa de seda glacial (22 c.)", type = "item", itemId = 41600, count = 1, icon = "Interface\\Icons\\INV_Misc_Bag_25", desc = "Bolsa superior de 22 casillas." }
        },
        [19] = {
            free = { name = "10x Poción de velocidad", type = "item", itemId = 33470, count = 10, icon = "Interface\\Icons\\INV_Potion_108", desc = "Mejora tu índice de velocidad en batalla." },
            premium = { name = "10x Emblema de Escarcha", type = "item", itemId = 49426, count = 10, icon = "Interface\\Icons\\Spell_Shadow_SummonImp", desc = "Emblemas para equipo Tier 10." }
        },
        [20] = {
            free = { name = "200 Monedas de Oro", type = "money", copper = 2000000, count = 200, icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Recompensa de hito nivel 20." },
            premium = { name = "Montura: Lobo de guerra blanco presto", type = "item", itemId = 49284, count = 1, icon = "Interface\\Icons\\Ability_Mount_WhiteDireWolf", desc = "Montura terrestre feroz (100% velocidad).", isExclusive = true }
        },
        [21] = {
            free = { name = "20x Festín de pescado", type = "item", itemId = 43015, count = 20, icon = "Interface\\Icons\\INV_Misc_Fish_52", desc = "Buff de comida para tu hermandad." },
            premium = { name = "10x Emblema de Escarcha", type = "item", itemId = 49426, count = 10, icon = "Interface\\Icons\\Spell_Frost_FrozenCore", desc = "Emblemas para equipo Tier 10." }
        },
        [22] = {
            free = { name = "Gema Épica: Ametrino", type = "item", itemId = 40121, count = 1, icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_38", desc = "Gema naranja híbrida de calidad épica." },
            premium = { name = "Gema Épica: Rubí del Cardenal", type = "item", itemId = 40111, count = 1, icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_37", desc = "Rubí épico rojo listo para engarzar." }
        },
        [23] = {
            free = { name = "150 Monedas de Oro", type = "money", copper = 1500000, count = 150, icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Oro para gemas y encantamientos." },
            premium = { name = "200 Monedas de Oro", type = "money", copper = 2000000, count = 200, icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Oro para la temporada." }
        },
        [24] = {
            free = { name = "15x Poción de Maná Rúnica", type = "item", itemId = 33448, count = 15, icon = "Interface\\Icons\\INV_Potion_137", desc = "Suministros de raid." },
            premium = { name = "Bolsa de seda glacial (22 c.)", type = "item", itemId = 41600, count = 1, icon = "Interface\\Icons\\INV_Misc_Bag_25", desc = "Bolsa espaciosa de 22 casillas." }
        },
        [25] = {
            free = { name = "250 Monedas de Oro", type = "money", copper = 2500000, count = 250, icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Hito de medio camino: 250 monedas de oro." },
            premium = { name = "Montura: Tigre de guerra presto", type = "item", itemId = 49286, count = 1, icon = "Interface\\Icons\\Ability_Mount_JungleTiger", desc = "Montura felina veloz y exclusiva.", isExclusive = true }
        },
        [26] = {
            free = { name = "5x Frasco de ira infinita", type = "item", itemId = 46377, count = 5, icon = "Interface\\Icons\\INV_Alchemy_Elixir_02", desc = "Frascos de poder de ataque para estancias." },
            premium = { name = "10x Emblema de Triunfo", type = "item", itemId = 47241, count = 10, icon = "Interface\\Icons\\Spell_Holy_SummonChampion", desc = "Emblemas para equipo." }
        },
        [27] = {
            free = { name = "Gema Épica: Ojo de noche del terror", type = "item", itemId = 40127, count = 1, icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_40", desc = "Gema morada épica." },
            premium = { name = "Gema Épica: Rubí del Cardenal", type = "item", itemId = 40111, count = 1, icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_37", desc = "Gema roja de máximo poder." }
        },
        [28] = {
            free = { name = "200 Monedas de Oro", type = "money", copper = 2000000, count = 200, icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Oro para tu personaje." },
            premium = { name = "250 Monedas de Oro", type = "money", copper = 2500000, count = 250, icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Bolsa de oro VIP." }
        },
        [29] = {
            free = { name = "20x Poción de Salud Rúnica", type = "item", itemId = 33447, count = 20, icon = "Interface\\Icons\\INV_Potion_131", desc = "Pociones para combates intensos." },
            premium = { name = "10x Frasco de la vermis de escarcha", type = "item", itemId = 46376, count = 10, icon = "Interface\\Icons\\INV_Alchemy_Elixir_02", desc = "Frascos para bandas de 25 jugadores." }
        },
        [30] = {
            free = { name = "10x Emblema de Escarcha", type = "item", itemId = 49426, count = 10, icon = "Interface\\Icons\\Spell_Frost_FrozenCore", desc = "Emblemas para armadura Tier 10." },
            premium = { name = "Mascota: Cachorro de oso de Ventormenta", type = "item", itemId = 44794, count = 1, icon = "Interface\\Icons\\INV_Box_PetCarrier_01", desc = "Cachorro entrañable que te protege.", isExclusive = true }
        },
        [31] = {
            free = { name = "200 Monedas de Oro", type = "money", copper = 2000000, count = 200, icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Fondos de temporada." },
            premium = { name = "250 Monedas de Oro", type = "money", copper = 2500000, count = 250, icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Oro VIP de nivel 31." }
        },
        [32] = {
            free = { name = "Gema Épica: Ámbar del Rey", type = "item", itemId = 40123, count = 1, icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_41", desc = "Gema amarilla épica." },
            premium = { name = "Gema Épica: Ojo de Zul", type = "item", itemId = 40119, count = 1, icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_39", desc = "Gema verde épica." }
        },
        [33] = {
            free = { name = "15x Poción de velocidad", type = "item", itemId = 33470, count = 15, icon = "Interface\\Icons\\INV_Potion_105", desc = "Pociones para maximizar DPS en jefes." },
            premium = { name = "15x Emblema de Triunfo", type = "item", itemId = 47241, count = 15, icon = "Interface\\Icons\\Spell_Holy_SummonChampion", desc = "Emblemas de equipamiento." }
        },
        [34] = {
            free = { name = "Bolsa de seda glacial (22 c.)", type = "item", itemId = 41600, count = 1, icon = "Interface\\Icons\\INV_Misc_Bag_25", desc = "Capacidad máxima para viajeros." },
            premium = { name = "Agujero portátil (24 casillas)", type = "item", itemId = 51809, count = 1, icon = "Interface\\Icons\\INV_Misc_Bag_28", desc = "Bolsa épica de 24 casillas.", isExclusive = true }
        },
        [35] = {
            free = { name = "10x Emblema de Escarcha", type = "item", itemId = 49426, count = 10, icon = "Interface\\Icons\\Spell_Frost_FrozenCore", desc = "Moneda PvE de máximo nivel." },
            premium = { name = "Montura: Mamut de tundra acorazado", type = "item", itemId = 44083, count = 1, icon = "Interface\\Icons\\Ability_Mount_Mammoth_Black", desc = "Mamut titánico con montura de pasajeros.", isExclusive = true }
        },
        [36] = {
            free = { name = "250 Monedas de Oro", type = "money", copper = 2500000, count = 250, icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Oro de hito 36." },
            premium = { name = "300 Monedas de Oro", type = "money", copper = 3000000, count = 300, icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Recompensa dorada." }
        },
        [37] = {
            free = { name = "Gema Épica: Rubí del Cardenal", type = "item", itemId = 40111, count = 1, icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_37", desc = "Rubí épico." },
            premium = { name = "2x Gema Épica: Rubí del Cardenal", type = "item", itemId = 40111, count = 2, icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_37", desc = "Dos rubíes del cardenal épicos." }
        },
        [38] = {
            free = { name = "20x Poción de Maná Rúnica", type = "item", itemId = 33448, count = 20, icon = "Interface\\Icons\\INV_Potion_137", desc = "Consumibles de raid." },
            premium = { name = "10x Frasco de ira infinita", type = "item", itemId = 46377, count = 10, icon = "Interface\\Icons\\INV_Alchemy_Elixir_02", desc = "Frascos para raids heroicas." }
        },
        [39] = {
            free = { name = "10x Poción de magia salvaje", type = "item", itemId = 40093, count = 10, icon = "Interface\\Icons\\INV_Scroll_02", desc = "Poder con hechizos aumentado." },
            premium = { name = "15x Emblema de Escarcha", type = "item", itemId = 49426, count = 15, icon = "Interface\\Icons\\Spell_Frost_FrozenCore", desc = "Emblemas para Tier 10." }
        },
        [40] = {
            free = { name = "300 Monedas de Oro", type = "money", copper = 3000000, count = 300, icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Hito nivel 40 alcanzado." },
            premium = { name = "Montura: Llave meca-jarly (Chopper)", type = "item", itemId = 44413, count = 1, icon = "Interface\\Icons\\Inv_misc_key_06", desc = "Motocicleta chopper con sidecar.", isExclusive = true }
        },
        [41] = {
            free = { name = "20x Festín de pescado", type = "item", itemId = 43015, count = 20, icon = "Interface\\Icons\\INV_Misc_Food_64", desc = "Comida de raid para 25 jugadores." },
            premium = { name = "350 Monedas de Oro", type = "money", copper = 3500000, count = 350, icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Oro de temporada." }
        },
        [42] = {
            free = { name = "Gema Épica: Zafiro majestuoso", type = "item", itemId = 40125, count = 1, icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_30", desc = "Gema azul épica." },
            premium = { name = "Gema Épica: Ámbar del Rey", type = "item", itemId = 40123, count = 1, icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_41", desc = "Gema amarilla épica." }
        },
        [43] = {
            free = { name = "300 Monedas de Oro", type = "money", copper = 3000000, count = 300, icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Oro para la recta final." },
            premium = { name = "15x Emblema de Escarcha", type = "item", itemId = 49426, count = 15, icon = "Interface\\Icons\\Spell_Frost_FrozenCore", desc = "Emblemas de escarcha." }
        },
        [44] = {
            free = { name = "Bolsa de seda glacial (22 c.)", type = "item", itemId = 41600, count = 1, icon = "Interface\\Icons\\INV_Misc_Bag_25", desc = "Bolsa superior de 22 casillas." },
            premium = { name = "Agujero portátil (24 casillas)", type = "item", itemId = 51809, count = 1, icon = "Interface\\Icons\\INV_Misc_Bag_28", desc = "Mochila épica de 24 casillas.", isExclusive = true }
        },
        [45] = {
            free = { name = "15x Emblema de Escarcha", type = "item", itemId = 49426, count = 15, icon = "Interface\\Icons\\Spell_Frost_FrozenCore", desc = "Emblemas para la última pieza de Tier 10." },
            premium = { name = "2x Gema Épica: Rubí del Cardenal", type = "item", itemId = 40111, count = 2, icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_37", desc = "Dos rubíes del cardenal épicos.", isExclusive = true }
        },
        [46] = {
            free = { name = "350 Monedas de Oro", type = "money", copper = 3500000, count = 350, icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Oro para la recta final." },
            premium = { name = "400 Monedas de Oro", type = "money", copper = 4000000, count = 400, icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Recompensa de oro VIP." }
        },
        [47] = {
            free = { name = "Gema Épica: Rubí del Cardenal", type = "item", itemId = 40111, count = 1, icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_37", desc = "Rubí épico." },
            premium = { name = "Gema Épica: Ojo de Zul", type = "item", itemId = 40119, count = 1, icon = "Interface\\Icons\\INV_Jewelcrafting_Gem_39", desc = "Gema verde épica." }
        },
        [48] = {
            free = { name = "400 Monedas de Oro", type = "money", copper = 4000000, count = 400, icon = "Interface\\Icons\\INV_Misc_Coin_01", desc = "Oro de nivel 48." },
            premium = { name = "20x Emblema de Escarcha", type = "item", itemId = 49426, count = 20, icon = "Interface\\Icons\\Spell_Frost_FrozenCore", desc = "Gran lote de emblemas de escarcha." }
        },
        [49] = {
            free = { name = "20x Poción de Maná Rúnica", type = "item", itemId = 33448, count = 20, icon = "Interface\\Icons\\INV_Potion_137", desc = "Último lote de consumibles." },
            premium = { name = "500 Monedas de Oro", type = "money", copper = 5000000, count = 500, icon = "Interface\\Icons\\INV_Misc_Coin_02", desc = "Oro VIP de nivel 49." }
        },
        [50] = {
            free = { name = "25x Emblema de Escarcha", type = "item", itemId = 49426, count = 25, icon = "Interface\\Icons\\Spell_Frost_FrozenCore", desc = "Gran recompensa final gratuita por completar los 50 niveles del Pase.", isExclusive = true },
            premium = { name = "Montura: Cenizas de Al'ar (310% vel.)", type = "item", itemId = 32458, count = 1, icon = "Interface\\Icons\\Ability_Mount_FlightFormCrucible", desc = "El máximo trofeo de la Temporada 1: Fénix llameante con 310% de velocidad voladora.", isExclusive = true }
        },
    }
}

-- Alias de compatibilidad arquitectónica
BP.Config.Rewards = BP.Config.Levels
