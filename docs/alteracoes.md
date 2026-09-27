# Alterações

Cada alteração lista o arquivo e a chave (para scripts e agentes) e o caminho na interface (para fazer à mão). Os caminhos na interface são do Plasma 5.27 em português.

## 1. Janelas (`scripts/10-janelas.sh`)

| O quê | Antes | Depois | Arquivo → grupo → chave |
|---|---|---|---|
| Maximizadas sem barra de título | não | sim | `kwinrc` → `[Windows]` → `BorderlessMaximizedWindows=true` |
| Tamanho dos botões (Breeze) | normal | pequeno | `breezerc` → `[Windeco]` → `ButtonSize=ButtonSmall` |
| Borda das janelas | normal | nenhuma | `kwinrc` → `[org.kde.kdecoration2]` → `BorderSize=None`, `BorderSizeAuto=false` |
| Fonte do título | 10 pt | 8 pt | `kdeglobals` → `[WM]` → `activeFont=Noto Sans,8,...` |

Na interface:
- *Configurações do Sistema → Aparência → Decorações de janelas*: *Tamanho da borda → Sem bordas*. No Breeze, clique no lápis → *Tamanho do botão: Pequeno*.
- *Aparência → Fontes → Título da janela*.
- **Sem barra de título ao maximizar:** no Plasma 5.27 não existe opção na interface, só pela chave. As *Regras de janela* ("Sem barra de título e moldura") removem a barra sempre, não só ao maximizar.

Aplicar sem sair da sessão: `qdbus org.kde.KWin /KWin reconfigure`.

## 2. Fontes, DPI e ícones (`scripts/20-fontes-dpi.sh`)

| O quê | Antes | Depois | Arquivo → grupo → chave |
|---|---|---|---|
| Fonte geral | Noto Sans 10 | Noto Sans 9 | `kdeglobals` → `[General]` → `font` |
| Fonte de menus | 10 | 9 | `kdeglobals` → `[General]` → `menuFont` |
| Barra de ferramentas | 10 | 8 | `kdeglobals` → `[General]` → `toolBarFont` |
| Menor legível | 8 | 7 | `kdeglobals` → `[General]` → `smallestReadableFont` |
| Monoespaçada | Hack 10 | Hack 9 | `kdeglobals` → `[General]` → `fixed` |
| DPI forçado | 0 (automático = 96) | 88 | `kcmfonts` → `[General]` → `forceFontDPI` |
| Ícones de barras de ferramentas | 22 px | 16 px | `kdeglobals` → `[MainToolbarIcons]`, `[ToolbarIcons]`, `[SmallIcons]` → `Size=16` |
| Fonte GTK | Noto Sans 10 | Noto Sans 9 | `gsettings org.gnome.desktop.interface font-name` |
| Monoespaçada GTK | Monospace 11 | Hack 9 | `gsettings org.gnome.desktop.interface monospace-font-name` |

Na interface: *Aparência → Fontes* (inclui "Forçar DPI da fonte") e *Aparência → Ícones → Configurar tamanhos de ícones*.

O DPI 88 vale para tudo que lê `Xft.dpi` no X11: apps KDE, GTK, Firefox e Chrome. Na sessão atual o script aplica com `xrdb -merge`, mas o efeito completo só vem depois de sair e entrar na sessão.

Se ficar pequeno demais, suba o DPI para 92 ou 96 antes de mexer nas fontes.

## 3. Painéis estilo macOS (`scripts/30-paineis-macos.sh` + `files/layout-macos.js`)

| Painel | Posição | Altura | Ocultar | Widgets |
|---|---|---|---|---|
| Barra superior | topo | 26 px | não | `kickoff`, `appmenu`, `panelspacer`, `systemtray`, `digitalclock` |
| Dock | baixo, centralizada, 300–700 px | 40 px | automático | `icontasks` |

Antes havia só um painel embaixo, com 44 px, contendo `kickoff`, `pager`, `icontasks`, `marginsseparator`, `systemtray`, `digitalclock` e `minimizeall`. O script transforma esse painel na dock e cria a barra superior.

Na interface: botão direito no painel → *Entrar no modo de edição*. Ali ficam altura, posição, *Mais opções → Ocultar automaticamente* e *Adicionar widgets → Menu global*.

**Depois de aplicar, reinicie o plasmashell** (o script já faz isso). Ver [problemas-conhecidos.md](problemas-conhecidos.md).

Botões de fechar/minimizar na barra superior (para janelas maximizadas) dependem do widget "Window Buttons" da KDE Store, que não está nos repositórios do Ubuntu e não foi instalado.

## 4. Menu global para apps GTK (`scripts/40-menu-global-gtk.sh`)

- Pacote necessário: `appmenu-gtk3-module` (já vem no Kubuntu 24.04).
- Arquivo `~/.config/plasma-workspace/env/appmenu-gtk.sh` (cópia de `files/appmenu-gtk.sh`), que exporta `GTK_MODULES=appmenu-gtk-module` no login.
- Apps KDE/Qt e LibreOffice usam o Menu global sem configuração extra. O Firefox não exporta o menu, mas a barra de menus dele já fica oculta (`Alt` mostra).

## 5. Dolphin (`scripts/50-dolphin.sh`)

| O quê | Arquivo → grupo → chave |
|---|---|
| Mesmo modo para todas as pastas | `dolphinrc` → `[General]` → `GlobalViewProps=true` |
| Modo Compacto | `~/.local/share/dolphin/view_properties/global/.directory` → `[Dolphin]` → `ViewMode=2` (0 Ícones, 1 Detalhes, 2 Compacto) |
| Sem miniaturas | mesmo arquivo → `PreviewsShown=false` |
| Ícones 16 px no Compacto | `dolphinrc` → `[CompactMode]` → `IconSize=16` |
| Ícones 16 px em Locais | `dolphinrc` → `[PlacesPanel]` → `IconSize=16` |

O Dolphin precisa estar fechado: ele reescreve a configuração ao sair. Os campos `Timestamp`/`ViewPropsTimestamp` são atualizados para que as configurações novas tenham prioridade sobre as de cada pasta.

Na interface: *Exibir → Modo de visualização → Compacto* e *Configurar Dolphin → Modos de visualização*.

## 6. Google Chrome (`scripts/60-chrome.sh`)

- Cópias de `/usr/share/applications/google-chrome.desktop` e `com.google.Chrome.desktop` em `~/.local/share/applications/`, com `env UBUNTU_MENUPROXY=0` e `--force-device-scale-factor=0.85` nas linhas `Exec=`.
- `UBUNTU_MENUPROXY=0` é **obrigatório** com o Menu global ativo; sem ele o Chrome trava ao abrir (ver [problemas-conhecidos.md](problemas-conhecidos.md)).
- Esse valor substitui a escala que o Chrome calcularia pelo DPI 88 (cerca de 0.92), em vez de se somar a ela.
- Só vale quando o Chrome é aberto do zero. Feche com `Ctrl+Shift+Q` e desative *Configurações → Sistema → Continuar executando apps em segundo plano*.

## Descartado

- **Simular resolução maior** (`xrandr --output LVDS-1 --scale-from 1440x900`): funciona no Intel HD 3000, mas o texto fica borrado. Desfaz com `--scale 1x1`.
