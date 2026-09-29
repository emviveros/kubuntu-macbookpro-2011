// Gestos estilo macOS no KWin do Plasma 6 (Wayland). O Touchégg não funciona
// no Wayland; o próprio KWin reconhece os gestos e este script diz o que fazem.
// O KWin já trata 4 dedos para cima/baixo/lados (Visão geral, trocar de área);
// aqui ficam os de 3 dedos e as pinças de 4 dedos. Também define o atalho de
// App Exposé, que o Plasma 6 não tem mais (Ctrl+↓ com o Toshy).
import QtQuick
import org.kde.kwin

Item {
    // O D-Bus espera uma lista de textos (QStringList); um array JS comum vira
    // uma lista de variantes e a chamada é recusada. Uma propriedade
    // list<string> vira QStringList.
    property list<string> idsExposicao

    // Próxima/anterior área, sem dar a volta (como no macOS)
    function mudarArea(passo) {
        const areas = Workspace.desktops;
        const i = areas.indexOf(Workspace.currentDesktop) + passo;
        if (i >= 0 && i < areas.length) Workspace.currentDesktop = areas[i];
    }

    // App Exposé: janelas normais do app ativo, na área atual, com o efeito
    // "Apresentar janelas" do KWin
    function janelasDoApp() {
        const ativa = Workspace.activeWindow;
        if (!ativa) return;
        const ids = Workspace.stackingOrder
            .filter(w => w.normalWindow && !w.minimized &&
                         w.resourceClass === ativa.resourceClass &&
                         (w.onAllDesktops || w.desktops.includes(Workspace.currentDesktop)))
            .map(w => w.internalId.toString());
        idsExposicao = ids;
        exposicao.arguments = [idsExposicao];
        exposicao.call();
    }

    DBusCall {
        id: exposicao
        service: "org.kde.KWin"
        path: "/org/kde/KWin/Effect/WindowView1"
        dbusInterface: "org.kde.KWin.Effect.WindowView1"
        method: "activate"
    }

    ShortcutHandler {
        name: "App Expose (gestos-macos)"
        text: "Janelas do app atual (App Exposé)"
        sequence: "Meta+Down"
        onActivated: janelasDoApp()
    }

    DBusCall {
        id: atalhoKWin
        service: "org.kde.kglobalaccel"
        path: "/component/kwin"
        dbusInterface: "org.kde.kglobalaccel.Component"
        method: "invokeShortcut"
    }
    DBusCall {
        id: lancador
        service: "org.kde.plasmashell"
        path: "/PlasmaShell"
        dbusInterface: "org.kde.PlasmaShell"
        method: "activateLauncherMenu"
    }

    // 3 dedos para cima: Mission Control (Visão geral)
    SwipeGestureHandler {
        direction: SwipeGestureHandler.Direction.Up
        fingerCount: 3
        deviceType: SwipeGestureHandler.Device.Touchpad
        onActivated: { atalhoKWin.arguments = ["Overview"]; atalhoKWin.call(); }
    }
    // 3 dedos para baixo: App Exposé (janelas do app atual)
    SwipeGestureHandler {
        direction: SwipeGestureHandler.Direction.Down
        fingerCount: 3
        deviceType: SwipeGestureHandler.Device.Touchpad
        onActivated: janelasDoApp()
    }
    // 3 dedos para os lados: trocar de área (o conteúdo acompanha os dedos)
    SwipeGestureHandler {
        direction: SwipeGestureHandler.Direction.Left
        fingerCount: 3
        deviceType: SwipeGestureHandler.Device.Touchpad
        onActivated: mudarArea(1)
    }
    SwipeGestureHandler {
        direction: SwipeGestureHandler.Direction.Right
        fingerCount: 3
        deviceType: SwipeGestureHandler.Device.Touchpad
        onActivated: mudarArea(-1)
    }
    // Pinça com 4 dedos: Launchpad (lançador de aplicativos)
    PinchGestureHandler {
        direction: PinchGestureHandler.Direction.Contracting
        fingerCount: 4
        onActivated: lancador.call()
    }
    // Abrir 4 dedos: mostrar a área de trabalho
    PinchGestureHandler {
        direction: PinchGestureHandler.Direction.Expanding
        fingerCount: 4
        onActivated: Workspace.showingDesktop = !Workspace.showingDesktop
    }
}
