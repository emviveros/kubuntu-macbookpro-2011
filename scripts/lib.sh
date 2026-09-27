# Funções comuns. Use com: source "$(dirname "$0")/lib.sh"
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.config/backup-tela-$(date +%Y%m%d-%H%M%S)}"

# Plasma 5 usa ferramentas com sufixo 5, Plasma 6 com sufixo 6
if command -v kwriteconfig6 >/dev/null; then
    KWRITE=kwriteconfig6; KREAD=kreadconfig6; KQUIT=kquitapp6; KSTART=kstart
    QDBUS=$(command -v qdbus6 || command -v qdbus)
    PLASMA=6
else
    KWRITE=kwriteconfig5; KREAD=kreadconfig5; KQUIT=kquitapp5; KSTART=kstart5
    QDBUS=qdbus
    PLASMA=5
fi

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

# Copia arquivos para o backup antes de alterar, mantendo o caminho relativo
# ao $HOME (restore.sh copia tudo de volta). Ignora os que não existem.
backup() {
    mkdir -p "$BACKUP_DIR"
    for f in "$@"; do
        [ -e "$f" ] || continue
        (cd "$HOME" && cp -a --parents "${f#"$HOME"/}" "$BACKUP_DIR/")
    done
}

require_x11() {
    if [ "${XDG_SESSION_TYPE:-}" != "x11" ]; then
        log "Aviso: sessão ${XDG_SESSION_TYPE:-?}; ajustes de DPI/xrdb só valem em X11."
    fi
}

reconfigure_kwin() {
    $QDBUS org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
}

# Reinicia o plasmashell. Necessário depois de recriar a bandeja do sistema,
# senão as teclas de volume ficam inativas (ver docs/problemas-conhecidos.md).
restart_plasmashell() {
    $KQUIT plasmashell >/dev/null 2>&1 || true
    for _ in $(seq 20); do pgrep -x plasmashell >/dev/null || break; sleep 0.5; done
    (setsid $KSTART plasmashell >/dev/null 2>&1 &)
    for _ in $(seq 30); do
        [ "$($QDBUS org.kde.kglobalaccel /component/kmix org.kde.kglobalaccel.Component.isActive 2>/dev/null)" = true ] && break
        sleep 1
    done
}
