# 📜 Aviso Legal y Atribución — ProjectJaina_BattlePass

Este repositorio forma parte del ecosistema oficial de **Project Jaina**.
Contiene Sistema estacional oficial de progresión y recompensas (Free y VIP de 50 niveles) con sincronización compacta de máscara de bits de 13 caracteres bajo el límite de 255 bytes. para el cliente World of Warcraft 3.3.5a (Build 12340).

---

## 1. Autoría y Desarrollo Oficial
* **Desarrollador Principal:** DarckRovert (Ingame: `Elnazzareno`) & Antigravity (Mythos 5)
* **Ecosistema:** [Project Jaina Oficial](https://darckrovert.github.io/ProjectJaina_Web/)
* **Repositorio Oficial:** [DarckRovert/ProjectJaina_BattlePass](https://github.com/DarckRovert/ProjectJaina_BattlePass)

---

## 2. Arquitectura y Protocolo Autoritativo
* **Prefijo de Red:** `WP_BP`
* **Integración Servidor:** `70_BattlePassSystem.lua y tabla MySQL character_battlepass`
* **Variables Guardadas:** `ProjectJaina_BattlePassDB`
* **Comandos Slash:** `/bp, /battlepass`

---

## 3. Cumplimiento de Políticas de Interfaz (Blizzard Custom UI Policy)
En estricto cumplimiento de la Política de Interfaz de Usuario Personalizada de Blizzard Entertainment (2009):
1. **Gratuito y Abierto:** Este software es completamente gratuito y de código abierto para la comunidad de jugadores.
2. **Sin Alteración de Binarios:** No realiza ingeniería inversa, inyección de código ni altera binarios del juego (`WoW.exe`).
3. **Aislamiento FrameXML:** Respeta el aislamiento de ejecución en FrameXML y no genera taint en subsistemas protegidos de combate.
4. **Sin Publicidad ni Cobro:** No incluye anuncios publicitarios ni solicita compensación monetaria directa para el uso de sus funciones in-game.
