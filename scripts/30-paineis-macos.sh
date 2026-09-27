#!/usr/bin/env bash
# Barra superior com Menu global + dock inferior oculta
source "$(dirname "$0")/lib.sh"

backup ~/.config/plasma-org.kde.plasma.desktop-appletsrc ~/.config/plasmashellrc

log "Aplicando layout de painéis"
$QDBUS org.kde.plasmashell /PlasmaShell evaluateScript "$(cat "$REPO_DIR/files/layout-macos.js")"

# A bandeja do sistema foi recriada: sem reiniciar, as teclas de volume param
log "Reiniciando plasmashell (reativa as teclas de volume)"
restart_plasmashell
echo "teclas de volume ativas: $($QDBUS org.kde.kglobalaccel /component/kmix org.kde.kglobalaccel.Component.isActive 2>/dev/null || echo '?')"
