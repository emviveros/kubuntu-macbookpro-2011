#!/usr/bin/env bash
# Barras de título compactas e janelas maximizadas sem barra de título
source "$(dirname "$0")/lib.sh"

backup ~/.config/kwinrc ~/.config/breezerc ~/.config/kdeglobals

log "Janelas maximizadas sem barra de título"
$KWRITE --file kwinrc --group Windows --key BorderlessMaximizedWindows true

log "Decoração Breeze: botões pequenos, sem bordas"
$KWRITE --file breezerc --group Windeco --key ButtonSize ButtonSmall
$KWRITE --file kwinrc --group org.kde.kdecoration2 --key BorderSize None
$KWRITE --file kwinrc --group org.kde.kdecoration2 --key BorderSizeAuto false

log "Fonte do título da janela: 8 pt (a altura da barra acompanha)"
$KWRITE --file kdeglobals --group WM --key activeFont "Noto Sans,8,-1,5,50,0,0,0,0,0"

reconfigure_kwin
