# 🛡️ Guía Técnica de Integración para el Staff: Project Jaina Battle Pass (v1.0.0)

> **Servidor Destino:** [Project Jaina](https://darckrovert.github.io/ProjectJaina_Web/) - Project Jaina  
> **Motor Compatible:** AzerothCore o TrinityCore con **Eluna Lua Engine**  
> **Cliente:** World of Warcraft 3.3.5a (Build 12340)

---

## 1. Visión General de la Arquitectura

El sistema de Pase de Batalla de Project Jaina consta de tres capas desacopladas:
1. **Frontend (Addon Cliente):** `Jaina_BattlePass` embebido en el MPQ del cliente o distribuido en `Interface/AddOns/`.
2. **Backend (Script Eluna):** `70_BattlePassSystem.lua` ejecutado en el emulador del servidor.
3. **Persistencia (MySQL):** Tablas `character_battlepass` y `character_battlepass_quests` en la base de datos `characters`.

```
[Cliente 3.3.5a] <─── SendAddonMessage ("WP_BP") ───> [Eluna (Core)] <───> [MySQL `characters`]
```

---

## 2. Instalación en el Servidor (Paso a Paso)

### Paso A: Base de Datos MySQL
1. Abre tu gestor de base de datos (HeidiSQL, Navicat, DBeaver o consola MySQL).
2. Selecciona la base de datos de personajes (`characters`).
3. Ejecuta el archivo [battlepass_schema.sql](Server/battlepass_schema.sql):

```sql
SOURCE Server/battlepass_schema.sql;
```

Esto creará automáticamente las tablas `character_battlepass` y `character_battlepass_quests` con sus índices optimizados.

### Paso B: Instalación del Script Eluna
1. Copia el archivo [70_BattlePassSystem.lua](Server/70_BattlePassSystem.lua) en la carpeta de scripts de Eluna en tu servidor:
   * **Ruta habitual:** `bin/lua_scripts/active/` o `lua/active/`
2. Si el servidor está encendido, ejecuta en la consola del core o como GM:
   ```
   .reload eluna
   ```
3. Verifica en la consola que no haya errores de sintaxis.

---

## 3. Embebido del Addon en el Cliente de Juego

Para que los jugadores disfruten del Pase de Batalla sin necesidad de configuraciones manuales:

### Método Recomendado: Inyección en MPQ Oficial
1. Abre tu herramienta de edición de MPQs (ej. **MPQEditor**).
2. Abre el archivo de parches del servidor: `Data/patch-Z-Project Jaina.MPQ`.
3. Navega hasta:
   ```
   Interface\AddOns\ProjectJaina_BattlePass\
   ```
4. Añade todos los archivos del addon:
   * `Jaina_BattlePass.toc`
   * `Config.lua`
   * `Locales.lua`
   * `Core.lua`
   * `MinimapButton.lua`
   * `UI.lua`
5. Guarda y compacta el archivo MPQ.
6. Distribúyelo mediante el actualizador / launcher oficial de Project Jaina.

---

## 4. Comandos de Administración In-Game (.bp)

El script de servidor incluye comandos para Game Masters (Rango GM $\ge 2$):

| Comando | Función | Ejemplo |
|---|---|---|
| `.bp sync` | Fuerza la sincronización del pase del jugador que lo ejecuta. | `.bp sync` |
| `.bp vip <Nombre> <1\|0>` | Activa (1) o revoca (0) el Pase VIP a un jugador. | `.bp vip Darck 1` |
| `.bp addxp <Nombre> <Cantidad>` | Otorga puntos de XP del Pase de Batalla al jugador. | `.bp addxp Darck 500` |

---

## 5. Integración con la Tienda Web de Donaciones

Cuando un jugador adquiere el Pase VIP en la página web ([projectjaina.com](https://darckrovert.github.io/ProjectJaina_Web/)):

### Opción 1: Inyección Directa en Base de Datos (Recomendada)
El backend web (PHP/Node/Python) ejecuta la siguiente consulta en la base de datos `characters`:

```sql
INSERT INTO character_battlepass (guid, season_id, level, xp, is_premium, claimed_free, claimed_premium)
SELECT guid, 1, 1, 0, 1, '0000000000000', '0000000000000' 
FROM characters 
WHERE name = 'NOMBRE_PERSONAJE'
ON DUPLICATE KEY UPDATE is_premium = 1;
```

> **Nota de Resiliencia:** Este query utiliza `UPSERT`. Si el jugador nunca antes ha logueado en la Temporada 1, crea su fila directamente con VIP activado (`is_premium = 1`). Si ya existía, únicamente actualiza su estado VIP preservando su nivel y recompensas. Si el jugador está conectado, al reloguear o al ejecutar `.bp sync` / hacer clic derecho en el botón de minimapa, su Pase VIP se activará de inmediato.

### Opción 2: Despacho por Soap / RA Console
Si tu tienda web cuenta con conexión SOAP o Remote Access a la consola de AzerothCore/TrinityCore:
```
.bp vip NOMBRE_PERSONAJE 1
```

---

## 6. Personalización de Recompensas y Temporadas

* **Cambio de Temporada:**
  En [Config.lua](Config.lua) del cliente y en [70_BattlePassSystem.lua](Server/70_BattlePassSystem.lua) del servidor, incrementa `SeasonId = 2`.
* **Modificación de Recompensas:**
  Edita la tabla `REWARDS` en `Server/70_BattlePassSystem.lua` y `BP.Config.Rewards` en `Config.lua`. Ambas tablas deben mantener consistencia en los IDs de ítems.
