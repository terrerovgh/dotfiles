#!/bin/bash
# backup.sh - Backup modular y escalable para dotfiles y configuraciones del sistema
# Autor: Josmar (terrerovgh)
# Fecha: $(date '+%Y-%m-%d')

set -e

# === CONFIGURACIÓN SSH PARA AUTOMATIZACIÓN ===
# Usar la clave SSH del usuario terrerov para git push automatizado
SSH_KEY="/home/terrerov/.ssh/id_ed25519_nopass"
export GIT_SSH_COMMAND="ssh -i $SSH_KEY -o IdentitiesOnly=yes"

# === AUTENTICACIÓN GITHUB CON TOKEN ===
GITHUB_ENV="/terrerov/.key/github.env"
if [[ -f "$GITHUB_ENV" ]]; then
  source "$GITHUB_ENV"
  if [[ -n "$GITHUB_TOKEN" ]]; then
    export GIT_ASKPASS="/bin/echo"
    export GIT_TERMINAL_PROMPT=0
    export GITHUB_USER="terrerovgh"
    export GITHUB_REPO="dotfiles"
    export GITHUB_URL="https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}.git"
    git remote set-url origin "$GITHUB_URL"
  fi
fi

# === ADVERTENCIA DE ROOT ===
if [[ $EUID -ne 0 ]]; then
  echo "[ERROR] Este script debe ejecutarse como root (sudo) para respaldar archivos protegidos."
  exit 1
fi

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
            local src_path="$file"
            local dest
            if [[ "$file" =~ ^/ ]]; then
                # Ruta absoluta: respáldala como system/etc/hostname, etc.
                dest="$module_backup_dir${file}"
            else
                # Ruta relativa: respáldala como backup/README.md, etc.
                dest="$module_backup_dir/$file"
                src_path="$DOTFILES_DIR/$file"
            fi
            local dest_dir
            dest_dir=$(dirname "$dest")
            mkdir -p "$dest_dir"
            if [[ -e "$src_path" ]]; then
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

# Commit y push a GitHub por cada archivo modificado
cd "$DOTFILES_DIR"

# Detectar archivos modificados (excluyendo README.md generados por backup)
git add .
changed_files=$(git diff --cached --name-only | grep -vE '/README.md$')

if [[ -n "$changed_files" ]]; then
    for file in $changed_files; do
        git commit -m "Backup automático: $file - $(date '+%Y-%m-%d %H:%M:%S')" -- "$file" || true
    done
    git push origin main
    # Restaurar la URL SSH si se cambió
    if [[ -n "$GITHUB_TOKEN" ]]; then
      git remote set-url origin "git@github.com:${GITHUB_USER}/${GITHUB_REPO}.git"
    fi
    echo "Backup y sincronización con GitHub completados."
else
    echo "No hay cambios para sincronizar con GitHub."
fi
