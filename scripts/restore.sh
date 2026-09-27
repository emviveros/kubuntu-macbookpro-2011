#!/usr/bin/env bash
# Restaura um backup criado pelos scripts: ./restore.sh ~/.config/backup-tela-AAAAMMDD-HHMMSS
source "$(dirname "$0")/lib.sh"

SRC="${1:?uso: $0 <pasta-de-backup>}"
[ -d "$SRC/.config" ] || [ -d "$SRC/.local" ] || { echo "Não parece um backup: $SRC"; exit 1; }

log "Restaurando arquivos de $SRC"
cp -a "$SRC"/. "$HOME"/

if [ -f "$SRC/gtk-fonts.txt" ]; then
    rm -f "$HOME/gtk-fonts.txt"
    mapfile -t F < "$SRC/gtk-fonts.txt"
    gsettings set org.gnome.desktop.interface font-name "${F[0]//\'/}"
    gsettings set org.gnome.desktop.interface monospace-font-name "${F[1]//\'/}"
fi

log "Itens que o backup não cobre (remova à mão se quiser desfazer):"
echo "    ~/.config/plasma-workspace/env/appmenu-gtk.sh"
echo "    ~/.local/share/applications/google-chrome.desktop e com.google.Chrome.desktop"

reconfigure_kwin
restart_plasmashell
log "Saia e entre na sessão para completar."
