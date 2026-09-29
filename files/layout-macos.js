// Layout estilo macOS para o Plasma (roda via PlasmaShell.evaluateScript).
// Idempotente: se já existe barra superior com Menu global, não cria outra.
//
// Resultado:
//   topo  (26 px): lançador | Menu global | espaço | bandeja | relógio
//   baixo (40 px): dock centralizada só com ícones das janelas, oculta automaticamente

function hasWidget(panel, type) {
    return panel.widgets().some(function (w) { return w.type == type; });
}

var all = panels();

var top = null;
all.forEach(function (p) {
    if (p.location == "top" && hasWidget(p, "org.kde.plasma.appmenu")) top = p;
});

// A barra padrão do Kubuntu fica embaixo e contém a bandeja; ela vira a dock
var dock = null;
all.forEach(function (p) { if (p.location == "bottom" && p !== top) dock = p; });

if (!top) {
    top = new Panel("org.kde.panel");
    top.location = "top";
    top.addWidget("org.kde.plasma.kickoff");
    top.addWidget("org.kde.plasma.appmenu");
    top.addWidget("org.kde.plasma.panelspacer");
    top.addWidget("org.kde.plasma.systemtray");
    top.addWidget("org.kde.plasma.digitalclock");
}
top.height = 26;

// Um lançador recém-criado vem sem atalho; o padrão do KDE é Alt+F1
top.widgets().forEach(function (w) {
    if (w.type == "org.kde.plasma.kickoff" && !w.globalShortcut) w.globalShortcut = "Alt+F1";
});

// Sem indicador de áreas de trabalho na barra: o usuário preferiu tirar
top.widgets().forEach(function (w) {
    if (w.type == "org.kde.plasma.pager") w.remove();
});

if (!dock) {
    dock = new Panel("org.kde.panel");
    dock.location = "bottom";
}
dock.widgets().forEach(function (w) {
    if (w.type != "org.kde.plasma.icontasks" && w.type != "org.kde.plasma.taskmanager") w.remove();
});
if (!hasWidget(dock, "org.kde.plasma.icontasks") && !hasWidget(dock, "org.kde.plasma.taskmanager")) {
    dock.addWidget("org.kde.plasma.icontasks");
}
dock.height = 40;
dock.alignment = "center";
dock.hiding = "autohide";
if (typeof dock.lengthMode !== "undefined") {
    // Plasma 6: "Ajustar ao conteúdo". Com o padrão ("fill") a dock ocupa a
    // largura toda e ignora os limites abaixo
    dock.lengthMode = "fit";
} else {
    dock.minimumLength = 300;
    dock.maximumLength = 700;
}

// O Plasma 6 cria painéis flutuantes, com margem em volta; sem ela a barra
// superior não perde pixels
[top, dock].forEach(function (p) {
    if (typeof p.floating !== "undefined") p.floating = false;
});

panels().forEach(function (p) {
    print(p.location + " h=" + p.height + " " + p.hiding + " | " +
          p.widgets().map(function (w) { return w.type.replace("org.kde.plasma.", ""); }).join(", ") + "\n");
});
