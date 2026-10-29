# 📋 Registro de Cambios — ProjectJaina_BattlePass

Todos los cambios notables de este proyecto están documentados en este archivo siguiendo el estándar [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/).

---

## [2.0.0] — 2026-10-28
### Sincronización Autoritativa en Vivo, VIP Atómico y Blindaje Contra Dirty Writes
- **Sincronización Autoritativa con Backend Eluna (`70_BattlePassSystem.lua`):**
  - Despacho y recepción en tiempo real de paquetes de progreso, experiencia de temporada y recompensas desbloqueadas mediante el prefijo `PJ_BP`.
  - Eliminación de la condición de carrera por sobreescritura sucia (`dirty writes`) al ganar XP o desconectarse tras compras web o in-game.
- **Soporte de Estatus VIP Permanente y Niveles Automáticos:**
  - Integración nativa de la compra de estatus VIP con desbloqueo instantáneo del track premium de recompensas (monturas exclusivas, alas arcanas, títulos).
  - Protocolo de entrega de niveles automáticos con actualización inmediata de `BP_CACHE` y notificación dorada en pantalla.
- **Interfaz Gráfica Responsiva y Recompensas Reclamables:**
  - Animación de partículas arcanas al subir de nivel de temporada.
  - Botón de reclamo atómico por casilla con verificación estricta de inventario disponible para evitar pérdidas de ítems.
- **Comandos Slash Nativos:**
  - Soporte ampliado para `/bp`, `/battlepass` y comandos de staff `.bp <subcmd>`.

---

## [1.0.1] — 2026-10-10
### Estabilización de Ecosistema y Gobernanza Oficial (Project Jaina)
- **Normalización de UI y Gráficos:** Normalización de aspect ratio 1:1 en icono de cabecera (54x54), re-alineación de título a X=78, configuración explícita de SetBlendMode('BLEND') y sincronización autoritativa con base de datos.
- **Homologación Documental:** Incorporación y actualización formal de `GOVERNANCE.md`, `LICENSE`, `NOTICE.md` y `SECURITY.md`.
- **Licencia Canónica:** Consolidación de licencia MIT 2026 bajo titularidad de DarckRovert & Project Jaina Team.
- **Validación de Runtime:** Verificado al 100% con compilador sintáctico `lua52_compiler.exe -p` con 0 errores y 0 warnings.

---

## [1.0.0] — 2026-10-04
### Lanzamiento Inicial — Ecosistema Project Jaina WotLK 3.3.5a
- Implementación de la arquitectura base para Project Jaina Battle Pass.
- Registro de comandos slash: `/bp, /battlepass`.
- Persistencia de configuración en `ProjectJaina_BattlePassDB`.
- Compatibilidad certificada con cliente WotLK 3.3.5a (Build 12340) y directiva `Interface: 30300`.
