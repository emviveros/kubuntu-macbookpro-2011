# Alterações

Cada alteração lista o arquivo e a chave (para scripts e agentes) e o caminho na interface (para fazer à mão). Os caminhos na interface são do Plasma 5.27 em português; no Plasma 6 são parecidos. Onde o Plasma 6 em Wayland (ambiente atual, Ubuntu 26.04) pede outro caminho, a seção diz.

## 0. Pacotes (`scripts/00-pacotes.sh`)

Instala só o que falta e pede a senha do sudo uma vez:

| Pacote | Para quê |
|---|---|
| `appmenu-gtk3-module` | Menu global em apps GTK (seção 4) |
| `gnome-sushi`, `xclip`, `xdotool` | Quick Look no Dolphin (seção 7) |
| `python3-dbus` | Gravar atalhos no kglobalaccel (seções 3 e 9) |
| `vlc`, `plasma-browser-integration` | Teclas de mídia (seção 8) |
| `touchegg` 2.x, do `ppa:touchegg/stable` | Gestos no X11 (seção 9); o do Ubuntu é o 1.x. No Wayland não é instalado |
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

**No Wayland** o DPI forçado não vale para os apps nativos (o Plasma 6 nem mostra a opção). O script usa o tamanho equivalente em pontos, 9 × 88/96 ≈ 8,3 pt, e apaga o `forceFontDPI`, que o Plasma 6 ainda aplica aos apps X11 (Xwayland) e os deixaria menores que os outros:

| O quê | X11 | Wayland |
|---|---|---|
| Fonte geral, menus, monoespaçada, GTK | 9 pt | 8,3 pt |
| Barra de ferramentas, título da janela | 8 pt | 7,3 pt |
| Menor legível | 7 pt | 6,4 pt |
| `kcmfonts` → `forceFontDPI` | 88 | apagado |

Se ficar pequeno demais, suba o DPI para 92 ou 96 antes de mexer nas fontes.

## 3. Painéis estilo macOS (`scripts/30-paineis-macos.sh` + `files/layout-macos.js`)

| Painel | Posição | Altura | Ocultar | Widgets |
|---|---|---|---|---|
| Barra superior | topo | 26 px | não | `kickoff` (`Alt+F1`), `appmenu`, `panelspacer`, `systemtray`, `digitalclock` |
| Dock | baixo, centralizada, do tamanho dos ícones | 40 px | automático | `icontasks` |

A barra já teve um indicador de áreas de trabalho (`pager`), que o usuário preferiu tirar; o script remove o widget se o encontrar.

No Plasma 6 a dock usa *Ajustar ao conteúdo* (`lengthMode = "fit"`). O padrão (`"fill"`) ignora os limites de largura e a deixava da largura da tela; no Plasma 5 ela fica entre 300 e 700 px (`minimumLength`/`maximumLength`). Os dois painéis ficam sem *Flutuante* (`floating = false`), para a barra superior não perder a margem.

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
| Modo Compacto | pasta `~/.local/share/dolphin/view_properties/global/` → `[Dolphin]` → `ViewMode=2` (0 Ícones, 1 Detalhes, 2 Compacto), ver abaixo |
| Sem miniaturas | mesmo arquivo → `PreviewsShown=false` |
| Ícones 16 px no Compacto | `dolphinrc` → `[CompactMode]` → `IconSize=16` |
| Ícones 16 px em Locais | `dolphinrc` → `[PlacesPanel]` → `IconSize=16` |

Onde fica o modo: até o Dolphin 24.05, no arquivo `.directory` dessa pasta. Do 24.08 em diante (o Ubuntu 26.04 traz o 25.12), num atributo estendido da pasta, `user.kde.fm.viewproperties#1`, com o mesmo conteúdo (inclusive `Version=4`); o Dolphin novo apaga o `.directory` sem ler. O script grava o atributo quando o sistema de arquivos aceita, senão o `.directory`. Para conferir: `python3 -c "import os; print(os.getxattr(os.path.expanduser('~/.local/share/dolphin/view_properties/global'), 'user.kde.fm.viewproperties#1').decode())"`.

O Dolphin precisa estar fechado: ele reescreve a configuração ao sair. Os campos `Timestamp`/`ViewPropsTimestamp` são atualizados para que as configurações novas tenham prioridade sobre as de cada pasta.

Na interface: *Exibir → Modo de visualização → Compacto* e *Configurar Dolphin → Modos de visualização*.

## 6. Google Chrome (`scripts/60-chrome.sh`)

- Cópias de `/usr/share/applications/google-chrome.desktop` e `com.google.Chrome.desktop` em `~/.local/share/applications/`, com `env UBUNTU_MENUPROXY=0` e `--force-device-scale-factor=0.85` nas linhas `Exec=`.
- `UBUNTU_MENUPROXY=0` é **obrigatório** com o Menu global ativo; sem ele o Chrome trava ao abrir (ver [problemas-conhecidos.md](problemas-conhecidos.md)).
- `XDG_CACHE_HOME=~/.cache/google-chrome-xdg` também está no `Exec=`: o Chrome 154 regrava o cache de fontes do usuário num formato que o fontconfig do sistema não lê, e o plasmashell cai no login seguinte. O cache do Chrome passa a ficar nessa pasta. Como segunda proteção, `~/.config/plasma-workspace/env/fontconfig-cache-guard.sh` (cópia de `files/fontconfig-cache-guard.sh`) apaga o cache quebrado a cada login, antes do Plasma (ver [problemas-conhecidos.md](problemas-conhecidos.md)).
- Esse valor substitui a escala que o Chrome calcularia pelo DPI 88 (cerca de 0.92), em vez de se somar a ela.
- No Wayland (o Chrome 154 já abre nativo) a escala também vale, e o Chrome manda o menu para o Menu global.
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
| `Espaço` ou `⌘+Y` no Dolphin (e na Área de trabalho, só no X11) | Pré-visualização (Quick Look) com o `sushi`. As setas mudam a seleção e ela acompanha; `Espaço` ou `Esc` fecham. |

**Apagar sem tecla Del.** O MacBook não tem Del; a tecla "delete" é o Backspace do Linux. O `Fn+Backspace → Del` vem do driver `hid_apple`, e o restante vem do Toshy, a não ser onde a tabela indica outra origem:

| Atalho | Em texto | No Dolphin e na Área de trabalho |
|---|---|---|
| `Fn+Delete` | Apaga para a frente (Del) | Mover para a lixeira |
| `Option+Delete` | Apaga a palavra anterior | — |
| `⌘+Delete` | Apaga até o começo da linha (vem deste repositório; o Toshy só fazia isso no Firefox e no Thunderbird) | Mover para a lixeira (na Área de trabalho, vem deste repositório: o Toshy não a trata como gerenciador de arquivos) |
| `⌘+Option+Delete` | — | Apagar de vez, com confirmação (vem deste repositório) |
| `Ctrl+D` | Apaga para a frente (Del) | — |

**Copiar o caminho, como no Finder.** `⌥⌘C` no Dolphin e na Área de trabalho copia o caminho dos itens selecionados em texto, um por linha (por exemplo `/home/usuario/Documentos/relatório final.pdf`). A função `km_copiar_caminho` (`files/toshy/user_custom_functions.py`) manda Ctrl+C, lê os endereços `file://` pelo Klipper e grava os caminhos no lugar deles. Se nada foi copiado como arquivo (renomeando, filtrando), devolve o que havia antes na área de transferência.

No terminal, `⌘+Delete` apaga até o começo da linha (`Ctrl+U`) e `Option+Delete` apaga a palavra anterior (`Ctrl+W`).

**Perfil do AppArmor:** quando `kernel.apparmor_restrict_unprivileged_userns = 1` (Ubuntu 24.04), o script instala `files/apparmor-nautilus-previewer` em `/etc/apparmor.d/nautilus-previewer` e **pede a senha do sudo** se o perfil falta ou mudou. No Ubuntu 26.04 essa restrição vem desligada e o perfil não é instalado. Sem ele, pré-visualizar HTML derruba o serviço de pré-visualização (ver [problemas-conhecidos.md](problemas-conhecidos.md)).

**Como funciona a pré-visualização:** nem o Dolphin nem a Área de trabalho informam a seleção por D-Bus. Por isso, `~/.local/bin/quicklook-dolphin` (cópia de `files/quicklook-dolphin`) manda Ctrl+C, lê o endereço do arquivo na área de transferência e depois restaura o conteúdo anterior. Se nada foi copiado como arquivo (renomeando ou digitando no filtro), o Espaço é digitado normalmente. O script chama o serviço `org.gnome.NautilusPreviewer` pelo D-Bus, com a janela de origem como janela-mãe, e devolve o foco a ela: a seleção continua visível. Enquanto a pré-visualização está aberta, existe o arquivo `$XDG_RUNTIME_DIR/quicklook-dolphin.open`, e o Toshy repassa as setas à janela e chama `quicklook-dolphin --sync`, que mostra o novo item selecionado; `Esc` chama `--close`. Repetições de tecla a menos de 0,7 s são ignoradas.

**Pré-visualização no Wayland** (`~/.local/bin/quicklook-wayland`, cópia de `files/quicklook-wayland`). Lá não há `xdotool` nem `xclip`, e um app só grava na área de transferência quando está em foco e depois de uma tecla de verdade. Por isso a função `km_quicklook_wl` (`files/toshy/user_custom_functions.py`), que roda dentro do Toshy:

1. guarda o texto da área de transferência em `$XDG_RUNTIME_DIR/quicklook-dolphin.clip` e a limpa, pelo Klipper (D-Bus);
2. manda Ctrl+C ao Dolphin, que está em foco;
3. espera até 0,3 s o Klipper mostrar um `file://`. Se aparecer, chama `quicklook-wayland --show`; se não (renomeando, filtrando), restaura a área de transferência e digita o Espaço.

Com a pré-visualização aberta, cada seta vai ao Dolphin seguida de Ctrl+C, e `quicklook-wayland --sync` mostra o novo arquivo. O script do KWin `quicklook` (`files/kwin-quicklook`) mantém a janela do sushi por cima e devolve o foco ao Dolphin sempre que ela o toma. Quando ela fecha, por qualquer meio, ele inicia `quicklook-fechou.service` (`~/.config/systemd/user/`), que restaura a área de transferência. Só texto volta à área de transferência: se havia uma imagem copiada, ela continua no histórico do Klipper. O sushi 50 não tem mais o problema de parar de abrir depois de fechar, então o serviço não é reiniciado.

Na Área de trabalho do Plasma 6.6 em Wayland, o Ctrl+C copia os arquivos selecionados (conferido em 29/09/2026: chegam como `file://` ao Klipper). Uma nota antiga dizia o contrário, e a pré-visualização lá ainda não foi testada de novo.

Para desfazer: apague o trecho entre as marcas e rode `toshy-services-restart`. No Wayland, também: `kpackagetool6 --type KWin/Script --remove quicklook`. Para remover o Toshy: `cd ~/.local/src/toshy && ./setup_toshy.py uninstall`.

## 8. Mídia (`files/midia-pular`, instalado por `scripts/70-teclado-macos.sh`)

As teclas F7/F8/F9 (anterior/tocar/próxima) e o controlador de mídia da bandeja usam MPRIS, que já funciona nos casos abaixo:

- **VLC** (`sudo apt install vlc`): expõe MPRIS sozinho.
- **YouTube e YouTube Music no Chrome**: precisam da extensão *Plasma Integration*, que já está instalada, e do pacote `plasma-browser-integration`. Com mais de uma fonte tocando, as teclas controlam a última que começou.

O F8 fica com o KDE. O F7 e o F9 são tratados pelo Toshy, que chama `~/.local/bin/midia-pular previous|next`:

| Situação | F7 | F9 |
|---|---|---|
| O player tem faixa anterior/próxima (playlist, YouTube Music, VLC com fila) | Faixa anterior | Próxima faixa |
| Não tem (vídeo avulso do YouTube, `CanGoPrevious`/`CanGoNext` falsos) | Volta 10 s | Avança 10 s |

O script usa o player que está tocando. O Chrome aparece duas vezes no MPRIS (`chromium.instance…` e `plasma-browser-integration`), e o script usa o segundo, como o KDE.

O widget *Reprodução de mídia* da bandeja só é carregado quando um player aparece. Antes disso, o componente `mediacontrol` não existe no kglobalaccel, e isso é normal.

## 9. Gestos do trackpad (`scripts/80-gestos.sh` + `files/touchegg.conf`)

**No Wayland (Plasma 6):** o Touchégg não funciona. O próprio KWin reconhece os gestos: de fábrica, 4 dedos para cima abrem a Visão geral e para os lados trocam de área. O script do KWin `gestos-macos` (`files/kwin-gestos-macos`, instalado em `~/.local/share/kwin/scripts/`) acrescenta os de 3 dedos e as pinças da tabela abaixo, com `SwipeGestureHandler` e `PinchGestureHandler`. Ele também recria o App Exposé, que o Plasma 6 não tem mais como atalho: pega as janelas do app ativo na área atual e chama o efeito *Apresentar janelas* por D-Bus (`org.kde.KWin.Effect.WindowView1.activate`), com o atalho `Meta+↓`. O script vale por completo a partir da sessão seguinte à instalação.

**No X11 (Plasma 5):** o KDE não tem gestos próprios. O `touchegg` do repositório do Ubuntu é a versão 1.x, que não funciona; use a 2.x do PPA do projeto:

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
| `Ctrl+↓` | Janelas do app atual | `Meta+↓` (no Plasma 5, também `Ctrl+F7`) |

Esses atalhos valem em qualquer app, inclusive no terminal, onde o Toshy mantém o Ctrl como Ctrl. `files/toshy/user_apps.py` trata as duas formas do Ctrl. Na primeira área, `Ctrl+←` não faz nada, e na última `Ctrl+→` também não, como no macOS.

O `F3` (tecla Scale do MacBook 2011) abre a Visão geral, como o Mission Control e como os 4 dedos para cima: o Toshy a transforma em `Meta+W`, porque o KDE não tem atalho para essa tecla. O `F4` (tecla Dashboard) abre o lançador de aplicativos, como o Launchpad. O Toshy transforma a tecla em `Alt+F1`, porque um segundo atalho gravado no KDE se perde quando o plasmashell reinicia.

Os atalhos de encaixar a janela na metade da tela (`Meta`+setas) ficam desligados. Ver também [problemas-conhecidos.md](problemas-conhecidos.md) (Toshy no Kubuntu).

O script também cria 4 áreas de trabalho em uma linha (`kwinrc` → `[Desktops]` → `Number=4`, `Rows=1`), porque antes só havia uma. Para mudar: `DESKTOPS=6 ./scripts/80-gestos.sh`.

Os gestos de 2 dedos (rolagem, pinça para zoom) continuam com o libinput e os próprios apps. O clique com 2 dedos é o botão direito.

Na interface (X11): o app gráfico *Touché* (Flathub, `com.github.joseexposito.touche`) edita o mesmo arquivo. No Wayland, os gestos de 3 dedos só mudam editando `files/kwin-gestos-macos/contents/ui/main.qml` e rodando o script de novo.

## 10. Brilho no mínimo apaga a tela (`scripts/85-brilho.sh`, só Plasma 6)

No Plasma 5, o brilho no mínimo desligava a luz de fundo, como no macOS. No Plasma 6 o brilho passa pelo KWin, que nunca grava 0 no hardware: no mínimo a tela fica fraca, mas acesa. Neste MacBook o kernel 7.0 usa a interface `acpi_video0` (níveis 0 a 15), e o KWin para no nível 1.

| Peça | O que faz |
|---|---|
| `~/.local/bin/brilho-tela` (cópia de `files/brilho-tela`) | Diminui um passo pelo Plasma (`org.kde.ScreenBrightness.AdjustBrightnessStep`, com o aviso na tela). No último passo, ou já no mínimo, grava 0 na luz de fundo pelo logind (`org.freedesktop.login1.Session.SetBrightness`), que não pede senha |
| `~/.config/systemd/user/brilho-tela.service` | Roda o script |
| Script do KWin `brilho-tela` (`files/kwin-brilho-tela`) | Fica com a tecla de diminuir o brilho (F1) e inicia o serviço |
| `kglobalshortcutsrc` → `[org_kde_powerdevil]` → `Decrease Screen Brightness=none` | Tira a tecla do Plasma |

A tecla de aumentar o brilho continua com o Plasma e acende a tela de novo.

O atalho fica num script do KWin porque um comando novo no kglobalaccel (como em *Configurações → Atalhos → Adicionar comando*) só passa a valer depois de reiniciar a sessão: o kglobalaccel roda dentro do KWin no Wayland.

Para desfazer: `kpackagetool6 --type KWin/Script --remove brilho-tela` e, em *Configurações → Atalhos → Gerenciamento de energia*, devolva a tecla a *Reduzir o brilho da tela*.

## 11. Google Antigravity (`scripts/90-antigravity.sh`)

Os três produtos do Antigravity, lado a lado e sem sudo (no Ubuntu 26.04):

| Comando | Produto | Onde fica | Atualização |
|---|---|---|---|
| `antigravity` | Antigravity 2.0 (app de agentes) | `~/.local/share/antigravity/app` | Rodar o script de novo com a URL nova |
| `antigravity-ide` | Antigravity IDE (derivada do VS Code; `antigravity-ide .` abre a pasta) | `~/.local/share/antigravity/ide` | Rodar o script de novo com a URL nova |
| `agy` | Antigravity CLI (agente no terminal) | `~/.local/bin/agy` | Sozinho, a cada uso |

O repositório apt do Google (`antigravity-debian`) é legado e parou na versão 1.x. O app e a IDE vêm em tarball de https://antigravity.google/download. As URLs ficam no topo do script e podem ser trocadas sem editar o arquivo: `ANTIGRAVITY_APP_URL=... ANTIGRAVITY_IDE_URL=... ./apply.sh 90`. O script só baixa de novo o que mudou. O `agy` vem do instalador oficial (`https://antigravity.google/cli/install.sh`), que confere o SHA-512 do binário e acrescenta o `PATH` ao perfil do shell (por isso o backup de `~/.bashrc` e `~/.profile`).

| Peça | O que faz |
|---|---|
| `~/.local/bin/antigravity` e `antigravity-ide` | Lançadores. Abrem com `FONTCONFIG_FILE=~/.config/antigravity/fonts.conf` e `UBUNTU_MENUPROXY=0` |
| `~/.config/antigravity/fonts.conf` (cópia de `files/antigravity-fonts.conf`) | Mesmas fontes do sistema, com o cache em `~/.cache/antigravity-fontconfig` |
| `~/.local/share/applications/antigravity.desktop` e `antigravity-ide.desktop` | Atalhos no menu, com ícones em `~/.local/share/icons/hicolor/512x512/apps/` |
| `x-scheme-handler/antigravity` e `antigravity-ide` (`xdg-mime`) | O login do Google volta do navegador para o app certo |
| `/etc/apparmor.d/antigravity` (cópia de `files/apparmor-antigravity`) | Só no Ubuntu 24.04: libera o `userns` do sandbox do Chromium. Pede a senha do sudo |

**Cache de fontes:** o app e a IDE trazem um fontconfig embutido mais novo que o do sistema (2.17) e gravam `*.cache-11` no cache do usuário, o mesmo tipo de problema do Chrome 154 (ver [problemas-conhecidos.md](problemas-conhecidos.md)). Com o `fonts.conf` próprio, o cache deles vai para outra pasta e `~/.cache/fontconfig` fica só com `*.cache-9`. Conferido abrindo os dois: nenhum `cache-11` nem link no cache do sistema.

**Menu global:** abrem com `UBUNTU_MENUPROXY=0`, como o Chrome, porque são Chromium e o `appmenu-gtk-module` derruba o Chrome. Os dois desenham os próprios menus, então não se perde nada.

Na primeira abertura, cada um pede para entrar com a conta Google. O `agy` guarda a sessão no chaveiro do KDE (Secret Service).

Para desfazer: `rm -rf ~/.local/share/antigravity ~/.config/antigravity ~/.cache/antigravity-fontconfig ~/.local/bin/{agy,antigravity,antigravity-ide} ~/.local/share/applications/antigravity{,-ide}.desktop ~/.local/share/icons/hicolor/512x512/apps/antigravity{,-ide}.png`. Os dados ficam em `~/.config/Antigravity`, `~/.antigravity-ide` e `~/.gemini`.

## Descartado

- **Simular resolução maior** (`xrandr --output LVDS-1 --scale-from 1440x900`): funciona no Intel HD 3000, mas o texto fica borrado. Desfaz com `--scale 1x1`.
