# 🤖 Reglas de Contexto y Memoria para Agentes de IA - Jaina_BattlePass

> **Repositorio Oficial:** [DarckRovert/Jaina_BattlePass](https://github.com/DarckRovert/Jaina_BattlePass)  
> **Líder del Proyecto:** DarckRovert (Ingame: `Elnazzareno`)  
> **Servidor Destino:** [Project Jaina](https://worldofwanos.com/) - Project Jaina  
> **Entorno:** WotLK 3.3.5a (Build 12340) | Motor Eluna Lua Engine  

---

## 1. Directivas Inviolables para Agentes de IA

1. **Empirismo Estricto:** Antes de editar código, inspeccionar siempre los archivos reales. Prohibido asumir APIs de Retail o versiones de Eluna inexistentes en 3.3.5a.
2. **Presupuesto de Red (255 Bytes):** Toda comunicación por `SendAddonMessage` usa el prefijo `WP_BP` por canal `"WHISPER"`. Las 50 recompensas se sincronizan en una máscara hexadecimal de 13 caracteres. Nunca enviar listas largas sin comprimir.
3. **Optimización de Memoria (Cabinas de Internet):**
   - El pool de ranuras en [UI.lua](UI.lua) mantiene exactamente 5 ranuras reciclables en memoria.
   - Todo watchdog `OnUpdate` en un botón reciclable **debe ser cancelado** con `btn:SetScript("OnUpdate", nil)` antes de mover de página u ocultar la ranura.
4. **Widgets 3.3.5a:**
   - Usar `SetTexture("Interface\\Buttons\\WHITE8X8")` y `SetVertexColor()` en vez de `SetTexture(r,g,b,a)`.
   - Proteger `RegisterAddonMessagePrefix` con `if RegisterAddonMessagePrefix then ... end`.
   - Enlaces copiables mediante `EditBox` con `HighlightText()`.
5. **Seguridad SQL y LowGUIDs:**
   - En [Server/70_BattlePassSystem.lua](Server/70_BattlePassSystem.lua), todo parámetro de usuario debe filtrarse con `gsub("['\"\\;%s]", "")`.
   - El evento `PLAYER_EVENT_ON_CHARACTER_DELETE` (Evento 2) debe purgar las tablas `character_battlepass` y `character_battlepass_quests`.
6. **Polimorfismo Eluna:** Mantener compatibilidad con firmas de 5 y 6 argumentos en `OnServerAddonMessage`.
7. **Git:** Rama canónica exclusiva `main`. Prohibido crear o usar `master`.
