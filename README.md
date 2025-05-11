# 🍓 Raspberry Pi 5 Full Modular DevOps Stack - Proyecto Terrerov

Este proyecto transforma una Raspberry Pi 5 con Arch Linux ARM en un sistema DevOps modular, robusto y autosustentable, inspirado en OPNsense y servicios empresariales, enfocado en:

- 🔐 Seguridad y control de red (Hotspot + Proxy + Firewall)
- 🧱 Infraestructura Docker completa
- 💾 Sistema de backups constante y modular
- 📂 Almacenamiento eficiente y organizado en USB 3.0
- ⚙️ Scripts reutilizables y automatización por defecto
- 🌐 Despliegue en dominio personalizado `terrerov.com` usando certificados Cloudflare

Todo esto es versionado con Git en un repositorio de `dotfiles`, para que puedas replicar, restaurar o migrar tu setup con solo ejecutar un script `setup.sh`.

---

## ✅ Checklist de Progreso

| Módulo                          | Estado       | Notas                                                                 |
|--------------------------------|--------------|-----------------------------------------------------------------------|
| 🔧 Sistema Base (`system`)     | ✅ Completo   | Hostname, login automático, usuario `terrerov` configurado.           |
| 💽 Montaje USB (`usb-mount`)   | ✅ Completo   | Montaje automático + servicio que detecta desconexiones.             |
| 🧠 Estructura Dotfiles          | ✅ Completo   | Estructura de carpetas modular organizada por servicios.             |
| 📦 Backup Modular              | 🔄 En curso   | Scripts funcionales, falta pulir `README.md` y modularización final. |
| 📶 Hotspot WiFi                | 🔲 Pendiente  | Configurar con `create_ap` + control por systemd.                     |
| 🌐 Proxy Transparente (Squid)  | 🔲 Pendiente  | Proxy HTTP/HTTPS via Docker + redirección NAT.                        |
| 🧱 Docker + Traefik            | 🔲 Pendiente  | Docker y proxy inverso para subdominios `*.terrerov.com`.            |
| 🔒 Certificados Cloudflare     | 🔲 Pendiente  | Automatizar Let’s Encrypt con Cloudflare API.                        |
| 🧩 Servicios Extra             | 🔲 Pendiente  | DNS (CoreDNS), Pi-hole, Monitorización (Uptime Kuma, Netdata, etc).  |

---

## 🗂️ Estructura de Carpetas

```bash
dotfiles/
├── setup.sh                     # Script principal de instalación
├── README.md                    # Este archivo
├── modules/
│   ├── system/                  # Configuración del sistema base
│   ├── usb-mount/               # Montaje dinámico de USB y backups
│   ├── docker/                  # Configuración base de Docker
│   ├── proxy/                   # Squid, Traefik y reglas de red
│   ├── backup/                  # Backup modular por servicio
│   └── wifi-hotspot/           # Configuración y arranque de hotspot
└── dotfiles-setup.log          # Registro de instalación
```

---

## 📁 Organización de `/mnt/usbdata`

Esta partición se usa como almacenamiento principal del sistema. Estructura base recomendada:

```
/mnt/usbdata/
├── backups/
│   └── dotfiles/               # Copias por módulo (con README)
├── media/
│   ├── fotos/
│   ├── videos/
│   └── musica/
├── documentos/
│   ├── personales/
│   └── laborales/
├── configs/
│   ├── pihole/
│   ├── traefik/
│   ├── squid/
│   └── system/
├── db/
│   ├── postgres/
│   └── sqlite/
└── www/
    └── sites/
```

---

## ⚙️ Cómo levantar el sistema desde cero

1. 🔥 Instalar Arch Linux ARM limpio en Raspberry Pi 5.
2. 🔐 Crear el usuario `terrerov` y clonar el repositorio:
   ```bash
   git clone git@github.com:terrerovgh/dotfiles.git
   cd dotfiles
   ./setup.sh
   ```
3. El script detecta y monta el USB en `/mnt/usbdata`, configura el sistema, y ejecuta cada módulo en orden.

---

## 🛠️ Sobre los Módulos

Cada módulo tiene:

- Scripts de instalación y restauración
- Backup de archivos de configuración
- Un `README.md` explicando qué hace y qué necesita
- Instalación automática si se ejecuta desde `setup.sh`

Ejemplo de estructura:

```
modules/system/
├── hostname.sh
├── auto-login.sh
└── README.md
```

---

## ♻️ Backup Automático

- Cada módulo puede definirse en `backup/include.txt` con sus archivos críticos.
- Un script `backup.sh` recorre los módulos y copia su contenido a `/mnt/usbdata/backups`.
- Se configura un cronjob para ejecutarse cada X horas o al iniciar el sistema.

---

## 🔒 Seguridad y recuperación

- Si el USB no está montado, se usa una copia mínima del sistema desde SD.
- Servicios como `usb-checker.service` monitorean que todo esté corriendo como debe.

---

## 🔚 ¿Qué falta?

- Hotspot funcional con firewall
- Redirección completa del tráfico al proxy transparente
- Subdominios automatizados para cada contenedor
- Certificados de Cloudflare configurados por API
- Documentación por cada módulo individual

---

## 👤 Autor

> **Josmar (terrerovgh)**  
> GitHub: [@terrerovgh](https://github.com/terrerovgh)  
> Email: terrerov@gmail.com
