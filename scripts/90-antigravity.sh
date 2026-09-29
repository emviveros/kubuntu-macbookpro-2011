#!/usr/bin/env bash
# Google Antigravity: o app (Antigravity 2.0), a IDE e o CLI, lado a lado.
#   antigravity       app Antigravity 2.0          ~/.local/share/antigravity/app
#   antigravity-ide   Antigravity IDE (abre pastas: antigravity-ide .)
#   agy               Antigravity CLI (instalador oficial, atualiza sozinho)
# O app e a IDE não se atualizam sozinhos no Linux: para atualizar, troque as
# URLs abaixo pelas de https://antigravity.google/download e rode de novo.
# Os dois trazem um fontconfig mais novo que o do sistema; os lançadores apontam
# o cache de fontes deles para outra pasta (files/antigravity-fonts.conf), senão
# o cache do sistema se mistura, como aconteceu com o Chrome 154. E, como o
# Chrome, abrem com UBUNTU_MENUPROXY=0 (sem o módulo do Menu global do GTK).
source "$(dirname "$0")/lib.sh"

APP_URL="${ANTIGRAVITY_APP_URL:-https://storage.googleapis.com/antigravity-public/antigravity-hub/2.18.1-4945794252537856/linux-x64/Antigravity.tar.gz}"
IDE_URL="${ANTIGRAVITY_IDE_URL:-https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/2.5.5-4923483625488384/linux-x64/Antigravity%20IDE.tar.gz}"
CLI_URL="https://antigravity.google/cli/install.sh"

DEST="$HOME/.local/share/antigravity"
FONTS="$HOME/.config/antigravity/fonts.conf"
APPS="$HOME/.local/share/applications"
ICONS="$HOME/.local/share/icons/hicolor/512x512/apps"

if [ "$(uname -m)" != x86_64 ]; then
    log "Arquitetura $(uname -m): troque linux-x64 por linux-arm nas URLs."; exit 1
fi

backup ~/.bashrc ~/.profile ~/.zshrc ~/.config/fish/config.fish \
    "$APPS/antigravity.desktop" "$APPS/antigravity-ide.desktop" \
    ~/.local/bin/antigravity ~/.local/bin/antigravity-ide

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# Baixa e troca a pasta só se a URL mudou desde a última instalação
instalar() {  # nome url
    local nome=$1 url=$2
    if [ "$(cat "$DEST/$nome/.url" 2>/dev/null)" = "$url" ]; then
        log "$nome: já é a versão de $url"; return
    fi
    log "$nome: baixando $url"
    curl -fL --progress-bar -o "$TMP/$nome.tar.gz" "$url"
    mkdir -p "$TMP/$nome"
    tar -xzf "$TMP/$nome.tar.gz" -C "$TMP/$nome" --strip-components=1
    echo "$url" > "$TMP/$nome/.url"
    rm -rf "$DEST/$nome"
    mkdir -p "$DEST"
    mv "$TMP/$nome" "$DEST/$nome"
}

instalar app "$APP_URL"
instalar ide "$IDE_URL"

# CLI pelo instalador oficial. Ele grava ~/.local/bin/agy e ajusta o PATH no
# perfil do shell; depois o agy se atualiza sozinho.
if [ -x ~/.local/bin/agy ]; then
    log "agy: já instalado (atualiza sozinho)"
else
    log "agy: instalando pelo instalador oficial"
    curl -fsSL "$CLI_URL" | bash
fi

log "Instalando $FONTS"
install -Dm644 "$REPO_DIR/files/antigravity-fonts.conf" "$FONTS"

# Lançadores depois do agy, para nenhum instalador sobrescrever estes nomes
log "Instalando ~/.local/bin/antigravity e antigravity-ide"
mkdir -p ~/.local/bin
cat > ~/.local/bin/antigravity <<EOF
#!/bin/sh
# Antigravity 2.0 (scripts/90-antigravity.sh)
UBUNTU_MENUPROXY=0 FONTCONFIG_FILE="$FONTS" exec "$DEST/app/antigravity" "\$@"
EOF
cat > ~/.local/bin/antigravity-ide <<EOF
#!/bin/sh
# Antigravity IDE (scripts/90-antigravity.sh)
UBUNTU_MENUPROXY=0 FONTCONFIG_FILE="$FONTS" exec "$DEST/ide/bin/antigravity-ide" "\$@"
EOF
chmod 755 ~/.local/bin/antigravity ~/.local/bin/antigravity-ide

log "Ícones e atalhos no menu de aplicativos"
mkdir -p "$ICONS" "$APPS"
python3 - "$DEST/app/resources/app.asar" "$ICONS/antigravity.png" <<'PY'
# O ícone do app fica dentro do app.asar (formato do Electron)
import json, struct, sys
with open(sys.argv[1], 'rb') as f:
    _, tam_cabecalho = struct.unpack('<II', f.read(8))
    _, tam_json = struct.unpack('<II', f.read(8))
    cabecalho = json.loads(f.read(tam_json))
    base = 8 + tam_cabecalho
    item = cabecalho['files']['icon.png']
    f.seek(base + int(item['offset']))
    open(sys.argv[2], 'wb').write(f.read(item['size']))
PY
install -m644 "$DEST/ide/resources/app/resources/linux/code.png" "$ICONS/antigravity-ide.png"

cat > "$APPS/antigravity.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Antigravity
GenericName=Agentes de IA para programar
Comment=Google Antigravity 2.0
Exec=$HOME/.local/bin/antigravity %U
Icon=antigravity
Terminal=false
Categories=Development;
MimeType=x-scheme-handler/antigravity;
StartupWMClass=antigravity
StartupNotify=true
EOF
cat > "$APPS/antigravity-ide.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Antigravity IDE
GenericName=Editor de código
Comment=Google Antigravity IDE
Exec=$HOME/.local/bin/antigravity-ide %F
Icon=antigravity-ide
Terminal=false
Categories=Development;IDE;TextEditor;
MimeType=text/plain;inode/directory;x-scheme-handler/antigravity-ide;
Keywords=antigravity;vscode;editor;
StartupWMClass=antigravity-ide
StartupNotify=true
Actions=new-empty-window;

[Desktop Action new-empty-window]
Name=Nova janela vazia
Exec=$HOME/.local/bin/antigravity-ide --new-window %F
Icon=antigravity-ide
EOF

# O login do Google volta do navegador por estes endereços
xdg-mime default antigravity.desktop x-scheme-handler/antigravity
xdg-mime default antigravity-ide.desktop x-scheme-handler/antigravity-ide
update-desktop-database "$APPS" >/dev/null 2>&1 || true
kbuildsycoca${PLASMA} >/dev/null 2>&1 || true

# Sandbox do Chromium: precisa de "userns", bloqueado pelo AppArmor do Ubuntu
# 24.04. No Ubuntu 26.04 a restrição vem desligada e o perfil não é instalado.
PROFILE=/etc/apparmor.d/antigravity
if [ "$(sysctl -n kernel.apparmor_restrict_unprivileged_userns 2>/dev/null)" = 1 ] &&
   [ -d /etc/apparmor.d ] && ! cmp -s "$REPO_DIR/files/apparmor-antigravity" "$PROFILE"; then
    log "Instalando o perfil AppArmor $PROFILE (pede a senha do sudo)"
    sudo install -m644 "$REPO_DIR/files/apparmor-antigravity" "$PROFILE" &&
        sudo apparmor_parser -r "$PROFILE" ||
        log "Aviso: perfil não instalado; o Antigravity pode não abrir."
fi

case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) log "Aviso: ~/.local/bin não está no PATH desta sessão; abra um terminal novo." ;;
esac
log "Pronto: antigravity, antigravity-ide e agy. Entre com a conta Google na primeira abertura."
