# 🌐 Registro Maestro del Ecosistema Técnico - WoW Perú

**Versión del Registro:** 1.0.0  
**Fecha de Actualización:** 27 de Septiembre de 2026  
**Líder Técnico / Arquitecto:** DarckRovert (Ingame: `Elnazzareno`)  
**Servidor Destino:** [WoW Perú](https://wow-peru.lat/) - Reino Andino  
**Entorno:** WotLK 3.3.5a (Build 12340) | TrinityCore / AzerothCore con Eluna Lua Engine  

---

## 1. Registro de Prefijos de Red (`SendAddonMessage`)

Para evitar colisiones entre sistemas, cada módulo tiene un prefijo reservado exclusivo. Queda estrictamente prohibido utilizar un prefijo registrado por otro módulo:

| Prefijo Reservado | Módulo Propietario | Tipo de Canal | OpCodes Principales | Formato de Carga | Longitud Máx. |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`WP_BP`** | `WoWPeru_BattlePass` | `"WHISPER"` | `BP_REQ_SYNC`<br>`BP_CLAIM:<lvl>:<track>`<br>`BP_RES_SYNC:...`<br>`BP_RES_CLAIM:...`<br>`BP_RES_XP:...`<br>`BP_RES_QUEST:...` | Delimitado por dos puntos (`:`). Máscara de bits hexadecimal para niveles. | 255 bytes (Límite estricto 3.3.5a) |
| **`WP_GAMEMODE`** | `WoWPeru_GameModes` | `"WHISPER"` | `SET_MODE:<ID>`<br>`GM_RES_STATUS:...` | Delimitado por dos puntos (`:`). | 255 bytes |
| **`WP_VISUAL`** | `WowPeruVisualShop` | `"WHISPER"` | `REQ_CATALOG`<br>`BUY_VISUAL:<id>`<br>`EQUIP_VISUAL:<id>` | IDs numéricos estables indexados a `Catalog.lua`. | 255 bytes |
| **`SEQUITO`** | `SEQUITO` | Canales de Raid/Party/Guild | Prefijos modulares internos (`RSYNC`, `ALERTHUB`, `VOTE`) | Serialización compacta AceSerializer / Custom. | 255 bytes |

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
   - Módulos actualizables independientemente: `WoWPeru_BattlePass`, `SEQUITO`.
   - Distribución directa o empaquetada mediante releases oficiales en GitHub.

---

## 6. Procedimiento de Integración de Nuevos Sistemas

Cuando se planifique crear un nuevo sistema para WoW Perú:
1. **Asignación de Prefijo:** Registrar el nuevo prefijo de red en la Sección 1 de este documento.
2. **Definición de Base de Datos:** Documentar las nuevas tablas en la Sección 2.
3. **Reserva de Spells/Items:** Confirmar que no exista colisión con los rangos de la Sección 3.
4. **Prioridad Eluna:** Asignar un número de orden en `lua/active/` respetando la Sección 4.
5. **Verificación de Empirismo:** Comprobar compatibilidad con WotLK 3.3.5a y el presupuesto de 255 bytes.
