#!/usr/bin/env bash
# Faz os apps GTK mandarem os menus para o Menu global da barra superior
source "$(dirname "$0")/lib.sh"

if ! dpkg -s appmenu-gtk3-module >/dev/null 2>&1; then
    log "Falta o pacote appmenu-gtk3-module. Instale com:"
    echo "    sudo apt install appmenu-gtk3-module"
fi

log "Instalando ~/.config/plasma-workspace/env/appmenu-gtk.sh"
mkdir -p ~/.config/plasma-workspace/env
install -m 755 "$REPO_DIR/files/appmenu-gtk.sh" ~/.config/plasma-workspace/env/appmenu-gtk.sh
log "Vale a partir do próximo login."
