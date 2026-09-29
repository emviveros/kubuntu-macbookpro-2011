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
echo "    ~/.config/plasma-workspace/env/appmenu-gtk.sh e fontconfig-cache-guard.sh"
echo "    ~/.local/share/applications/google-chrome.desktop e com.google.Chrome.desktop"
echo "    ~/.local/bin/quicklook-dolphin, quicklook-wayland, midia-pular e brilho-tela"
echo "    ~/.config/touchegg/touchegg.conf (se não havia antes)"
echo "    Scripts do KWin: kpackagetool6 --type KWin/Script --remove gestos-macos (e brilho-tela, quicklook)"
echo "    Serviços: ~/.config/systemd/user/brilho-tela.service e quicklook-fechou.service"
echo "    Toshy: cd ~/.local/src/toshy && ./setup_toshy.py uninstall"
echo "    Antigravity: ver docs/alteracoes.md, seção 11 (~/.local/share/antigravity, ~/.local/bin/agy e outros)"
echo "    Indexador: systemctl --user unmask tracker-miner-fs-3.service; rm ~/.config/autostart/tracker-miner-fs-3.desktop"

reconfigure_kwin
restart_plasmashell
log "Saia e entre na sessão para completar."
