# 🇵🇪 Project Jaina - Pase de Batalla (Battle Pass Suite v2.0.0)

[![GitHub](https://img.shields.io/badge/GitHub-DarckRovert%2FWanos__BattlePass-black?logo=github)](https://github.com/DarckRovert/Jaina_BattlePass)
[![WoW Client](https://img.shields.io/badge/WoW%20Client-3.3.5a%20(Build%2012340)-blue.svg)](https://projectjaina.com/)
[![Server](https://img.shields.io/badge/Servidor-WoW%20Perú-gold.svg)](https://projectjaina.com/)
[![Realm](https://img.shields.io/badge/Reino-Reino%20Andino-red.svg)](https://projectjaina.com/)
[![License](https://img.shields.io/badge/Licencia-MIT-green.svg)](LICENSE)

Sistema estacional de Pase de Batalla (Free y Premium VIP) con **50 niveles de progresión**, misiones diarias/semanales y recompensas exclusivas diseñado específicamente para el servidor **Project Jaina** (Project Jaina, 3.3.5a Build 12340).

---

## ✨ Características Principales

* **Progresión Estacional de 50 Niveles:** Sube de nivel realizando actividades cotidianas: mazmorras, campos de batalla (CFBG), arenas 1v1, misiones de mundo y muertes de monstruos.
* **Modelo Dual Justo:**
  * **Vía Gratuita:** Oro, pociones, bolsas, gemas épicas, emblemas de triunfo/escarcha, mascotas y títulos al alcance de todos los jugadores.
  * **Vía Premium (VIP):** Monturas exclusivas de temporada, auras visuales y efectos épicos para jugadores que apoyan el proyecto en [projectjaina.com](https://projectjaina.com/).
* **Carrusel Virtual de Alto Rendimiento:** Utiliza un pool de 5 ranuras reciclables en memoria. Cero caídas de FPS incluso en ordenadores de cabinas de internet ($800\times600$ a $4\text{K}$).
* **Botón de Minimapa Interactivo:** Botón circular con el blasón dorado de Project Jaina, órbita radial libre y tooltip reactivo con el nivel, porcentaje de XP y misiones completadas hoy.
* **Protocolo Bitmask Seguro (Inmune al límite de 255 bytes de la 3.3.5a):** Los 50 niveles se sincronizan en 13 caracteres hexadecimales, garantizando estabilidad absoluta y cero duplicación de recompensas.

---

## 🎮 Comandos de Chat

| Comando | Acción |
|---|---|
| `/bp` o `/pase` | Abre o cierra la ventana principal del Pase de Batalla. |
| `/bp minimap` | Muestra u oculta el botón del minimapa. |
| `/bp sync` | Fuerza la sincronización del estado con el servidor. |
| `/bp reset` | Restaura la posición original de la ventana. |

---

## 📁 Estructura del Módulo

```
Jaina_BattlePass/
├── Jaina_BattlePass.toc      # Metadatos del Addon
├── Config.lua                  # Temporada, 50 niveles de recompensas y misiones
├── Locales.lua                 # Localización Español (Project Jaina) / Inglés
├── Core.lua                    # Motor de eventos, parser bitmask y red
├── MinimapButton.lua           # Botón de minimapa y tooltip reactivo
├── UI.lua                      # Interfaz visual con carrusel virtual reciclable
├── README.md                   # Este documento
├── CHANGELOG.md                # Historial de versiones
├── CONTRIBUTING.md             # Guía para contribuidores
├── GOVERNANCE.md               # Modelo de gobernanza y roles
├── SECURITY.md                 # Política de seguridad y anti-exploits
├── AGENTS.md                   # Reglas de contexto para agentes de IA
├── ECOSYSTEM_REGISTRY.md       # Registro técnico del ecosistema
├── LICENSE                     # Licencia MIT
├── INTEGRACION_STAFF.md        # Guía técnica de instalación para el Staff
└── Server/
    ├── battlepass_schema.sql   # Esquema MySQL para la BD `characters`
    └── 70_BattlePassSystem.lua # Script Eluna para el emulador
```

---

## 📄 Licencia

Este proyecto está licenciado bajo los términos de la **Licencia MIT**. Consulta el archivo [LICENSE](LICENSE) para más detalles.

---

## 📚 Documentación del Ecosistema

* [Ficha Técnica Oficial del Ecosistema](ECOSYSTEM_REGISTRY.md)
* [Historial de Cambios](CHANGELOG.md)
* [Guía de Contribución](CONTRIBUTING.md)
* [Política de Seguridad](SECURITY.md)
* [Gobernanza del Proyecto](GOVERNANCE.md)
* [Licencia MIT](LICENSE)

---

## 👥 Créditos

* **Desarrollo y Arquitectura:** DarckRovert (Ingame: Elnazzareno) & Equipo de Project Jaina
* **Sitio Web Oficial:** [https://projectjaina.com/](https://projectjaina.com/)
