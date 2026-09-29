#!/usr/bin/env bash
# Barras de título compactas (mantidas nas janelas maximizadas)
source "$(dirname "$0")/lib.sh"

backup ~/.config/kwinrc ~/.config/breezerc ~/.config/kdeglobals

# Sem barra de título ao maximizar some também fechar/minimizar/restaurar,
# e o Plasma 5 não tem widget nativo que os leve para a barra superior.
log "Janelas maximizadas mantêm a barra de título"
$KWRITE --file kwinrc --group Windows --key BorderlessMaximizedWindows false

log "Decoração Breeze: botões pequenos, sem bordas"
$KWRITE --file breezerc --group Windeco --key ButtonSize ButtonSmall
$KWRITE --file kwinrc --group org.kde.kdecoration2 --key BorderSize None
$KWRITE --file kwinrc --group org.kde.kdecoration2 --key BorderSizeAuto false

# No Wayland, 7,3 pt equivale aos 8 pt com DPI 88 do X11 (ver 20-fontes-dpi.sh)
if is_wayland; then TITLE=7.3; else TITLE=8; fi
log "Fonte do título da janela: $TITLE pt (a altura da barra acompanha)"
$KWRITE --file kdeglobals --group WM --key activeFont "Noto Sans,$TITLE,-1,5,50,0,0,0,0,0"

reconfigure_kwin
