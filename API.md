# 🔌 Especificación Técnica y API — WoWPeru_BattlePass

[![GitHub](https://img.shields.io/badge/GitHub-DarckRovert%2FWoWPeru_BattlePass-black?logo=github)](https://github.com/DarckRovert/WoWPeru_BattlePass)
[![Ecosistema](https://img.shields.io/badge/Ecosistema-WoW%20Per%C3%BA%203.3.5a-gold.svg)](https://wow-peru.lat/)

## 📌 Resumen Arquitectónico
Sistema estacional de Pase de Batalla con 50 niveles de progresión, desafíos diarios/semanales, recompensas exclusivas y sincronización de auras de cuenta.

- **Rol en el Ecosistema:** Módulo Oficial #12 — Pase de Batalla
- **Archivo Principal TOC:** `WoWPeru_BattlePass.toc`
- **Compatibilidad del Motor:** World of Warcraft 3.3.5a (Build 12340)

---

## ⌨️ Comandos de Consola (Slash Commands)
- `/battlepass`: Acceso principal o comando del addon.
- `/bp`: Acceso principal o comando del addon.
- `/pase`: Acceso principal o comando del addon.

---

## 📡 Protocolo de Red y Eventos
- `WP_BATTLEPASS`: Prefijo registrado para sincronización de datos.

### Eventos del Motor 3.3.5a Gestionados
- `PLAYER_LOGIN` / `ADDON_LOADED`: Inicialización atómica de tablas de configuración y hooks.
- `PLAYER_ENTERING_WORLD`: Sincronización de estado tras transiciones de pantalla o mapa.
- `PLAYER_LOGOUT`: Guardado seguro en disco de las variables locales.

---

## 💾 Persistencia de Datos (SavedVariables)
- `WoWPeru_BattlePass_CharDB`: Almacenamiento estructurado de configuración y estado persistente.
- `WoWPeru_BattlePass_GlobalDB`: Almacenamiento estructurado de configuración y estado persistente.

---

## 🛠️ Buenas Prácticas de Integración
1. Toda invocación a funciones públicas debe verificar previamente la existencia del espacio de nombres en `_G`.
2. Las tablas de configuración deben consultarse en modo lectura sin sobreescribir valores por omisión no validados.
3. El intercambio de datos con otros addons debe efectuarse a través del bus oficial `WoWPeru_Companion` o hooks de eventos estándar.
