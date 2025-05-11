# 🍓 Raspberry Pi Modular DevOps Backup & Infra - Proyecto Terrerov

Este proyecto convierte una Raspberry Pi 5 (Arch Linux ARM) en una infraestructura DevOps modular, robusta y autosustentable, inspirada en OPNsense y servicios empresariales. Todo el sistema de configuración y automatización está versionado en este repositorio.

---

## 🚀 ¿Qué contiene este repositorio?

- **Scripts de backup y restauración modular** (`backup.sh`)
- **Definición de módulos**: cada servicio/configuración tiene su carpeta y `include.txt` con rutas críticas a respaldar
- **Automatización de backups y sincronización con GitHub**
- **Estructura lista para restaurar o migrar el sistema**
- **No incluye los archivos respaldados** (por seguridad y privacidad, los backups se guardan fuera del repo, en `/mnt/usbdata/backups/dotfiles/`)

---

## 🗂️ Estructura del proyecto

```
dotfiles/
├── backup.sh           # Script principal de backup modular y push a GitHub
├── backup.log          # Log de respaldos
├── README.md           # Este archivo
├── modules/            # Definición de módulos y archivos a respaldar
│   ├── system/
│   │   └── include.txt
│   ├── docker/
│   │   └── include.txt
│   ├── proxy/
│   │   └── include.txt
│   ├── usb-mount/
│   │   └── include.txt
│   ├── wifi-hotspot/
│   │   └── include.txt
│   └── backup/
│       └── include.txt
└── ...
```

Los backups reales se almacenan en `/mnt/usbdata/backups/dotfiles/<modulo>/` y **no** se suben a GitHub.

---

## ♻️ Lógica de backup modular

- Cada módulo define en su `include.txt` los archivos/carpetas críticos a respaldar (rutas absolutas o relativas).
- El script `backup.sh` recorre todos los módulos y copia los archivos a `/mnt/usbdata/backups/dotfiles/<modulo>/`, replicando la estructura original.
- Se genera un `README.md` por módulo con la fecha y los archivos respaldados.
- Si hay cambios en los scripts o definiciones, se hace commit y push automático a GitHub, con mensaje detallado por archivo.
- El backup puede ejecutarse manualmente o por cron/systemd timer, y no requiere intervención ni contraseñas.

---

## 🔒 Seguridad

- **No se suben archivos sensibles ni configuraciones reales a GitHub**.
- Solo los scripts, logs y definiciones de backup están versionados.
- El backup real queda en el almacenamiento local seguro (`/mnt/usbdata/backups/dotfiles/`).
- El acceso SSH para push a GitHub es automatizado y sin passphrase.

---

## ⚙️ Restauración

- Para restaurar, copia los archivos desde `/mnt/usbdata/backups/dotfiles/<modulo>/` a su ubicación original.
- Puedes automatizar la restauración con un script similar, leyendo los `include.txt` de cada módulo.
- El sistema es modular: puedes restaurar solo un servicio o todo el sistema.

---

## 🛠️ Automatización

- El backup se puede ejecutar manualmente:
  ```bash
  sudo bash /mnt/usbdata/dotfiles/backup.sh
  ```
- O programar con cron (ejemplo cada 6 horas):
  ```bash
  0 */6 * * * sudo /mnt/usbdata/dotfiles/backup.sh
  ```
- O con un systemd timer.

---

## 👤 Autor

> **Josmar (terrerovgh)**  
> GitHub: [@terrerovgh](https://github.com/terrerovgh)  
> Email: terrerov@gmail.com
