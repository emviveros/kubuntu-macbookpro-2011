// Quick Look no Wayland (files/quicklook-wayland). A pré-visualização do sushi
// toma o foco ao abrir e a cada arquivo novo. Este script a mantém por cima e
// devolve o foco à janela de origem (Dolphin ou Área de trabalho), para as
// setas continuarem mudando a seleção dela, como no Finder. Quando ela fecha,
// por qualquer meio, avisa o quicklook-wayland (quicklook-fechou.service).
import QtQuick
import org.kde.kwin

Item {
    property var origem: null

    function ehPreview(w) {
        return w && w.resourceClass === "org.gnome.NautilusPreviewer";
    }

    Connections {
        target: Workspace
        function onWindowAdded(w) {
            if (ehPreview(w)) w.keepAbove = true;
        }
        function onWindowActivated(w) {
            if (!w) return;
            if (!ehPreview(w)) {
                origem = w;
            } else if (origem && Workspace.stackingOrder.includes(origem)) {
                const o = origem;
                Qt.callLater(() => { Workspace.activeWindow = o; });
            }
        }
        function onWindowRemoved(w) {
            if (w === origem) origem = null;
            if (ehPreview(w)) fechou.call();
        }
    }

    DBusCall {
        id: fechou
        service: "org.freedesktop.systemd1"
        path: "/org/freedesktop/systemd1"
        dbusInterface: "org.freedesktop.systemd1.Manager"
        method: "StartUnit"
        arguments: ["quicklook-fechou.service", "replace"]
    }
}
