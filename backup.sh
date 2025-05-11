#!/bin/bash
# backup.sh - Backup modular y escalable para dotfiles y configuraciones del sistema
# Autor: Josmar (terrerovgh)
# Fecha: $(date '+%Y-%m-%d')

set -e

# Configuración
DOTFILES_DIR="/mnt/usbdata/dotfiles"
MODULES_DIR="$DOTFILES_DIR/modules"
BACKUP_DIR="/mnt/usbdata/backups/dotfiles"
LOG_FILE="$DOTFILES_DIR/backup.log"
GIT_REPO="git@github.com:terrerovgh/dotfiles.git"

# Crear carpeta de backups si no existe
mkdir -p "$BACKUP_DIR"

# Función para respaldar un módulo
backup_module() {
    local module="$1"
    local include_file="$MODULES_DIR/$module/include.txt"
    local module_backup_dir="$BACKUP_DIR/$module"
    mkdir -p "$module_backup_dir"
    if [[ -f "$include_file" ]]; then
        echo "[INFO] Respaldando módulo: $module"
        local backed_up_any=0
        while IFS= read -r file; do
            [[ -z "$file" || "$file" =~ ^# ]] && continue
            # Permitir rutas absolutas y relativas
            local src_path="$file"
            [[ ! "$file" =~ ^/ ]] && src_path="$DOTFILES_DIR/$file"
            if [[ -e "$src_path" ]]; then
                local dest="$module_backup_dir/${file}"
                local dest_dir
                dest_dir=$(dirname "$dest")
                mkdir -p "$dest_dir"
                if [[ -d "$src_path" ]]; then
                    rsync -a --delete "$src_path/" "$dest/"
                else
                    cp -a "$src_path" "$dest"
                fi
                echo "  - $src_path -> $dest" >> "$LOG_FILE"
                backed_up_any=1
            else
                echo "  - [WARN] $src_path no existe" >> "$LOG_FILE"
            fi
        done < "$include_file"
        # Actualizar README del módulo
        echo -e "# Backup del módulo $module\n\nÚltimo backup: $(date '+%Y-%m-%d %H:%M:%S')\n\nArchivos respaldados:\n" > "$module_backup_dir/README.md"
        grep -v '^#' "$include_file" | grep -v '^$' | sed 's/^/ - /' >> "$module_backup_dir/README.md"
        if [[ $backed_up_any -eq 0 ]]; then
            echo "\n(No se respaldó ningún archivo en este backup)" >> "$module_backup_dir/README.md"
        fi
    else
        echo "[WARN] No existe $include_file para $module" >> "$LOG_FILE"
    fi
}

# Recorrer todos los módulos
for module in $(ls "$MODULES_DIR"); do
    backup_module "$module"
done

# Commit y push a GitHub
cd "$DOTFILES_DIR"
# Soporte para SSH agent al usar sudo
if [ -n "$SUDO_USER" ] && [ -n "$SSH_AUTH_SOCK" ]; then
    export SSH_AUTH_SOCK="$SSH_AUTH_SOCK"
fi
git add .
git commit -m "Backup automático: $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main

echo "Backup y sincronización con GitHub completados."
