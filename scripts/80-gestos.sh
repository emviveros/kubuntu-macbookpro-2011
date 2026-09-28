#!/usr/bin/env bash
# Gestos do trackpad estilo macOS com o Touchégg 2.x e 4 áreas de trabalho (Spaces).
# No Plasma 5 em X11 o KDE não tem gestos próprios. O touchegg do repositório do
# Ubuntu é a versão 1.x antiga; instale a 2.x do PPA (pede sudo):
#   sudo add-apt-repository ppa:touchegg/stable && sudo apt install touchegg
source "$(dirname "$0")/lib.sh"

DESKTOPS="${DESKTOPS:-4}"

backup ~/.config/touchegg/touchegg.conf ~/.config/kwinrc

log "Instalando ~/.config/touchegg/touchegg.conf"
install -Dm644 "$REPO_DIR/files/touchegg.conf" ~/.config/touchegg/touchegg.conf

if [ "$($KREAD --file kwinrc --group Desktops --key Number --default 1)" -lt "$DESKTOPS" ]; then
    log "Criando $DESKTOPS áreas de trabalho em uma linha"
    $KWRITE --file kwinrc --group Desktops --key Number "$DESKTOPS"
    $KWRITE --file kwinrc --group Desktops --key Rows 1
fi
# O reconfigure do KWin não relê o número de áreas; cria as que faltam por D-Bus
VDM="org.kde.KWin /VirtualDesktopManager org.kde.KWin.VirtualDesktopManager"
n=$($QDBUS $VDM.count 2>/dev/null || echo "$DESKTOPS")
while [ "$n" -lt "$DESKTOPS" ]; do
    $QDBUS $VDM.createDesktop "$n" "Área $((n + 1))" >/dev/null
    n=$((n + 1))
done

if ! command -v touchegg >/dev/null; then
    log "touchegg não instalado; a configuração vale depois que você instalar."
elif touchegg --help 2>&1 | grep -q -- --daemon; then
    # O cliente relê o arquivo sozinho; só garante que ele está rodando
    pgrep -u "$USER" -x touchegg >/dev/null || (setsid touchegg >/dev/null 2>&1 &)
else
    log "Aviso: touchegg 1.x instalado (repositório do Ubuntu). Instale a 2.x do PPA."
fi
