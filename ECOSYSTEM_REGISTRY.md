# 🌐 Registro de Ecosistema — Jaina_BattlePass

Ficha técnica oficial de registro en la infraestructura multi-addon de **Project Jaina - Project Jaina**.

---

## 1. Identidad del Addon en el Ecosistema

| Campo | Valor |
|---|---|
| **Nombre Técnico** | `Jaina_BattlePass` |
| **Carpeta Local** | `Jaina_BattlePass` |
| **Versión Actual** | `2.0.0` |
| **Clasificación** | Cliente / Gameplay |
| **Licencia Formal** | MIT |
| **Repositorio GitHub** | [Jaina_BattlePass](https://github.com/DarckRovert/Jaina_BattlePass) |
| **Entorno de Juego** | World of Warcraft 3.3.5a (Build 12340) / AzerothCore |

---

## 2. Registro de Tablas de Base de Datos MySQL (`characters`)

Todo sistema que persista datos en la base de datos `characters` debe respetar este registro para evitar duplicidades de nombres o conflictos en eliminaciones de personajes:

### 2.1. Tablas Activas

| Tabla MySQL | Sistema Propietario | Clave Primaria / Índices | Propósito | Limpieza en Delete (`PLAYER_EVENT_ON_CHARACTER_DELETE`) |
| :--- | :--- | :--- | :--- | :--- |
| **`character_battlepass`** | `Jaina_BattlePass` | `guid` (INT UNSIGNED, PK) | Almacena nivel actual, XP, estado VIP (0/1), y máscaras de bits hexadecimales de recompensas reclamadas (`free_claims`, `premium_claims`). | **Obligatoria** (Previene herencia indebida de recompensas en LowGUID reciclado). |
| **`character_battlepass_quests`** | `Jaina_BattlePass` | `(guid, quest_id)` (Composite PK) | Almacena el progreso de objetivos (`progress`), estado de completado (`completed`) y timestamp del último reinicio (`last_reset`). | **Obligatoria** (Eliminación en cascada por `guid`). |
| **`character_gamemodes`** | `ProjectJaina_GameModes` | `guid` (INT UNSIGNED, PK) | Almacena el modo seleccionado (Normal, Hardcore, Desafíos), vidas restantes y marcas de tiempo de activación. | **Obligatoria**. |
| **`character_visuals`** | `Project JainaVisualShop` | `(guid, visual_id)` (Composite PK) | Almacena los efectos visuales, auras y cosméticos adquiridos por el personaje. | **Obligatoria**. |

---

## 3. Registro de Rangos de IDs de DBC y Spells Custom

Para evitar sobrescribir hechizos de Blizzard o de otros packs de la comunidad (ej. títulos custom o auras existentes), se reservan los siguientes rangos en `Spell.dbc` y `Item.dbc`:

```
┌───────────────────────────┬─────────────────────────────────────────────────────────────┐
│ Rango de IDs              │ Asignación / Propietario                                    │
├───────────────────────────┼─────────────────────────────────────────────────────────────┤
│ 10000 - 55000 (Items)     │ DBC Oficial Blizzard 3.3.5a (Recompensas BattlePass)        │
│ 940001 - 940049 (Spells)  │ Pack de 49 Títulos Custom (Inti / Core)                     │
│ 941001 - 941999 (Spells)  │ Auras Combinadas de Efectos Visuales (`Project JainaVisualShop`)  │
│ 942001 - 942999 (Spells)  │ Auras de Forma / Druida / Shapeshift (`Project JainaVisualShop`)  │
│ 943001 - 943018 (Spells)  │ Auras y Modelos de Alas Visuales (`Project JainaVisualShop`)      │
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

1. **Parche Oficial MPQ (`Data/patch-Z-Project Jaina.MPQ`):**
   - Contiene los archivos embebidos que no deben ser eliminados por el usuario.
   - Embebe `ProjectJaina_GameModes`, `Project JainaVisualShop`, texturas personalizadas e iconos `.tga`.
2. **Carpeta de Addons (`Interface/AddOns/`):**
   - Módulos actualizables independientemente: `Jaina_BattlePass`, `ProjectJaina_RaidSuite`.
   - Distribución directa o empaquetada mediante releases oficiales en GitHub.

---

## 6. Procedimiento de Integración de Nuevos Sistemas

Cuando se planifique crear un nuevo sistema para Project Jaina:
1. **Asignación de Prefijo:** Registrar el nuevo prefijo de red en la Sección 1 de este documento.
2. **Definición de Base de Datos:** Documentar las nuevas tablas en la Sección 2.
3. **Reserva de Spells/Items:** Confirmar que no exista colisión con los rangos de la Sección 3.
4. **Prioridad Eluna:** Asignar un número de orden en `lua/active/` respetando la Sección 4.
5. **Verificación de Empirismo:** Comprobar compatibilidad con WotLK 3.3.5a y el presupuesto de 255 bytes.

---

## 🏛️ Directorio Maestro del Ecosistema Project Jaina (18 Repositorios)

### A. Módulos Oficiales del Cliente (`Client\Interface\AddOns\`)

| # | Repositorio GitHub | Carpeta Local | Versión | Tipo / Licencia | Propósito en el Ecosistema |
|:---:|---|---|:---:|:---:|---|
| 01 | [ProjectJaina_AbbreviatedStatus](https://github.com/DarckRovert/ProjectJaina_AbbreviatedStatus) | `AbbreviatedStatus` | 1.2.1 | MIT / Fork | Abreviación compacta y formateo legible de salud y maná sin división por cero. |
| 02 | [Jaina_BattlePass](https://github.com/DarckRovert/Jaina_BattlePass) | `Jaina_BattlePass` | 2.0.0 | MIT | Pase de Batalla estacional de 50 niveles con backend Eluna y bitmask de progreso. |
| 03 | [ProjectJaina_Carbonite](https://github.com/DarckRovert/ProjectJaina_Carbonite) | `ProjectJaina_Carbonite` | 3.3.4-WP | Other / EULA | Suite satelital HD de cartografía, navegación multi-zona y misiones. |
| 04 | [ProjectJaina_Companion](https://github.com/DarckRovert/ProjectJaina_Companion) | `ProjectJaina_Companion` | 1.0.3 | MIT | Hub social ligero, cross-faction (/comerciar, /invitar) y telemetría de grupo. |
| 05 | [ProjectJaina_DragonflightUI](https://github.com/DarckRovert/ProjectJaina_DragonflightUI) | `cDF` | 1.0.0 | MIT / BSD | Re-implementación visual moderna estilo Dragonflight 10.x para cliente 3.3.5a. |
| 06 | [ProjectJaina_GameModes](https://github.com/DarckRovert/ProjectJaina_GameModes) | `ProjectJaina_GameModes` | 1.0.0 | MIT | Selector cinemático de modos (Normal, Hardcore, Ironman) con verificación Eluna. |
| 07 | [ProjectJaina_GMGenie](https://github.com/DarckRovert/ProjectJaina_GMGenie) | `GMGenie` | 1.3.1 | GPL-3.0 | Suite administrativa integral para Game Masters adaptada a AzerothCore. |
| 08 | [ProjectJaina_ProjectJaina_IntiObjGPS](https://github.com/DarckRovert/ProjectJaina_ProjectJaina_IntiObjGPS) | `ProjectJaina_IntiObjGPS` | 1.0.0 | MIT | Editor por lotes de coordenadas GPS de GameObjects para Staff y constructores. |
| 09 | [ProjectJaina_LoreHUD](https://github.com/DarckRovert/ProjectJaina_LoreHUD) | `LoreHUD` | 1.0.0 | MIT | Diálogos cinemáticos inmersivos y subtítulos estilizados para misiones y Lore. |
| 10 | [ProjectJaina_PrideTrace](https://github.com/DarckRovert/ProjectJaina_PrideTrace) | `Project JainaPrideTrace` | 1.0.0 | MIT | Rastreador de combate y telemetría de eventos de orgullo en tiempo real. |
| 11 | [ProjectJaina_RaidSuite](https://github.com/DarckRovert/ProjectJaina_RaidSuite) | `ProjectJaina_RaidSuite` | 1.0.0 | MIT | Suite modular de herramientas analíticas para líderes de banda y oficiales. |
| 12 | [ProjectJaina_Talented](https://github.com/DarckRovert/ProjectJaina_Talented) | `Talented` | 3.3.5-WP | GPL-2.0 | Árbol de talentos avanzado con soporte para plantillas y compartición. |
| 13 | [ProjectJaina_TBCBalance](https://github.com/DarckRovert/ProjectJaina_TBCBalance) | `ProjectJaina_TBCBalance` | 1.0.0 | MIT | Monitor privado de balance y composición de bandas TBC para Game Masters. |
| 14 | [ProjectJaina_Wardrobe](https://github.com/DarckRovert/ProjectJaina_Wardrobe) | `ProjectJaina_Wardrobe` | 1.0.0 | MIT | Guardarropa, catálogo cosmético y transfiguración con backend Eluna (60_WardrobeSystem.lua). |
| 15 | [Project JainaVisualShop](https://github.com/DarckRovert/Project JainaVisualShop) | `Project JainaVisualShop` | 1.0.1 | MIT | Tienda oficial de efectos visuales, auras y alas con backend Eluna (59_SpellVisualCatalog.lua). |
| 16 | [ProjectJaina_Voice](https://github.com/DarckRovert/ProjectJaina_Voice) | `ProjectJaina_Voice` | 1.0.0 | MIT | Voz espacial 3D por proximidad y vinculación WebRTC con backend Eluna (65_VoiceProximitySync.lua). |

### B. Suites Comunitarias Monorepositorio Pre-instaladas (`WoW_Peru_Lab\AddOns\`)

| # | Repositorio GitHub | Carpeta Local | Versión | Tipo / Licencia | Propósito en el Ecosistema |
|:---:|---|---|:---:|:---:|---|
| 17 | [ProjectJaina_DBM](https://github.com/DarckRovert/ProjectJaina_DBM) | `ProjectJaina_DBM` | 4.52-WP | CC BY-NC-SA 3.0 | Suite unificada de 13 módulos Deadly Boss Mods para todas las raids y mazmorras WotLK. |
| 18 | [ProjectJaina_GearScore](https://github.com/DarckRovert/ProjectJaina_GearScore) | `ProjectJaina_GearScore` | 3.1.16-WP | MIT / Comm. | Monorepositorio unificado de GearScore (3.1.16) y BonusScanner (5.3) sin dependencias rotas. |

---

## 📜 Principios de Gobernanza y Convivencia Arquitectónica

1. **Inmunidad a Taint:** Prohibido modificar o enganchar `UnitPopupMenus` de Blizzard para garantizar la estabilidad de menús contextuales y addons de curación (`HealBot`, `Grid`).
2. **Empirismo y Cero Suposiciones:** Todo cambio de protocolo o base de datos debe ser validado con inspección en disco y pruebas de red activas.
3. **Codificación Canónica:** Todo archivo de texto debe persistirse en **UTF-8 sin BOM** con saltos de línea estrictos **LF**.
4. **Preservación de Binarios:** Todos los assets multimedia (`.tga`, `.blp`, `.mp3`, `.ogg`, `.wav`, `.ttf`, `.m2`) se encuentran blindados mediante `.gitattributes` para evitar corrupción en transferencias Git.
