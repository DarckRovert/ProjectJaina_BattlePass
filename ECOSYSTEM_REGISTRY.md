# 🌐 Registro de Ecosistema — WoWPeru_BattlePass

Ficha técnica oficial de registro en la infraestructura multi-addon de **WoW Perú - Reino Andino**.

---

## 1. Identidad del Addon en el Ecosistema

| Campo | Valor |
|---|---|
| **Nombre Técnico** | `WoWPeru_BattlePass` |
| **Carpeta Local** | `WoWPeru_BattlePass` |
| **Versión Actual** | `2.0.0` |
| **Clasificación** | Cliente / Gameplay |
| **Licencia Formal** | MIT |
| **Repositorio GitHub** | [WoWPeru_BattlePass](https://github.com/DarckRovert/WoWPeru_BattlePass) |
| **Entorno de Juego** | World of Warcraft 3.3.5a (Build 12340) / AzerothCore |

---

## 2. Registro de Tablas de Base de Datos MySQL (`characters`)

Todo sistema que persista datos en la base de datos `characters` debe respetar este registro para evitar duplicidades de nombres o conflictos en eliminaciones de personajes:

### 2.1. Tablas Activas

| Tabla MySQL | Sistema Propietario | Clave Primaria / Índices | Propósito | Limpieza en Delete (`PLAYER_EVENT_ON_CHARACTER_DELETE`) |
| :--- | :--- | :--- | :--- | :--- |
| **`character_battlepass`** | `WoWPeru_BattlePass` | `guid` (INT UNSIGNED, PK) | Almacena nivel actual, XP, estado VIP (0/1), y máscaras de bits hexadecimales de recompensas reclamadas (`free_claims`, `premium_claims`). | **Obligatoria** (Previene herencia indebida de recompensas en LowGUID reciclado). |
| **`character_battlepass_quests`** | `WoWPeru_BattlePass` | `(guid, quest_id)` (Composite PK) | Almacena el progreso de objetivos (`progress`), estado de completado (`completed`) y timestamp del último reinicio (`last_reset`). | **Obligatoria** (Eliminación en cascada por `guid`). |
| **`character_gamemodes`** | `WoWPeru_GameModes` | `guid` (INT UNSIGNED, PK) | Almacena el modo seleccionado (Normal, Hardcore, Desafíos), vidas restantes y marcas de tiempo de activación. | **Obligatoria**. |
| **`character_visuals`** | `WowPeruVisualShop` | `(guid, visual_id)` (Composite PK) | Almacena los efectos visuales, auras y cosméticos adquiridos por el personaje. | **Obligatoria**. |

---

## 3. Registro de Rangos de IDs de DBC y Spells Custom

Para evitar sobrescribir hechizos de Blizzard o de otros packs de la comunidad (ej. títulos custom o auras existentes), se reservan los siguientes rangos en `Spell.dbc` y `Item.dbc`:

```
┌───────────────────────────┬─────────────────────────────────────────────────────────────┐
│ Rango de IDs              │ Asignación / Propietario                                    │
├───────────────────────────┼─────────────────────────────────────────────────────────────┤
│ 10000 - 55000 (Items)     │ DBC Oficial Blizzard 3.3.5a (Recompensas BattlePass)        │
│ 940001 - 940049 (Spells)  │ Pack de 49 Títulos Custom (Inti / Core)                     │
│ 941001 - 941999 (Spells)  │ Auras Combinadas de Efectos Visuales (`WowPeruVisualShop`)  │
│ 942001 - 942999 (Spells)  │ Auras de Forma / Druida / Shapeshift (`WowPeruVisualShop`)  │
│ 943001 - 943018 (Spells)  │ Auras y Modelos de Alas Visuales (`WowPeruVisualShop`)      │
└───────────────────────────┴─────────────────────────────────────────────────────────────┘
```

> **Nota Crítica de Arquitectura:** El rango `943001-943018` fue migrado formalmente desde `940001-940018` para evitar la colisión con los títulos custom del servidor. Todo nuevo hechizo cosmético debe asignarse a partir de `944000`.

---

## 4. Convención de Carga de Scripts Eluna en Servidor (`lua/active/`)

El motor Eluna en TrinityCore y AzerothCore ejecuta los scripts en orden lexicográfico. Los números de prefijo garantizan que las dependencias, utilitarios y tablas maestras se inicialicen antes de los sistemas de juego:

```
lua/active/
├── 01_CoreUtils.lua                 -- Wrappers de logging, helpers globales
├── 10_DatabaseInit.lua               -- Creación condicional de esquemas
├── 59_SpellVisualCatalog.lua        -- Catálogo maestro de visuales (idéntico a Catalog.lua)
├── 70_BattlePassSystem.lua          -- Motor del Pase de Batalla estacional
└── 71_GameModesSystem.lua           -- Motor de Modos de Juego (Hardcore, Desafíos)
```

---

## 5. Distribución de Cliente y Parche MPQ

El servidor distribuye las modificaciones cliente a través de dos mecanismos:

1. **Parche Oficial MPQ (`Data/patch-Z-WOWPERU.MPQ`):**
   - Contiene los archivos embebidos que no deben ser eliminados por el usuario.
   - Embebe `WoWPeru_GameModes`, `WowPeruVisualShop`, texturas personalizadas e iconos `.tga`.
2. **Carpeta de Addons (`Interface/AddOns/`):**
   - Módulos actualizables independientemente: `WoWPeru_BattlePass`, `WoWPeru_RaidSuite`.
   - Distribución directa o empaquetada mediante releases oficiales en GitHub.

---

## 6. Procedimiento de Integración de Nuevos Sistemas

Cuando se planifique crear un nuevo sistema para WoW Perú:
1. **Asignación de Prefijo:** Registrar el nuevo prefijo de red en la Sección 1 de este documento.
2. **Definición de Base de Datos:** Documentar las nuevas tablas en la Sección 2.
3. **Reserva de Spells/Items:** Confirmar que no exista colisión con los rangos de la Sección 3.
4. **Prioridad Eluna:** Asignar un número de orden en `lua/active/` respetando la Sección 4.
5. **Verificación de Empirismo:** Comprobar compatibilidad con WotLK 3.3.5a y el presupuesto de 255 bytes.

---

## 🏛️ Directorio Maestro del Ecosistema WoW Perú (17 Repositorios)

### A. Módulos Oficiales del Cliente (`Client\Interface\AddOns\`)

| # | Repositorio GitHub | Carpeta Local | Versión | Tipo / Licencia | Propósito en el Ecosistema |
|:---:|---|---|:---:|:---:|---|
| 01 | [WoWPeru_AbbreviatedStatus](https://github.com/DarckRovert/WoWPeru_AbbreviatedStatus) | `AbbreviatedStatus` | 1.2.1 | MIT / Fork | Abreviación compacta y formateo legible de salud y maná sin división por cero. |
| 02 | [WoWPeru_BattlePass](https://github.com/DarckRovert/WoWPeru_BattlePass) | `WoWPeru_BattlePass` | 2.0.0 | MIT | Pase de Batalla estacional de 50 niveles con backend Eluna y bitmask de progreso. |
| 03 | [WoWPeru_Carbonite](https://github.com/DarckRovert/WoWPeru_Carbonite) | `WoWPeru_Carbonite` | 3.3.4-WP | Other / EULA | Suite satelital HD de cartografía, navegación multi-zona y misiones. |
| 04 | [WoWPeru_Companion](https://github.com/DarckRovert/WoWPeru_Companion) | `WoWPeru_Companion` | 1.0.3 | MIT | Hub social ligero, cross-faction (/comerciar, /invitar) y telemetría de grupo. |
| 05 | [WoWPeru_DragonflightUI](https://github.com/DarckRovert/WoWPeru_DragonflightUI) | `cDF` | 1.0.0 | MIT / BSD | Re-implementación visual moderna estilo Dragonflight 10.x para cliente 3.3.5a. |
| 06 | [WoWPeru_GameModes](https://github.com/DarckRovert/WoWPeru_GameModes) | `WoWPeru_GameModes` | 1.0.0 | MIT | Selector cinemático de modos (Normal, Hardcore, Ironman) con verificación Eluna. |
| 07 | [WoWPeru_GMGenie](https://github.com/DarckRovert/WoWPeru_GMGenie) | `GMGenie` | 1.3.1 | GPL-3.0 | Suite administrativa integral para Game Masters adaptada a AzerothCore. |
| 08 | [WoWPeru_IntiObjGPS](https://github.com/DarckRovert/WoWPeru_IntiObjGPS) | `IntiObjGPS` | 1.0.0 | MIT | Editor por lotes de coordenadas GPS de GameObjects para Staff y constructores. |
| 09 | [WoWPeru_LoreHUD](https://github.com/DarckRovert/WoWPeru_LoreHUD) | `LoreHUD` | 1.0.0 | MIT | Subtítulos cinemáticos inmersivos y telemetría narrativa para LoreBots. |
| 10 | [WoWPeru_PrideTrace](https://github.com/DarckRovert/WoWPeru_PrideTrace) | `WowPeruPrideTrace` | 1.0.0 | MIT | Diagnóstico de latencia de input, framerate y telemetría en vuelo. |
| 11 | [WoWPeru_RaidSuite](https://github.com/DarckRovert/WoWPeru_RaidSuite) | `WoWPeru_RaidSuite` | 11.2.1 | MIT / Comm. | Asistente de combate y combate táctico multiclase evolucionado de Sequito. |
| 12 | [WoWPeru_Talented](https://github.com/DarckRovert/WoWPeru_Talented) | `Talented` | 2.4.8 | GPL-2.0 / BSD | Editor integral de árboles de talentos, calculadoras de mascotas y glifos. |
| 13 | [WoWPeru_TBCBalance](https://github.com/DarckRovert/WoWPeru_TBCBalance) | `IntiTBCBalance` | 1.0.0 | MIT | Monitor privado de balance y composición de bandas TBC para Game Masters. |
| 14 | [WoWPeru_Wardrobe](https://github.com/DarckRovert/WoWPeru_Wardrobe) | `WoWPeru_Wardrobe` | 1.0.0 | MIT | Guardarropa, catálogo cosmético y transfiguración con backend Eluna (60_WardrobeSystem.lua). |
| 15 | [WowPeruVisualShop](https://github.com/DarckRovert/WowPeruVisualShop) | `WowPeruVisualShop` | 1.0.1 | MIT | Tienda oficial de efectos visuales, auras y alas con backend Eluna (59_SpellVisualCatalog.lua). |

### B. Suites Comunitarias Monorepositorio Pre-instaladas (`WoW_Peru_Lab\AddOns\`)

| # | Repositorio GitHub | Carpeta Local | Versión | Tipo / Licencia | Propósito en el Ecosistema |
|:---:|---|---|:---:|:---:|---|
| 16 | [WoWPeru_DBM](https://github.com/DarckRovert/WoWPeru_DBM) | `WoWPeru_DBM` | 4.52-WP | CC BY-NC-SA 3.0 | Suite unificada de 13 módulos Deadly Boss Mods para todas las raids y mazmorras WotLK. |
| 17 | [WoWPeru_GearScore](https://github.com/DarckRovert/WoWPeru_GearScore) | `WoWPeru_GearScore` | 3.1.16-WP | MIT / Comm. | Monorepositorio unificado de GearScore (3.1.16) y BonusScanner (5.3) sin dependencias rotas. |

---

## 📜 Principios de Gobernanza y Convivencia Arquitectónica

1. **Inmunidad a Taint:** Prohibido modificar o enganchar `UnitPopupMenus` de Blizzard para garantizar la estabilidad de menús contextuales y addons de curación (`HealBot`, `Grid`).
2. **Empirismo y Cero Suposiciones:** Todo cambio de protocolo o base de datos debe ser validado con inspección en disco y pruebas de red activas.
3. **Codificación Canónica:** Todo archivo de texto debe persistirse en **UTF-8 sin BOM** con saltos de línea estrictos **LF**.
4. **Preservación de Binarios:** Todos los assets multimedia (`.tga`, `.blp`, `.mp3`, `.ogg`, `.wav`, `.ttf`, `.m2`) se encuentran blindados mediante `.gitattributes` para evitar corrupción en transferencias Git.

