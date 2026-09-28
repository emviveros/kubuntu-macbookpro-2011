#!/usr/bin/env bash
# Teclado estilo macOS com o Toshy: ⌘ como Ctrl dos apps, Option como Alt,
# ⌘+Shift+3/4/5 para capturas e Espaço/⌘+Y para pré-visualizar no Dolphin.
# Pré-requisitos (pedem sudo, instale antes; ver docs/alteracoes.md):
#   Toshy (github.com/RedBearAK/toshy) e: sudo apt install gnome-sushi xclip xdotool
source "$(dirname "$0")/lib.sh"

CFG=~/.config/toshy/toshy_config.py
if [ ! -f "$CFG" ]; then
    log "Toshy não instalado ($CFG não existe); pulando. Veja docs/alteracoes.md."
    exit 0
fi
for c in sushi xclip xdotool; do
    command -v $c >/dev/null || log "Aviso: '$c' não instalado; a pré-visualização no Dolphin não vai funcionar."
done

backup "$CFG" ~/.config/mimeapps.list ~/.config/autostart/tracker-miner-fs-3.desktop

# O gnome-sushi depende do Nautilus, que depende do indexador tracker-miner-fs.
# Os pacotes ficam, mas o indexador não roda e o Dolphin continua abrindo as
# pastas (ver docs/problemas-conhecidos.md).
if [ -f /etc/xdg/autostart/tracker-miner-fs-3.desktop ]; then
    log "Desativando o indexador tracker-miner-fs (veio com o Nautilus)"
    systemctl --user mask --now tracker-miner-fs-3.service >/dev/null 2>&1 || true
    mkdir -p ~/.config/autostart
    printf '[Desktop Entry]\nType=Application\nName=Tracker File System Miner\nHidden=true\n' \
        > ~/.config/autostart/tracker-miner-fs-3.desktop
fi
if [ "$(xdg-mime query default inode/directory)" != org.kde.dolphin.desktop ]; then
    log "Dolphin como gerenciador de arquivos padrão"
    xdg-mime default org.kde.dolphin.desktop inode/directory
fi

log "Instalando ~/.local/bin/quicklook-dolphin"
install -Dm755 "$REPO_DIR/files/quicklook-dolphin" ~/.local/bin/quicklook-dolphin

# Insere cada trecho dentro da "slice" do Toshy (preservada em reinstalações),
# entre marcas próprias, substituindo a versão anterior se já existir.
log "Inserindo atalhos nas slices do $CFG"
python3 - "$CFG" "$REPO_DIR/files/toshy" <<'EOF'
import re, sys, pathlib
cfg, src = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
text = cfg.read_text()
for slice_name in ("user_custom_functions", "user_apps"):
    block = (src / f"{slice_name}.py").read_text().rstrip("\n")
    begin, end = "# >>> kubuntu-macbookpro-2011", "# <<< kubuntu-macbookpro-2011"
    ours = f"{begin}\n{block}\n{end}\n"
    old = re.compile(re.escape(begin) + r".*?" + re.escape(end) + r"\n", re.S)
    m = re.search(r"(###  SLICE_MARK_START: " + slice_name + r"  ###.*?\n)(.*?)(###  SLICE_MARK_END: " + slice_name + r"  ###)", text, re.S)
    if not m:
        sys.exit(f"slice {slice_name} não encontrada em {cfg}")
    body = old.sub("", m.group(2)).rstrip("\n") + "\n\n" + ours + "\n"
    text = text[:m.start(2)] + body + text[m.end(2):]
cfg.write_text(text)
EOF

log "Reiniciando o Toshy"
if command -v toshy-services-restart >/dev/null; then
    toshy-services-restart >/dev/null 2>&1 || true
else
    ~/.local/bin/toshy-services-restart >/dev/null 2>&1 || true
fi
