// Tecla de diminuir o brilho → serviço brilho-tela.service (~/.local/bin/brilho-tela),
// que apaga a luz de fundo no mínimo. O atalho fica no KWin porque um comando
// novo no kglobalaccel só passa a valer depois de reiniciar a sessão.
import QtQuick
import org.kde.kwin

Item {
    DBusCall {
        id: servico
        service: "org.freedesktop.systemd1"
        path: "/org/freedesktop/systemd1"
        dbusInterface: "org.freedesktop.systemd1.Manager"
        method: "StartUnit"
        arguments: ["brilho-tela.service", "replace"]
    }
    ShortcutHandler {
        name: "Diminuir o brilho (brilho-tela)"
        text: "Diminuir o brilho (apaga no mínimo)"
        sequence: "Monitor Brightness Down"
        onActivated: servico.call()
    }
}
