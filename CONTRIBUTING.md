# 🤝 Guía de Contribución - WoW Perú Battle Pass

¡Gracias por tu interés en contribuir a **WoWPeru_BattlePass**! Este documento establece las pautas de calidad, arquitectura y flujo de trabajo necesarias para que cualquier aporte sea aceptado en el proyecto oficial de WoW Perú.

---

## 1. Principios de Desarrollo

El Pase de Batalla de WoW Perú opera en un entorno híbrido (Cliente WoW 3.3.5a + Servidor Eluna Lua Engine). Todo código debe cumplir:

1. **Lua 5.1 Estricto:** Prohibido el uso de APIs o sintaxis de versiones posteriores.
2. **Compatibilidad con Cabinas de Internet:** Optimizado para bajo consumo de memoria y CPU. No crear widgets dinámicos en bucles; usar el pool virtual de 5 ranuras en [UI.lua](UI.lua).
3. **Cero Fugas de Memoria / Watchdogs Limpios:** Todo temporizador `OnUpdate` debe cancelarse (`SetScript("OnUpdate", nil)`) antes de que su frame sea reciclado u ocultado.
4. **Respeto al Límite de 255 Bytes:** Los mensajes de red vía `SendAddonMessage` nunca deben exceder 255 bytes. Usar codificación hexadecimal o delimitación compacta.
5. **Sanitización de Consultas SQL:** Todo dato proveniente de comandos de usuario en [Server/70_BattlePassSystem.lua](Server/70_BattlePassSystem.lua) debe sanitizarse contra inyección (`gsub("['\"\\;%s]", "")`).

---

## 2. Flujo de Trabajo en Git

1. **Rama Canónica:** El repositorio utiliza exclusivamente la rama `main`. No crear ni hacer pull requests dirigidos a `master`.
2. **Ramas de Trabajo:**
   - Correcciones de errores: `fix/nombre-del-bug`
   - Nuevas funcionalidades: `feature/nombre-de-la-mejora`
   - Documentación: `docs/nombre-del-cambio`
3. **Mensajes de Commit:** Seguir la convención de Commits Convencionales:
   - `fix: cancelar timers OnUpdate en reciclaje de slots`
   - `feat: anadir validacion de caracteres latinos en comando .bp`
   - `docs: actualizar guia de gobernanza y roles`
   - `perf: optimizar parsing de bitmask hexadecimal`

---

## 3. Checklist Obligatorio Antes de Enviar un Pull Request

Antes de solicitar la integración de código, debes ejecutar y verificar:

- [ ] **Balance de Sintaxis Lua:** Ejecutar el analizador de sintaxis y confirmar balance de bloques en cero (`depth = 0`).
- [ ] **Sincronización 1:1 de Recompensas:** Las tablas `Config.Levels` en [Config.lua](Config.lua) y `BP_Config.Rewards` en [Server/70_BattlePassSystem.lua](Server/70_BattlePassSystem.lua) deben ser idénticas en IDs de ítem, tipos, cantidades y títulos.
- [ ] **Existencia en DBC 3.3.5a:** Confirmar que cualquier nuevo ítem o montura exista en el cliente de WotLK 3.3.5a (Build 12340).
- [ ] **Pruebas de Polimorfismo en Servidor:** Asegurar que `OnServerAddonMessage` funcione correctamente tanto con firmas de 5 argumentos como de 6 argumentos.
- [ ] **Sin Taint ni Errores LUA:** Probar in-game recargando la interfaz (`/reload`) sin generar excepciones de Lua.

---

## 4. Estilo de Código

- Indentación: 4 espacios (no tabs).
- Nombres de funciones y tablas globales: Prefijo `WoWPeru_BattlePass_` o dentro del namespace `WP_BP`.
- Variables locales: Declarar siempre como `local` para no contaminar el entorno global `_G`.
- Comentarios: Explicar el "por qué" de las decisiones arquitectónicas, no solo el "qué".

---

## 5. Reporte de Vulnerabilidades o Exploits

Si descubres una vulnerabilidad que permita duplicar recompensas, inyectar código SQL o manipular la progresión de niveles, **NO abras un issue público**. Consulta las instrucciones en [SECURITY.md](SECURITY.md).
