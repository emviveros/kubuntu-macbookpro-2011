#!/usr/bin/env bash
# Dolphin em modo Compacto em todas as pastas, ícones de 16 px
source "$(dirname "$0")/lib.sh"

if pgrep -x dolphin >/dev/null; then
    log "Feche o Dolphin antes (ele reescreve a configuração ao sair)."; exit 1
fi

D=~/.local/share/dolphin/view_properties/global/.directory
mkdir -p "$(dirname "$D")"
backup ~/.config/dolphinrc "$(dirname "$D")"   # cp -a leva junto o atributo estendido

NOW=$(date +%Y,%-m,%-d,%-H,%-M,%-S.000)
log "Mesmo modo de visualização para todas as pastas"
$KWRITE --file dolphinrc --group General --key GlobalViewProps true
$KWRITE --file dolphinrc --group General --key ViewPropsTimestamp "$NOW"

log "Modo Compacto (ViewMode=2), sem miniaturas"
# O Dolphin 24.08 em diante guarda isso num atributo estendido da pasta
# (user.kde.fm.viewproperties#1, mesmo conteúdo do .directory) e apaga o
# .directory sem ler; os mais antigos só leem o .directory
PROPS="[Dolphin]
PreviewsShown=false
Timestamp=$NOW
Version=4
ViewMode=2
"
if python3 -c 'import os, sys; os.setxattr(sys.argv[1], "user.kde.fm.viewproperties#1", sys.argv[2].encode())' \
        "$(dirname "$D")" "$PROPS" 2>/dev/null; then
    rm -f "$D"
else
    printf %s "$PROPS" > "$D"
fi

log "Ícones de 16 px no modo Compacto e no painel Locais"
$KWRITE --file dolphinrc --group CompactMode --key IconSize 16
$KWRITE --file dolphinrc --group PlacesPanel --key IconSize 16
