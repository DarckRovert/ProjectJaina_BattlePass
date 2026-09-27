# 🇵🇪 WoW Perú - Pase de Batalla (Battle Pass Suite v1.0.0)

Sistema estacional de Pase de Batalla (Free y Premium VIP) con 50 niveles de progresión, misiones diarias/semanales y recompensas exclusivas diseñado específicamente para el servidor **WoW Perú** (Reino Andino, 3.3.5a Build 12340).

---

## ✨ Características Principales

* **Progresión Estacional de 50 Niveles:** Sube de nivel realizando actividades cotidianas: mazmorras, campos de batalla (CFBG), arenas 1v1, misiones de mundo y muertes de monstruos.
* **Modelo Dual Justo:**
  * **Vía Gratuita:** Oro, pociones, bolsas, gemas épicas, emblemas de triunfo/escarcha, mascotas y títulos al alcance de todos los jugadores.
  * **Vía Premium (VIP):** Monturas exclusivas de temporada, auras visuales y efectos épicos para jugadores que apoyan el proyecto en [wow-peru.lat](https://wow-peru.lat/).
* **Carrusel Virtual de Alto Rendimiento:** Utiliza un pool de 5 ranuras reciclables en memoria. Cero caídas de FPS incluso en ordenadores de cabinas de internet ($800\times600$ a $4\text{K}$).
* **Botón de Minimapa Interactivo:** Botón circular con el blasón dorado de WoW Perú, órbita radial libre y tooltip reactivo con el nivel, porcentaje de XP y misiones completadas hoy.
* **Protocolo Bitmask Seguro (Inmune a los 255 bytes de la 3.3.5a):** Los 50 niveles se sincronizan en 13 caracteres hexadecimales, garantizando estabilidad absoluta y cero duplicación de recompensas.

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
WoWPeru_BattlePass/
├── WoWPeru_BattlePass.toc   # Metadatos del Addon
├── Config.lua               # Temporada, 50 niveles de recompensas y misiones
├── Locales.lua              # Localización Español (Reino Andino) / Inglés
├── Core.lua                 # Motor de eventos, parser bitmask y red
├── MinimapButton.lua        # Botón de minimapa y tooltip reactivo
├── UI.lua                   # Interfaz visual con carrusel virtual reciclable
├── README.md                # Este documento
├── INTEGRACION_STAFF.md     # Guía técnica de instalación para el Staff
└── Server/
    ├── battlepass_schema.sql  # Esquema MySQL para la BD `characters`
    └── 70_BattlePassSystem.lua # Script Eluna para el emulador
```

---

## 👥 Créditos
* **Desarrollo y Arquitectura:** DarckRovert & Equipo de WoW Perú
* **Sitio Web Oficial:** [https://wow-peru.lat/](https://wow-peru.lat/)
