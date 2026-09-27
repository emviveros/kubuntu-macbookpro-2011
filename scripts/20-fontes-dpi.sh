#!/usr/bin/env bash
# Fontes 9 pt, DPI 88 e ícones de barra de ferramentas 16 px (KDE/Qt e GTK)
source "$(dirname "$0")/lib.sh"
require_x11

backup ~/.config/kdeglobals ~/.config/kcmfonts
mkdir -p "$BACKUP_DIR"
{
    gsettings get org.gnome.desktop.interface font-name
    gsettings get org.gnome.desktop.interface monospace-font-name
} > "$BACKUP_DIR/gtk-fonts.txt" 2>/dev/null || true

log "Fontes KDE/Qt"
$KWRITE --file kdeglobals --group General --key font                 "Noto Sans,9,-1,5,50,0,0,0,0,0"
$KWRITE --file kdeglobals --group General --key menuFont             "Noto Sans,9,-1,5,50,0,0,0,0,0"
$KWRITE --file kdeglobals --group General --key toolBarFont          "Noto Sans,8,-1,5,50,0,0,0,0,0"
$KWRITE --file kdeglobals --group General --key smallestReadableFont "Noto Sans,7,-1,5,50,0,0,0,0,0"
$KWRITE --file kdeglobals --group General --key fixed                "Hack,9,-1,5,50,0,0,0,0,0"

log "Ícones das barras de ferramentas: 16 px"
$KWRITE --file kdeglobals --group MainToolbarIcons --key Size 16
$KWRITE --file kdeglobals --group ToolbarIcons     --key Size 16
$KWRITE --file kdeglobals --group SmallIcons       --key Size 16

log "DPI forçado: 88 (vale para KDE, GTK, Firefox e Chrome no X11)"
$KWRITE --file kcmfonts --group General --key forceFontDPI 88
echo "Xft.dpi: 88" | xrdb -merge

log "Fontes GTK"
gsettings set org.gnome.desktop.interface font-name 'Noto Sans 9'
gsettings set org.gnome.desktop.interface monospace-font-name 'Hack 9'

# Avisa apps KDE abertos para recarregar fontes e ícones
dbus-send --session --type=signal /KGlobalSettings org.kde.KGlobalSettings.notifyChange int32:1 int32:0 || true
dbus-send --session --type=signal /KIconLoader org.kde.KIconLoader.iconChanged int32:0 || true
reconfigure_kwin
log "Efeito completo só após sair e entrar na sessão."
