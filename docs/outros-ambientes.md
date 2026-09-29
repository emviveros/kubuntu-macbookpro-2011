# Adaptar para outros ambientes

A especificação do resultado desejado está em [alteracoes.md](alteracoes.md). Aqui estão as diferenças entre os dois ambientes em que os scripts foram usados e os equivalentes em outros desktops. **As seções de GNOME e XFCE não foram testadas nesta máquina:** confira os nomes de chaves e pacotes na versão instalada antes de aplicar.

## Plasma 5 (X11) × Plasma 6 (Wayland)

Os dois são tratados pelos scripts. O ambiente atual é o Plasma 6.6 em Wayland (Kubuntu 26.04); o anterior era o Plasma 5.27 em X11 (Kubuntu 24.04). As diferenças:

| Item | Plasma 5 / X11 | Plasma 6 / Wayland |
|---|---|---|
| Ferramentas | `kwriteconfig5`, `qdbus`, `kquitapp5`, `kstart5` | `kwriteconfig6`, `qdbus6`, `kquitapp6`, `kstart` (o `scripts/lib.sh` detecta) |
| Fontes menores | 9 pt com DPI 88 (`forceFontDPI`, `xrdb`) | 8,3 pt, sem DPI forçado |
| Dock | `minimumLength`/`maximumLength` | `lengthMode = "fit"`, sem *Flutuante* |
| Dolphin | `.directory` | atributo estendido `user.kde.fm.viewproperties#1` |
| Gestos | Touchégg 2.x do PPA | script do KWin `gestos-macos` |
| App Exposé | atalho `ExposeClass` do KWin | recriado no script `gestos-macos` |
| Quick Look | `xdotool` + `xclip`, também na Área de trabalho | Toshy + Klipper + script do KWin `quicklook`; só no Dolphin |
| Brilho no mínimo | apaga a tela | apaga com `scripts/85-brilho.sh` |
| Menu global em apps GTK | `appmenu-gtk-module` | só em apps GTK rodando em X11 (Xwayland) |

Continua igual nos dois: janelas, Menu global nos apps KDE/Qt, Chrome com escala 0.85, teclado do Toshy, teclas de mídia, teclas de volume (componente `kmix` no kglobalaccel).

## GNOME

| Objetivo | Como |
|---|---|
| Fontes menores | `gsettings set org.gnome.desktop.interface text-scaling-factor 0.9` e fontes 9 pt no GNOME Tweaks |
| Barra superior | O GNOME já tem uma; a extensão *Just Perfection* reduz o tamanho |
| Dock oculta | Extensão *Dash to Dock* com ocultação automática |
| Sem barra de título ao maximizar | Extensões como *Unite* ou *No Title Bar* |
| Menu global | Não há suporte oficial |

## XFCE

| Objetivo | Como |
|---|---|
| Fontes e DPI | *Aparência → Fontes → DPI personalizado: 88* |
| Barra superior + dock | Painel 1 no topo (26 px) com menu, bandeja e relógio; painel 2 embaixo com *Botões de janela*, ocultação *Inteligente* |
| Menu global | Plugin `xfce4-appmenu-plugin` (via pacote `vala-panel-appmenu`) |
| Barra de título compacta | *Gerenciador de janelas → Estilo*: escolha um tema com barra fina e fonte do título em 8 pt |
| Sem barra de título ao maximizar | *Ajustes do gerenciador de janelas → Acessibilidade → Ocultar título das janelas maximizadas* |
