# 📋 Registro de Cambios (Changelog) - Project Jaina Battle Pass

Todos los cambios notables en este proyecto se documentarán en este archivo.
El formato se basa en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/) y este proyecto se adhiere a [Semantic Versioning](https://semver.org/lang/es/).

---

## [2.0.0] - 2026-09-28

### 🎉 Temporada 2: La Forja Andina

### ✨ Nuevas Funcionalidades
- **Season 2 activa:** `SeasonId = 2`, nombre "Temporada 2: La Forja Andina", 60 días de duración.
- **Misiones del Ecosistema (IDs 201-203):** Integración con `ProjectJaina_RaidSuite` via `EcosystemBridge.lua`:
  - `201` — **Guardián de Banda** (1 raid con el grupo, +400 XP)
  - `202` — **Mazmorrista del Andino** (3 mazmorras semanales, +350 XP)
  - `203` — **Superviviente Hardcore** (1 raid sin morir en modo Hardcore, +750 XP)
- **Handler `BP_QUEST_PROGRESS`:** El servidor Eluna procesa los paquetes del cliente enviados por `EcosystemBridge.lua` de manera idempotente y con persistencia MySQL directa.
- **`ACTIVE_QUEST_IDS`** ampliado a `{ 1, 2, 3, 4, 5, 101, 102, 103, 201, 202, 203 }`.

---

## [1.0.0] - 2026-09-27

### 🎉 Lanzamiento Oficial - Temporada 1: Project Jaina

Primera versión de producción del sistema de Pase de Batalla de Project Jaina, diseñada para clientes 3.3.5a (Build 12340) y servidores TrinityCore/AzerothCore con motor Eluna.

### ✨ Nuevas Funcionalidades
- **Sistema de Progresión de 50 Niveles:** Vía Gratuita y Vía Premium (VIP) completas con recompensas balanceadas (oro, pociones, gemas, bolsas, emblemas de triunfo/escarcha, mascotas, monturas y títulos).
- **Carrusel Virtual de 5 Ranuras:** Renderizado de alto rendimiento en [UI.lua](UI.lua) mediante un pool virtual reciclable en memoria, garantizando 60 FPS estables en PCs de cabinas de internet ($800\times600$ a $4\text{K}$).
- **Protocolo Hexadecimal Bitmask:** Sincronización atómica de los 50 niveles en 13 caracteres hexadecimales (`3FFFFFFFFFFFF`), inmune al límite estricto de 255 bytes por paquete de `SendAddonMessage`.
- **Caja de Enlace VIP Interactiva:** Widget `EditBox` con auto-selección (`HighlightText()`) para copiar el enlace de donación de [projectjaina.com](https://darckrovert.github.io/ProjectJaina_Web/) sin fricción en el cliente 3.3.5a.
- **Botón de Minimapa Reactivo:** Blasón dorado con órbita circular suave y tooltip en tiempo real con estadísticas de nivel, porcentaje y misiones diarias.
- **Misiones Diarias y Semanales:** Motor de misiones con reinicio determinista a las 04:00 AM (diario) y miércoles 04:00 AM (semanal).
- **Comandos de Administración `.bp`:** Herramientas para Game Masters (`.bp addxp`, `.bp setlevel`, `.bp setvip`, `.bp resetquests`, `.bp reload`).

### 🛡️ Endurecimiento de Seguridad y Auditoría Técnica (57 Correcciones)
- **Watchdogs y Fugas de Memoria:** Cancelación explícita de temporizadores `OnUpdate` (`btn:SetScript("OnUpdate", nil)`) al reciclar botones o cambiar de página, previniendo condiciones de carrera por clausuras zombis.
- **Polimorfismo de Red en Eluna:** Soporte simultáneo para firmas de 5 parámetros `(event, player, type, prefix, message)` y 6 parámetros `(event, player, type, prefix, message, target)` en `OnServerAddonMessage`.
- **Filtro de Grupo en Muertes:** Validación de miembros vivos en grupo `(member == player or member:IsAlive())` para evitar acreditación indebida de experiencia a personajes muertos o distantes.
- **Defensa Anti-SQL Injection:** Filtrado estricto con regex `gsub("['\"\\;%s]", "")` en nombres de jugadores para comandos `.bp` en el emulador.
- **Limpieza de LowGUIDs:** Suscripción al evento `PLAYER_EVENT_ON_CHARACTER_DELETE` (Evento 2) para purgar automáticamente filas huérfanas en `character_battlepass` y evitar colisiones de IDs reciclados.
- **Compatibilidad Gráfica 3.3.5a:** Sustitución de llamadas inválidas `SetTexture(r, g, b, a)` por `SetTexture("Interface\\Buttons\\WHITE8X8")` y `SetVertexColor(r, g, b, a)`.
- **Protección de Registro de Prefijo:** Envoltura condicional en `if RegisterAddonMessagePrefix then ... end`.
- **Verificación DBC al 100%:** Auditoría empírica de los 100 IDs de recompensa contra el archivo `item_template` y DBC oficial de WotLK 3.3.5a.
- **Unificación de Git:** Eliminación de rama redundante `master` y establecimiento de `main` como rama canónica única en el repositorio oficial [DarckRovert/Jaina_BattlePass](https://github.com/DarckRovert/Jaina_BattlePass).
