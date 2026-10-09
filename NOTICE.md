# 📜 Aviso Legal y Atribución — Jaina_BattlePass

Este repositorio forma parte del ecosistema oficial de **Project Jaina - Project Jaina**.
Contiene el sistema de Pase de Batalla Estacional (Free y VIP) para el cliente World of Warcraft 3.3.5a (Build 12340).

---

## 1. Autoría y Desarrollo Oficial
* **Desarrollador Principal:** DarckRovert (Ingame: `Elnazzareno`) & Antigravity (Mythos 5)
* **Ecosistema:** [Project Jaina — Project Jaina](https://darckrovert.github.io/ProjectJaina_Web/)
* **Repositorio Oficial:** [DarckRovert/Jaina_BattlePass](https://github.com/DarckRovert/Jaina_BattlePass)

---

## 2. Arquitectura de Red y Protocolo Autoritativo
* **Prefijo de Red:** `WP_BP` (Canales: `WHISPER`, `GUILD`, `PARTY`).
* **Integración Servidor:** Script autoritativo en Eluna (`70_BattlePassSystem.lua`) y tabla MySQL `character_battlepass`.
* **Seguridad y Anti-Exploit:** La progresión de niveles (1-50), misiones y reclamo de recompensas son validados exclusivamente en el servidor. El cliente es puramente visual y de presentación.

---

## 3. Cumplimiento de Políticas de Interfaz
En estricto cumplimiento de la Política de Interfaz de Usuario Personalizada de Blizzard (Blizzard Custom UI Policy):
1. Este software es gratuito y de código abierto para la comunidad de jugadores del Project Jaina.
2. No realiza ingeniería inversa ni altera binarios del juego (`WoW.exe`).
3. Respeta el aislamiento de ejecución en FrameXML y no genera taint en subsistemas protegidos.
