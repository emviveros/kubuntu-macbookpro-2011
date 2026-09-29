#!/usr/bin/env bash
# Gestos do trackpad estilo macOS e 4 áreas de trabalho (Spaces).
# - X11 (Plasma 5): o KDE não tem gestos próprios; usa o Touchégg 2.x do PPA
#   (o touchegg do Ubuntu é a versão 1.x antiga, que não funciona).
# - Wayland (Plasma 6): o Touchégg não funciona; o próprio KWin reconhece os
#   gestos e o script files/kwin-gestos-macos diz o que cada um faz.
source "$(dirname "$0")/lib.sh"

DESKTOPS="${DESKTOPS:-4}"

backup ~/.config/touchegg/touchegg.conf ~/.config/kwinrc ~/.config/kglobalshortcutsrc

if is_wayland; then
    log "Instalando o script do KWin gestos-macos (gestos de 3 dedos e pinças)"
    kpackagetool6 --type KWin/Script --upgrade "$REPO_DIR/files/kwin-gestos-macos" >/dev/null 2>&1 ||
        kpackagetool6 --type KWin/Script --install "$REPO_DIR/files/kwin-gestos-macos" >/dev/null
    $KWRITE --file kwinrc --group Plugins --key gestos-macosEnabled true
else
    log "Instalando ~/.config/touchegg/touchegg.conf"
    install -Dm644 "$REPO_DIR/files/touchegg.conf" ~/.config/touchegg/touchegg.conf
fi

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

# Ctrl+setas como no macOS. Nos apps gráficos o Toshy transforma o Ctrl físico
# em Meta, e Meta+setas encaixava a janela na metade da tela; no terminal o
# Toshy já manda Ctrl+Meta+esquerda/direita, que continuam valendo.
log "Ctrl+setas: trocar de área, Visão geral e janelas do app"
python3 - "$PLASMA" <<'PY'
import dbus, sys
k = dbus.Interface(dbus.SessionBus().get_object("org.kde.kglobalaccel", "/kglobalaccel"),
                   "org.kde.KGlobalAccel")
META, CTRL = 0x10000000, 0x04000000
LEFT, UP, RIGHT, DOWN, W, F7 = 0x01000012, 0x01000013, 0x01000014, 0x01000015, 0x57, 0x01000036
shortcuts = {
    "Window Quick Tile Left": [], "Window Quick Tile Right": [],
    "Window Quick Tile Top": [], "Window Quick Tile Bottom": [],
    "Switch One Desktop to the Left": [META | CTRL | LEFT, META | LEFT],
    "Switch One Desktop to the Right": [META | CTRL | RIGHT, META | RIGHT],
    "Overview": [META | W, META | UP],
}
# No Plasma 6 o KWin não tem mais o atalho ExposeClass; o App Exposé vem do
# script gestos-macos, que já registra Meta+↓
if sys.argv[1] == "5":
    shortcuts["ExposeClass"] = [CTRL | F7, META | DOWN]
for action, keys in shortcuts.items():
    k.setForeignShortcut(["kwin", action, "KWin", action], dbus.Array(keys, signature="i"))
PY
# Sem isso, as teclas novas ficam registradas mas não disparam no X11
reconfigure_kwin

if is_wayland; then
    :
elif ! command -v touchegg >/dev/null; then
    log "touchegg não instalado; a configuração vale depois que você instalar."
elif touchegg --help 2>&1 | grep -q -- --daemon; then
    # O cliente relê o arquivo sozinho; só garante que ele está rodando
    pgrep -u "$USER" -x touchegg >/dev/null || (setsid touchegg >/dev/null 2>&1 &)
else
    log "Aviso: touchegg 1.x instalado (repositório do Ubuntu). Instale a 2.x do PPA."
fi
