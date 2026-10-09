# 🏛️ Modelo de Gobernanza del Proyecto - Project Jaina Battle Pass

**Versión del Documento:** 1.0.0  
**Fecha de Entrada en Vigor:** 27 de Septiembre de 2026  
**Líder del Proyecto / Autor:** DarckRovert (Ingame: Elnazzareno)  
**Servidor Destino:** [Project Jaina](https://darckrovert.github.io/ProjectJaina_Web/) - Project Jaina  
**Entorno de Ejecución:** World of Warcraft 3.3.5a (Build 12340) | Eluna Lua Engine (TrinityCore / AzerothCore)  

---

## 1. Misión y Alcance

**ProjectJaina_BattlePass** es el sistema estacional oficial de progresión y recompensas del servidor Project Jaina. Proporciona una experiencia de 50 niveles con vías Duales (Gratuita y Premium VIP), misiones diarias y semanales, y entrega de ítems, monturas y títulos mediante arquitectura distribuida cliente-servidor.

### Objetivos Primordiales del Sistema:
1. **Rendimiento Extremo (Cabinas de Internet):** Funcionamiento fluido a 60 FPS sin caídas de framerate en resoluciones bajas ($800\times600$, $1024\times768$) típicas de cabinas de internet en Perú, utilizando un pool virtual de 5 ranuras reciclables en memoria.
2. **Seguridad de Red y Cero Desbordamiento:** Empaquetado estricto bajo el límite inviolable de 255 bytes por paquete de `SendAddonMessage` de la versión 3.3.5a, sincronizando 50 niveles en una máscara de bits hexadecimal de 13 caracteres.
3. **Idempotencia y Persistencia Robusta:** Imposibilidad matemática de reclamar recompensas duplicadas y sincronización segura con la base de datos MySQL (`characters`).
4. **Compatibilidad Multi-Núcleo:** Funcionamiento nativo e idéntico tanto en emuladores basados en TrinityCore como en AzerothCore con motor Eluna.

---

## 2. Estructura de Roles y Responsabilidades

El proyecto se rige bajo un modelo de **Liderazgo Técnico Centralizado**:

```
       ┌─────────────────────────────────────────┐
       │   Líder del Proyecto (Project Lead)     │
       │     DarckRovert (Elnazzareno)            │
       └────────────────────┬────────────────────┘
                            │
       ┌────────────────────▼────────────────────┐
       │      Equipo de Desarrollo y Staff       │
       │   (Core Eluna, Addon Lua, Webmaster)    │
       └────────────────────┬────────────────────┘
                            │
       ┌────────────────────▼────────────────────┐
       │     Game Masters y Soporte In-Game      │
       │     (Atención a Jugadores, Eventos)     │
       └─────────────────────────────────────────┘
```

### 2.1. Project Lead (Líder del Proyecto)
- **Titular:** DarckRovert (Elnazzareno).
- **Atribuciones:**
  - Control de la visión arquitectónica, balance de experiencia y recompensas estacionales.
  - Aprobación y fusión final de código en la rama `main` del repositorio oficial.
  - Firma de versiones estacionales oficiales (v1.0.0, v2.0.0, etc.).
  - Veto técnico sobre cualquier cambio que comprometa la estabilidad del emulador o el rendimiento del cliente.

### 2.2. Desarrolladores y Mantenedores (Core & Web)
- **Responsabilidades:**
  - Mantenimiento del script de servidor (`Server/70_BattlePassSystem.lua`) y del addon cliente (`Core.lua`, `UI.lua`, `MinimapButton.lua`, `Config.lua`).
  - Verificación estricta de compatibilidad de ítems con el DBC de WotLK 3.3.5a (Build 12340).
  - Integración del pipeline de donaciones web (`https://darckrovert.github.io/ProjectJaina_Web/`) con las tablas `character_battlepass`.
  - Asegurar la integridad de sintaxis Lua (balance de bloques sin fugas).

### 2.3. Game Masters (Staff de Soporte)
- Gestión de incidencias in-game mediante los comandos de administración `.bp`.
- Asignación de experiencia o activación de pases mediante herramientas autorizadas sin manipular directamente la base de datos en caliente a menos que sea necesario.

---

## 3. Principios Técnicos Inviolables (Leyes de Arquitectura)

Todo código añadido o modificado en este proyecto debe cumplir estrictamente las siguientes reglas:

### 3.1. Cero Suposiciones (Empirismo Estricto)
Antes de proponer o aplicar un cambio, se debe verificar el código fuente exacto, las llamadas de API de Eluna y el estado real en disco. Queda terminantemente prohibido asumir firmas de métodos de WoW Retail o versiones posteriores de la API de Blizzard.

### 3.2. Restricciones del Cliente 3.3.5a (Build 12340)
- **Texturas:** `Texture:SetTexture(r, g, b, a)` NO existe en 3.3.5a. Toda textura de color sólido debe usar `SetTexture("Interface\\Buttons\\WHITE8X8")` seguido de `SetVertexColor(r, g, b, a)`.
- **Registro de Prefijos:** `RegisterAddonMessagePrefix` no existe en 3.3.5a nativo; cualquier llamada debe estar protegida defensivamente con `if RegisterAddonMessagePrefix then ... end`.
- **Copiar Enlaces:** Los `FontString` no son seleccionables en 3.3.5a. Todo enlace que requiera ser copiado al portapapeles debe utilizar un widget `EditBox` con `HighlightText()` automático.

### 3.3. Protocolo de Red y Seguridad de Paquetes
- **Canal de Transporte:** Se debe utilizar exclusivamente `"WHISPER"` dirigido a `UnitName("player")` para evitar polución de canales de chat globales o de grupo.
- **Prefijo Oficial:** Todo mensaje del Pase de Batalla debe utilizar el prefijo reservado `WP_BP`.
- **Estructura de OpCodes:**
  - Peticiones del cliente: `BP_REQ_SYNC`, `BP_CLAIM:<nivel>:<free|premium>`.
  - Respuestas del servidor: `BP_RES_SYNC:...`, `BP_RES_CLAIM:...`, `BP_RES_XP:...`, `BP_RES_QUEST:...`.
- **Longitud Máxima:** Ningún payload puede exceder los 255 bytes en ninguna circunstancia.

### 3.4. Ciclo de Vida de Interfaz y Recursos de CPU
- **Gestión de Tickers `OnUpdate`:** Cualquier temporizador de espera (watchdog) instalado en un botón o marco reciclable DEBE ser cancelado explícitamente (`btn:SetScript("OnUpdate", nil)`) al reutilizar el slot o cambiar de página para evitar condiciones de carrera por clausuras zombis.
- **Pool de Ranuras Virtuales:** La interfaz de recompensas nunca debe instanciar 50 filas físicas; debe mantener un pool estático de 5 tarjetas recicladas dinámicamente mediante traslación matemática de página.

### 3.5. Persistencia y Base de Datos MySQL
- **Reseteos Temporales:** Las misiones diarias se reinician deterministamente a las 04:00 AM hora del reino; las semanales los miércoles a las 04:00 AM. Los cálculos deben usar `os.time` con normalización gregoriana.
- **Protección de Reciclaje de GUIDs:** La eliminación de personajes (`PLAYER_EVENT_ON_CHARACTER_DELETE`, Evento 2) debe purgar de inmediato las filas en `character_battlepass` y `character_battlepass_quests` para evitar colisiones de herencia de datos en LowGUIDs reciclados.
- **Sanitización SQL Inviolable:** Queda prohibida la concatenación de variables de usuario en sentencias SQL sin sanitizar caracteres de inyección (`['"\\;%s]`).

---

## 4. Gestión de Cambios y Versionado

El proyecto utiliza **Versionado Semántico (SemVer)** adaptado al ciclo de vida del reino:

- **MAJOR (vX.0.0):** Cambios de Temporada (`SeasonId`), reestructuración de esquemas de base de datos o modificaciones incompatibles del protocolo de red.
- **MINOR (vx.Y.0):** Adición de nuevas misiones, rebalanceo de tablas de experiencia, o nuevas funcionalidades visuales conservando compatibilidad de red.
- **PATCH (vx.y.Z):** Corrección de bugs, optimización de consumo de memoria, actualización de descripciones o ajustes menores de interfaz.

### Política de Ramas en Git
- **`main`:** Rama única y canónica de producción. Todo commit en `main` debe ser ejecutable sin errores en el cliente y servidor.
- Queda prohibida la coexistencia de ramas duplicadas como `master`.

---

## 5. Procedimiento de Lanzamiento Oficial (Release Checklist)

Antes de generar un nuevo release o comprimir el archivo distribuible:
1. [ ] Ejecutar el verificador de sintaxis `check_lua_syntax.py` y constatar balance de bloques en cero.
2. [ ] Ejecutar `verify_rewards_sync.py` y constatar 0 discrepancias entre `Config.lua` y `70_BattlePassSystem.lua`.
3. [ ] Ejecutar `check_items.py` y confirmar que todos los IDs de recompensa existan en el DBC de WotLK 3.3.5a.
4. [ ] Generar el paquete ZIP `ProjectJaina_BattlePass_vX.Y.Z.zip` e incluirlo en la sección de Releases de GitHub.
5. [ ] Notificar al Sysadmin para aplicar posibles migraciones SQL si hubo cambio de versión mayor.
