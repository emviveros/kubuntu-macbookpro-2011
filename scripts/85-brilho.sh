#!/usr/bin/env bash
# Brilho no mínimo apaga a tela (luz de fundo em 0), como no Plasma 5.
# No Plasma 6 o KWin nunca grava 0 na luz de fundo; a tecla de diminuir o
# brilho passa a chamar ~/.local/bin/brilho-tela (ver files/brilho-tela).
source "$(dirname "$0")/lib.sh"

if [ "$PLASMA" != 6 ]; then
    log "Plasma 5: o mínimo já apaga a tela; nada a fazer."; exit 0
fi

backup ~/.config/kglobalshortcutsrc

log "Instalando ~/.local/bin/brilho-tela"
install -Dm755 "$REPO_DIR/files/brilho-tela" ~/.local/bin/brilho-tela

log "Instalando o serviço brilho-tela.service e o script do KWin brilho-tela"
install -Dm644 "$REPO_DIR/files/brilho-tela.service" ~/.config/systemd/user/brilho-tela.service
systemctl --user daemon-reload

# A tecla sai do Plasma (powerdevil) e vai para o script do KWin, que chama o
# serviço. Um "comando" novo no kglobalaccel só valeria depois de reiniciar a
# sessão; o script do KWin vale na hora.
log "Tecla de diminuir o brilho → brilho-tela (tira a do Plasma)"
python3 - <<'PY'
import dbus
k = dbus.Interface(dbus.SessionBus().get_object("org.kde.kglobalaccel", "/kglobalaccel"),
                   "org.kde.KGlobalAccel")
k.setForeignShortcut(["org_kde_powerdevil", "Decrease Screen Brightness",
                      "Gerenciamento de energia", "Reduzir o brilho da tela"],
                     dbus.Array([], signature="i"))
PY
kpackagetool6 --type KWin/Script --upgrade "$REPO_DIR/files/kwin-brilho-tela" >/dev/null 2>&1 ||
    kpackagetool6 --type KWin/Script --install "$REPO_DIR/files/kwin-brilho-tela" >/dev/null
$KWRITE --file kwinrc --group Plugins --key brilho-telaEnabled true
reconfigure_kwin
