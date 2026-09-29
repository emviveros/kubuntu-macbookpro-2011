#!/usr/bin/env bash
# Pacotes de que os outros scripts dependem. Só instala o que falta; pede a
# senha do sudo uma vez. O Google Chrome (60-chrome.sh) fica de fora: instale-o
# do site do Google.
source "$(dirname "$0")/lib.sh"

# appmenu-gtk3-module: Menu global em apps GTK (40)
# gnome-sushi, xclip, xdotool: Quick Look no Dolphin (70)
# python3-dbus: atalhos gravados pelo kglobalaccel (80)
# vlc, plasma-browser-integration: teclas de mídia (docs/alteracoes.md, seção 8)
# git, python3-venv: instalação do Toshy
APT=(appmenu-gtk3-module gnome-sushi xclip xdotool python3-dbus vlc
     plasma-browser-integration git python3-venv)

missing=()
for p in "${APT[@]}"; do
    dpkg-query -W -f='${Status}' "$p" 2>/dev/null | grep -q "ok installed" || missing+=("$p")
done

# O touchegg do Ubuntu é a versão 1.x, que não funciona; a 2.x vem do PPA do projeto
touchegg_ok() { touchegg --help 2>&1 | grep -q -- --daemon; }
if ! touchegg_ok; then
    if ! grep -rqs "touchegg/stable" /etc/apt/sources.list.d/; then
        log "Adicionando o PPA do Touchégg (pede a senha do sudo)"
        sudo add-apt-repository -y ppa:touchegg/stable
    fi
    missing+=(touchegg)
fi

if [ ${#missing[@]} -gt 0 ]; then
    log "Instalando: ${missing[*]}"
    sudo apt-get update -qq
    sudo apt-get install -y "${missing[@]}"
else
    log "Pacotes apt já instalados"
fi
if touchegg_ok && ! systemctl is-enabled --quiet touchegg.service; then
    sudo systemctl enable --now touchegg.service
fi

# Toshy: teclado estilo macOS (70). O instalador é interativo e pede sudo.
if [ ! -f ~/.config/toshy/toshy_config.py ]; then
    log "Instalando o Toshy em ~/.local/src/toshy"
    [ -d ~/.local/src/toshy ] || git clone https://github.com/RedBearAK/toshy.git ~/.local/src/toshy
    (cd ~/.local/src/toshy && ./setup_toshy.py install)
    log "O Toshy só pega o teclado depois de reiniciar o computador."
else
    log "Toshy já instalado"
fi
