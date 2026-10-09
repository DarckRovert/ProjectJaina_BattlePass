-- ========================================================================
-- Project JAIna - Pase de Batalla (battlepass_schema.sql)
-- Reino: Theramore | Servidor: https://darckrovert.github.io/ProjectJaina_Web/
-- Motor Compatible: AzerothCore / TrinityCore con Eluna Lua Engine
-- ========================================================================
-- Importar en la base de datos de 'characters'.

CREATE TABLE IF NOT EXISTS `character_battlepass` (
    `guid` INT UNSIGNED NOT NULL COMMENT 'GUID del personaje',
    `season_id` INT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'ID de la temporada activa',
    `level` INT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Nivel alcanzado (1 al 50)',
    `xp` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Experiencia acumulada en el nivel actual',
    `is_premium` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '1 = Posee Pase VIP, 0 = Gratuito',
    `claimed_free` VARCHAR(16) NOT NULL DEFAULT '0000000000000' COMMENT 'Bitmask hex (13 chars) de recompensas Free reclamadas',
    `claimed_premium` VARCHAR(16) NOT NULL DEFAULT '0000000000000' COMMENT 'Bitmask hex (13 chars) de recompensas VIP reclamadas',
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`guid`, `season_id`),
    KEY `idx_season_level` (`season_id`, `level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Project JAIna - Estado del Pase de Batalla';

CREATE TABLE IF NOT EXISTS `character_battlepass_quests` (
    `guid` INT UNSIGNED NOT NULL COMMENT 'GUID del personaje',
    `quest_id` INT UNSIGNED NOT NULL COMMENT 'ID de la misión diaria o semanal',
    `progress` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Contador de progreso actual',
    `completed` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '1 si la misión fue completada, 0 si está pendiente',
    `reset_time` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Timestamp UNIX del próximo reseteo',
    PRIMARY KEY (`guid`, `quest_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='WoW Perú - Progreso de Misiones del Pase';
