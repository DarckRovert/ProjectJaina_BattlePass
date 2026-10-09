# 🛡️ Política de Seguridad y Anti-Exploits - Project Jaina Battle Pass

**Versión:** 1.0.0  
**Fecha de Vigencia:** 27 de Septiembre de 2026  
**Responsable de Seguridad:** DarckRovert (Elnazzareno)  

---

## 1. Modelo de Seguridad y Confianza Cero (Zero Trust)

El sistema **Jaina_BattlePass** opera bajo el principio de **Autoridad Exclusiva del Servidor**:
- El cliente (Addon Lua) actúa únicamente como una terminal visual de presentación.
- **Ninguna acción de progresión, entrega de ítems, adición de oro o desbloqueo de niveles se decide en el cliente.**
- Todo reclamo emitido por el cliente (`BP_CLAIM:<nivel>:<track>`) es validado estrictamente por el script de servidor [70_BattlePassSystem.lua](Server/70_BattlePassSystem.lua) antes de interactuar con la base de datos o el inventario del jugador.

---

## 2. Mecanismos de Defensa Implementados

### 2.1. Prevención de Duplicación mediante Máscara de Bits (Bitmask Tamper-Proof)
- Las recompensas gratuitas y VIP de los 50 niveles se almacenan como máscaras de bits (`free_claims`, `premium_claims`).
- Si un usuario manipula el cliente para enviar múltiples paquetes `BP_CLAIM`, el servidor realiza una operación lógica AND a nivel de bit:
  - Si el bit correspondiente ya está activo, el servidor ignora la petición y registra un intento de reclamo inválido.
  - La transacción es atómica e idempotente.

### 2.2. Protección Contra Inyecciones SQL
- Los comandos administrativos in-game (`.bp addxp`, `.bp setvip`, `.bp reset`) reciben nombres de personajes introducidos por Game Masters o Staff.
- Todo parámetro de texto se somete a filtrado de caracteres maliciosos mediante expresiones regulares de Lua:
  ```lua
  local safeTarget = targetName:gsub("['\"\\;%s]", "")
  ```
  Esto bloquea comillas, barras invertidas, punto y coma y espacios en blanco antes de ejecutar consultas en MySQL.

### 2.3. Aislamiento de Transporte de Red
- Toda la comunicación de red utiliza el canal `"WHISPER"` dirigido a `UnitName("player")`.
- Esto garantiza que ningún otro jugador en la banda, grupo, hermandad o canal global pueda interceptar, espiar o falsear paquetes de respuesta del Pase de Batalla.

### 2.4. Integridad en el Ciclo de Vida de Personajes (Anti LowGUID Collision)
- En emuladores 3.3.5a, cuando un personaje se elimina, su LowGUID puede ser reasignado a un nuevo personaje en el futuro.
- El servidor escucha el evento `PLAYER_EVENT_ON_CHARACTER_DELETE` (Evento 2 de Eluna) y purga inmediatamente todos los registros en `character_battlepass` y `character_battlepass_quests`.
- Esto elimina el riesgo de que un personaje recién creado herede niveles, progreso o estados VIP indebidos.

---

## 3. Notificación Responsable de Vulnerabilidades

Si descubres una vulnerabilidad de seguridad crítica o un fallo que permita la explotación de recompensas:

1. **NO divulgarla públicamente:** No crear issues públicos en GitHub ni compartirla en canales de chat abiertos.
2. **Canal de Contacto Directo:**
   - Discord oficial de Project Jaina: Contactar directamente a `DarckRovert` (Elnazzareno).
   - Servidor: [https://darckrovert.github.io/ProjectJaina_Web/](https://darckrovert.github.io/ProjectJaina_Web/)
3. **Información a Proporcionar:**
   - Pasos detallados para reproducir el comportamiento.
   - Capturas de paquetes o logs del emulador (si aplica).
   - Impacto estimado en la economía o estabilidad del servidor.
