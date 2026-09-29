# Alterações

Cada alteração lista o arquivo e a chave (para scripts e agentes) e o caminho na interface (para fazer à mão). Os caminhos na interface são do Plasma 5.27 em português.

## 0. Pacotes (`scripts/00-pacotes.sh`)

Instala só o que falta e pede a senha do sudo uma vez:

| Pacote | Para quê |
|---|---|
| `appmenu-gtk3-module` | Menu global em apps GTK (seção 4) |
| `gnome-sushi`, `xclip`, `xdotool` | Quick Look no Dolphin (seção 7) |
| `python3-dbus` | Gravar atalhos no kglobalaccel (seções 3 e 9) |
| `vlc`, `plasma-browser-integration` | Teclas de mídia (seção 8) |
| `touchegg` 2.x, do `ppa:touchegg/stable` | Gestos (seção 9); o do Ubuntu é o 1.x |
| Toshy (`git clone` em `~/.local/src/toshy` + `./setup_toshy.py install`) | Teclado estilo macOS (seção 7). O instalador é interativo e exige reiniciar o computador |

O Google Chrome (seção 6) não é instalado: baixe-o do site do Google.

## 1. Janelas (`scripts/10-janelas.sh`)

| O quê | Antes | Depois | Arquivo → grupo → chave |
|---|---|---|---|
| Maximizadas sem barra de título | não | não (ver abaixo) | `kwinrc` → `[Windows]` → `BorderlessMaximizedWindows=false` |
| Tamanho dos botões (Breeze) | normal | pequeno | `breezerc` → `[Windeco]` → `ButtonSize=ButtonSmall` |
| Borda das janelas | normal | nenhuma | `kwinrc` → `[org.kde.kdecoration2]` → `BorderSize=None`, `BorderSizeAuto=false` |
| Fonte do título | 10 pt | 8 pt | `kdeglobals` → `[WM]` → `activeFont=Noto Sans,8,...` |

Na interface:
- *Configurações do Sistema → Aparência → Decorações de janelas*: *Tamanho da borda → Sem bordas*. No Breeze, clique no lápis → *Tamanho do botão: Pequeno*.
- *Aparência → Fontes → Título da janela*.
- **Sem barra de título ao maximizar:** foi testado com `true` e descartado: a janela maximizada fica sem os botões de fechar/minimizar/restaurar, e o widget que os colocaria na barra superior não está nos repositórios (ver seção 3). A barra compacta custa cerca de 20 px. No Plasma 5.27 não existe opção na interface, só pela chave.

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
| Barra superior | topo | 26 px | não | `kickoff` (`Alt+F1`), `appmenu`, `panelspacer`, `pager` (número da área), `systemtray`, `digitalclock` |
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

## 7. Teclado estilo macOS (`scripts/70-teclado-macos.sh`)

Usa o [Toshy](https://github.com/RedBearAK/toshy), que remapeia por aplicativo: ⌘ faz o papel do Ctrl nos apps gráficos, e no terminal ⌘+C copia enquanto Ctrl+C interrompe. ⌘+Tab troca de app, ⌘+Espaço abre o lançador e Option+setas pula palavras. O Toshy roda como serviço de usuário do systemd e tem ícone na bandeja.

Instalação: `scripts/00-pacotes.sh` faz os passos abaixo. À mão, no Konsole:

```bash
sudo apt install gnome-sushi xclip xdotool
git clone https://github.com/RedBearAK/toshy.git ~/.local/src/toshy
cd ~/.local/src/toshy && ./setup_toshy.py install
```

O `gnome-sushi` depende do Nautilus, e o Nautilus depende do indexador `tracker-miner-fs`. Não dá para instalar um sem os outros. O script deixa os pacotes, mas desativa o indexador e mantém o Dolphin como padrão (ver [problemas-conhecidos.md](problemas-conhecidos.md)).

Não marque o teclado como "Apple" nas configurações do KDE: o Toshy detecta o teclado Apple sozinho.

O script insere dois trechos (`files/toshy/*.py`) nas *slices* `user_custom_functions` e `user_apps` de `~/.config/toshy/toshy_config.py`, entre as marcas `# >>> kubuntu-macbookpro-2011` e `# <<< kubuntu-macbookpro-2011`. As *slices* são preservadas quando o Toshy é reinstalado.

| Atalho | Ação |
|---|---|
| `⌘+Shift+3` | Tela inteira, salva na Área de trabalho como `Captura de Tela AAAA-MM-DD às HH.MM.SS.png` |
| `⌘+Shift+4` | Região selecionável, salva na Área de trabalho |
| `⌘+Shift+5` | Abre o Spectacle (painel de captura) |
| `Ctrl+⌘+Shift+3` / `4` | Igual, mas copia para a área de transferência |
| `Espaço` ou `⌘+Y` no Dolphin ou na Área de trabalho | Pré-visualização (Quick Look) com o `sushi`. As setas mudam a seleção e ela acompanha; `Espaço` ou `Esc` fecham. |

**Apagar sem tecla Del.** O MacBook não tem Del; a tecla "delete" é o Backspace do Linux. O `Fn+Backspace → Del` vem do driver `hid_apple`, e o restante vem do Toshy, a não ser onde a tabela indica outra origem:

| Atalho | Em texto | No Dolphin |
|---|---|---|
| `Fn+Delete` | Apaga para a frente (Del) | Mover para a lixeira |
| `Option+Delete` | Apaga a palavra anterior | — |
| `⌘+Delete` | Apaga até o começo da linha (vem deste repositório; o Toshy só fazia isso no Firefox e no Thunderbird) | Mover para a lixeira |
| `⌘+Option+Delete` | — | Apagar de vez, com confirmação (vem deste repositório) |
| `Ctrl+D` | Apaga para a frente (Del) | — |

No terminal, `⌘+Delete` apaga até o começo da linha (`Ctrl+U`) e `Option+Delete` apaga a palavra anterior (`Ctrl+W`).

**Perfil do AppArmor:** o script instala `files/apparmor-nautilus-previewer` em `/etc/apparmor.d/nautilus-previewer` e **pede a senha do sudo** quando o perfil falta ou mudou. Sem ele, pré-visualizar HTML derruba o serviço de pré-visualização (ver [problemas-conhecidos.md](problemas-conhecidos.md)).

**Como funciona a pré-visualização:** nem o Dolphin nem a Área de trabalho informam a seleção por D-Bus. Por isso, `~/.local/bin/quicklook-dolphin` (cópia de `files/quicklook-dolphin`) manda Ctrl+C, lê o endereço do arquivo na área de transferência e depois restaura o conteúdo anterior. Se nada foi copiado como arquivo (renomeando ou digitando no filtro), o Espaço é digitado normalmente. O script chama o serviço `org.gnome.NautilusPreviewer` pelo D-Bus, com a janela de origem como janela-mãe, e devolve o foco a ela: a seleção continua visível. Enquanto a pré-visualização está aberta, existe o arquivo `$XDG_RUNTIME_DIR/quicklook-dolphin.open`, e o Toshy repassa as setas à janela e chama `quicklook-dolphin --sync`, que mostra o novo item selecionado; `Esc` chama `--close`. Repetições de tecla a menos de 0,7 s são ignoradas.

Para desfazer: apague o trecho entre as marcas e rode `toshy-services-restart`. Para remover o Toshy: `cd ~/.local/src/toshy && ./setup_toshy.py uninstall`.

## 8. Mídia (sem script)

As teclas F7/F8/F9 (anterior/tocar/próxima) e o controlador de mídia da bandeja usam MPRIS, que já funciona nos casos abaixo:

- **VLC** (`sudo apt install vlc`): expõe MPRIS sozinho.
- **YouTube e YouTube Music no Chrome**: precisam da extensão *Plasma Integration*, que já está instalada, e do pacote `plasma-browser-integration`. Com mais de uma fonte tocando, as teclas controlam a última que começou.

## 9. Gestos do trackpad (`scripts/80-gestos.sh` + `files/touchegg.conf`)

O Plasma 5 em X11 não tem gestos próprios (eles só existem no Wayland). O `touchegg` do repositório do Ubuntu é a versão 1.x, que não funciona; use a 2.x do PPA do projeto:

```bash
sudo add-apt-repository ppa:touchegg/stable
sudo apt install touchegg
```

| Gesto | Ação | Equivalente no macOS |
|---|---|---|
| 3 dedos para cima | Visão geral (`Overview` do KWin) | Mission Control |
| 3 dedos para baixo | Janelas do app atual (`ExposeClass`) | App Exposé |
| 3 dedos para esquerda/direita | Próxima/anterior área de trabalho | Trocar de Space |
| Pinça com 4 dedos | Lançador de aplicativos | Launchpad |
| Abrir 4 dedos | Mostrar a área de trabalho | Mostrar mesa |

Com 4 dedos, as passadas fazem o mesmo que com 3. O driver do trackpad (`bcm5974`) às vezes conta 3 dedos como 4, e antes disso a passada não fazia nada.

Atalhos de teclado, como no macOS (nos apps gráficos o Toshy manda o Ctrl físico como Meta):

| Tecla | Ação | Atalho no KDE |
|---|---|---|
| `Ctrl+←` / `Ctrl+→` | Área anterior / seguinte | `Meta+←/→` e `Meta+Ctrl+←/→` |
| `Ctrl+↑` | Visão geral | `Meta+↑` e `Meta+W` |
| `Ctrl+↓` | Janelas do app atual | `Meta+↓` e `Ctrl+F7` |

Esses atalhos valem em qualquer app, inclusive no terminal, onde o Toshy mantém o Ctrl como Ctrl. `files/toshy/user_apps.py` trata as duas formas do Ctrl. Na primeira área, `Ctrl+←` não faz nada, e na última `Ctrl+→` também não, como no macOS.

O `F4` (tecla Dashboard do MacBook 2011) abre o lançador de aplicativos, como o Launchpad. O Toshy transforma a tecla em `Alt+F1`, porque um segundo atalho gravado no KDE se perde quando o plasmashell reinicia.

Os atalhos de encaixar a janela na metade da tela (`Meta`+setas) ficam desligados. Ver também [problemas-conhecidos.md](problemas-conhecidos.md) (Toshy no Kubuntu).

O script também cria 4 áreas de trabalho em uma linha (`kwinrc` → `[Desktops]` → `Number=4`, `Rows=1`), porque antes só havia uma. Para mudar: `DESKTOPS=6 ./scripts/80-gestos.sh`.

Os gestos de 2 dedos (rolagem, pinça para zoom) continuam com o libinput e os próprios apps. O clique com 2 dedos é o botão direito.

Na interface: o app gráfico *Touché* (Flathub, `com.github.joseexposito.touche`) edita o mesmo arquivo.

## Descartado

- **Simular resolução maior** (`xrandr --output LVDS-1 --scale-from 1440x900`): funciona no Intel HD 3000, mas o texto fica borrado. Desfaz com `--scale 1x1`.
