#!/usr/bin/env bash
# Google Chrome com escala 0.85 (atalhos .desktop do usuário)
# UBUNTU_MENUPROXY=0 desliga o appmenu-gtk-module só no Chrome: com o Menu global
# ativo ele faz o Chrome travar ao abrir (ver docs/problemas-conhecidos.md).
# XDG_CACHE_HOME separado: o Chrome 154 regrava o cache de fontes do usuário num
# formato que o fontconfig do sistema não lê, e o plasmashell cai no login
# seguinte (ver docs/problemas-conhecidos.md).
source "$(dirname "$0")/lib.sh"

SCALE="${CHROME_SCALE:-0.85}"
CACHE="$HOME/.cache/google-chrome-xdg"
mkdir -p ~/.local/share/applications "$CACHE"

log "Instalando ~/.config/plasma-workspace/env/fontconfig-cache-guard.sh"
install -Dm644 "$REPO_DIR/files/fontconfig-cache-guard.sh" ~/.config/plasma-workspace/env/fontconfig-cache-guard.sh

found=0
for f in google-chrome.desktop com.google.Chrome.desktop; do
    src=/usr/share/applications/$f
    [ -f "$src" ] || continue
    found=1
    log "Criando ~/.local/share/applications/$f (escala $SCALE)"
    sed "s|^Exec=/usr/bin/google-chrome-stable|Exec=env UBUNTU_MENUPROXY=0 XDG_CACHE_HOME=$CACHE /usr/bin/google-chrome-stable --force-device-scale-factor=$SCALE|" \
        "$src" > ~/.local/share/applications/$f
done

if [ $found = 0 ]; then log "Chrome não instalado; nada a fazer."; exit 0; fi
kbuildsycoca${PLASMA} >/dev/null 2>&1 || true
log "Feche o Chrome por completo (Ctrl+Shift+Q) e abra pelo ícone."
