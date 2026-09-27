#!/usr/bin/env bash
# Dolphin em modo Compacto em todas as pastas, ícones de 16 px
source "$(dirname "$0")/lib.sh"

if pgrep -x dolphin >/dev/null; then
    log "Feche o Dolphin antes (ele reescreve a configuração ao sair)."; exit 1
fi

D=~/.local/share/dolphin/view_properties/global/.directory
mkdir -p "$(dirname "$D")"
backup ~/.config/dolphinrc "$D"

NOW=$(date +%Y,%-m,%-d,%-H,%-M,%-S.000)
log "Mesmo modo de visualização para todas as pastas"
$KWRITE --file dolphinrc --group General --key GlobalViewProps true
$KWRITE --file dolphinrc --group General --key ViewPropsTimestamp "$NOW"

log "Modo Compacto (ViewMode=2), sem miniaturas"
$KWRITE --file "$D" --group Dolphin --key ViewMode 2
$KWRITE --file "$D" --group Dolphin --key PreviewsShown false
$KWRITE --file "$D" --group Dolphin --key Timestamp "$NOW"

log "Ícones de 16 px no modo Compacto e no painel Locais"
$KWRITE --file dolphinrc --group CompactMode --key IconSize 16
$KWRITE --file dolphinrc --group PlacesPanel --key IconSize 16
