#!/bin/bash

set -e
REPO_DIR="/mnt/usbdata/dotfiles"
REMOTE_GIT="git@github.com:terrerovgh/dotfiles.git"
GIT_USER="terrerovgh"
GIT_EMAIL="terrerov@gmail.com"

log() {
    echo "[dotfiles-setup] $1"
}

error_exit() {
    echo "[ERROR] $1" >&2
    exit 1
}

# Configura git globalmente
log "Configurando Git global..."
git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main

cd "$REPO_DIR" || error_exit "No se pudo entrar a $REPO_DIR"

# Inicializa el repo si no existe
if [ ! -d ".git" ]; then
    log "Inicializando repositorio Git local..."
    git init
    git remote add origin "$REMOTE_GIT"
fi

# Verifica estado actual
log "Obteniendo estado de Git..."
git status

# Intenta hacer pull primero si existe
log "Haciendo pull del repositorio remoto (si existe)..."
if git ls-remote "$REMOTE_GIT" &>/dev/null; then
    git fetch origin || log "No se pudo hacer fetch (¿clave SSH mal configurada?)"
    git merge origin/main || log "No se pudo hacer merge automático. Resuelve conflictos a mano."
else
    log "El repositorio remoto aún no existe o no es accesible. Se asumirá que es un nuevo repo."
fi

# Agrega todos los archivos y haz commit si hay cambios
if [ -n "$(git status --porcelain)" ]; then
    log "Agregando archivos y haciendo commit..."
    git add .
    git commit -m "Sync automático de dotfiles desde rpi" || log "No hay nada que commitear."
    git push origin main || log "Error al hacer push. ¿Tienes acceso SSH al repositorio?"
else
    log "No hay cambios nuevos para subir."
fi

log "Sincronización completa."
