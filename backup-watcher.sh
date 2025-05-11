#!/bin/bash
# backup-watcher.sh - Monitorea cambios en archivos críticos y ejecuta backup automático

WATCH_PATHS=(
  "/etc"
  "/mnt/usbdata/config"
  "/mnt/usbdata/dotfiles"
)
LOG="/mnt/usbdata/dotfiles/backup-watcher.log"

inotifywait -m -r -e modify,create,delete,move --format '%w%f' "${WATCH_PATHS[@]}" | while read file; do
  echo "$(date '+%Y-%m-%d %H:%M:%S') Cambio detectado en: $file" >> "$LOG"
  sudo -u terrerov bash /mnt/usbdata/dotfiles/backup.sh
  sleep 5 # Evita ejecuciones múltiples simultáneas
done
