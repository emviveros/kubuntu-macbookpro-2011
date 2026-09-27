#!/usr/bin/env bash
# Aplica todas as alterações em ordem. Para aplicar só uma parte:
#   ./apply.sh 10 30      (roda só os scripts que começam com 10 e 30)
set -euo pipefail
cd "$(dirname "$0")"

export BACKUP_DIR="$HOME/.config/backup-tela-$(date +%Y%m%d-%H%M%S)"

for s in scripts/[0-9]*.sh; do
    n=$(basename "$s"); n=${n%%-*}
    if [ $# -gt 0 ] && [[ " $* " != *" $n "* ]]; then continue; fi
    echo; echo "### $s"
    bash "$s"
done

echo
echo "Backup em: $BACKUP_DIR"
echo "Para desfazer: scripts/restore.sh $BACKUP_DIR"
echo "Saia e entre na sessão para tudo valer (DPI, fontes GTK, menu global GTK)."
