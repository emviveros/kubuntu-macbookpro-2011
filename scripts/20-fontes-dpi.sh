#!/usr/bin/env bash
# Fontes 9 pt com DPI 88 e ícones de barra de ferramentas 16 px (KDE/Qt e GTK).
# No Wayland o DPI forçado não vale para os apps nativos: usa o tamanho
# equivalente em pontos (9 × 88/96 ≈ 8,3 pt) e deixa o DPI no automático.
source "$(dirname "$0")/lib.sh"

backup ~/.config/kdeglobals ~/.config/kcmfonts
mkdir -p "$BACKUP_DIR"
{
    gsettings get org.gnome.desktop.interface font-name
    gsettings get org.gnome.desktop.interface monospace-font-name
} > "$BACKUP_DIR/gtk-fonts.txt" 2>/dev/null || true

if is_wayland; then
    F9=8.3; F8=7.3; F7=6.4
else
    F9=9; F8=8; F7=7
fi

log "Fontes KDE/Qt (${F9} pt)"
$KWRITE --file kdeglobals --group General --key font                 "Noto Sans,$F9,-1,5,50,0,0,0,0,0"
$KWRITE --file kdeglobals --group General --key menuFont             "Noto Sans,$F9,-1,5,50,0,0,0,0,0"
$KWRITE --file kdeglobals --group General --key toolBarFont          "Noto Sans,$F8,-1,5,50,0,0,0,0,0"
$KWRITE --file kdeglobals --group General --key smallestReadableFont "Noto Sans,$F7,-1,5,50,0,0,0,0,0"
$KWRITE --file kdeglobals --group General --key fixed                "Hack,$F9,-1,5,50,0,0,0,0,0"
# A fonte do título (10-janelas.sh) acompanha a escala
$KWRITE --file kdeglobals --group WM --key activeFont                "Noto Sans,$F8,-1,5,50,0,0,0,0,0"

log "Ícones das barras de ferramentas: 16 px"
$KWRITE --file kdeglobals --group MainToolbarIcons --key Size 16
$KWRITE --file kdeglobals --group ToolbarIcons     --key Size 16
$KWRITE --file kdeglobals --group SmallIcons       --key Size 16

if is_wayland; then
    # O kscreen usa esta chave para os apps X11 (Xwayland); com as fontes já
    # reduzidas, 88 os deixaria menores que os outros
    log "DPI automático (as fontes já estão no tamanho equivalente a 88 DPI)"
    $KWRITE --file kcmfonts --group General --key forceFontDPI --delete
else
    log "DPI forçado: 88 (vale para KDE, GTK, Firefox e Chrome no X11)"
    $KWRITE --file kcmfonts --group General --key forceFontDPI 88
    echo "Xft.dpi: 88" | xrdb -merge
fi

log "Fontes GTK"
gsettings set org.gnome.desktop.interface font-name "Noto Sans $F9"
gsettings set org.gnome.desktop.interface monospace-font-name "Hack $F9"

# Avisa apps KDE abertos para recarregar fontes e ícones
dbus-send --session --type=signal /KGlobalSettings org.kde.KGlobalSettings.notifyChange int32:1 int32:0 || true
dbus-send --session --type=signal /KIconLoader org.kde.KIconLoader.iconChanged int32:0 || true
reconfigure_kwin
log "Efeito completo só após sair e entrar na sessão."
