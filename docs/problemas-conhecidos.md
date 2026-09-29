# Problemas conhecidos

## Chrome fecha sozinho logo depois de abrir (Menu global)

**Sintoma:** o Chrome abre e fecha em menos de 1 s, ou trava pouco depois. Há dumps em `~/.config/google-chrome/Crash Reports/completed/` e o perfil fica com `exit_type = Crashed`.

**Causa:** quando existe um widget **Menu global** no painel, o KDE (`kde-gtk-config`) adiciona sozinho `appmenu-gtk-module` ao `gtk-modules` em `~/.config/gtk-3.0/settings.ini`. O Chrome 154 carrega esse módulo e trava numa chamada de retorno do GIO/D-Bus (SIGSEGV ou SIGILL), com ou sem GPU e com qualquer escala.

**Diagnóstico (perfil temporário, não mexe no seu):**
```bash
timeout 15 /opt/google/chrome/chrome --user-data-dir=/tmp/ct --no-first-run about:blank; echo $?
# 139/132 = travou; 124 = rodou 15 s normalmente
timeout 15 env UBUNTU_MENUPROXY=0 /opt/google/chrome/chrome --user-data-dir=/tmp/ct --no-first-run about:blank; echo $?
```

**Solução:** abrir o Chrome com `env UBUNTU_MENUPROXY=0`, o que já é feito em `scripts/60-chrome.sh`. O Chrome não usa barra de menus, então não se perde nada.

## Plasma cai em loop depois de abrir o Chrome (cache de fontes)

**Sintoma:** ao reiniciar o plasmashell (ou no login seguinte), ele cai logo ao abrir e o Gerenciador de Falhas aparece várias vezes. A barra superior e a dock somem.

**Causa:** o Chrome 154 traz um fontconfig mais novo. Ao abrir, ele grava em `~/.cache/fontconfig` arquivos `*.cache-12` e troca os `*.cache-9` do fontconfig do sistema (2.17) por links para eles. O fontconfig do sistema lê o formato errado: `fc-match "Noto Sans"` passa a devolver `KaTeX_AMS-Regular.woff: "Noto Sans" "<unknown style>"`, e o plasmashell cai em `FcCharSetHasChar` ao desenhar o primeiro texto (`coredumpctl info plasmashell`). Apps que já estavam abertos não são afetados, por isso o problema só aparece no próximo início.

**Diagnóstico:**
```bash
fc-match "Noto Sans"                       # esperado: NotoSans-Regular.ttf: "Noto Sans" "Regular"
ls -la ~/.cache/fontconfig | grep -c '\-> .*cache-12'   # esperado: 0
```

**Solução:** `scripts/60-chrome.sh` abre o Chrome com `XDG_CACHE_HOME` próprio e instala `fontconfig-cache-guard.sh`, que limpa o cache no login. À mão:
```bash
find ~/.cache/fontconfig -maxdepth 1 \( -type l -name '*.cache-*' -o -name '*.cache-1[0-9]' \) -delete
fc-cache -f && kstart plasmashell
```

## Teclas de volume param de funcionar depois de mudar os painéis

**Sintoma:** as teclas de volume do teclado não fazem nada.

**Causa:** no Plasma 5.27, as teclas de volume são registradas pelo widget de áudio (`org.kde.plasma.volume`) que fica dentro da bandeja do sistema, sob o componente `kmix` do kglobalaccel (mesmo sem o KMix instalado). Quando a bandeja antiga é removida, o registro fica inativo. A bandeja nova não reativa o registro até o plasmashell reiniciar.

**Diagnóstico:**
```bash
qdbus org.kde.kglobalaccel /component/kmix org.kde.kglobalaccel.Component.isActive   # false = problema
```

**Solução:**
```bash
kquitapp5 plasmashell; kstart5 plasmashell
```
Sair e entrar na sessão também resolve.

## Menu global vazio em apps GTK

Os apps GTK só mandam o menu depois do login seguinte à instalação de `~/.config/plasma-workspace/env/appmenu-gtk.sh`. Confira com `echo $GTK_MODULES`: deve conter `appmenu-gtk-module`.

## Chrome não ficou menor

Sobrou um processo do Chrome em segundo plano, então a nova escala não foi lida. Feche com `Ctrl+Shift+Q`, confirme com `pgrep chrome` e abra pelo ícone. Se abrir por terminal ou outro atalho, a flag não é aplicada.

## Dolphin volta ao modo antigo

O Dolphin estava aberto quando a configuração mudou e sobrescreveu tudo ao fechar. Feche o Dolphin e rode `scripts/50-dolphin.sh` de novo.

## O gnome-sushi traz o Nautilus e um indexador de arquivos

**Sintoma:** depois de `sudo apt install gnome-sushi` aparecem o Nautilus ("Arquivos") no menu e o `tracker-miner-fs`, que indexa a pasta pessoal e gasta CPU e disco.

**Causa:** no Ubuntu 24.04 o `gnome-sushi` depende do `nautilus`, e o `nautilus` depende do `tracker-miner-fs`. São dependências obrigatórias, então `--no-install-recommends` não resolve, e remover qualquer um deles remove o `gnome-sushi`. O autostart do indexador (`/etc/xdg/autostart/tracker-miner-fs-3.desktop`) vale também para o KDE.

**Solução:** `scripts/70-teclado-macos.sh` mantém os pacotes, mas:
- mascara o serviço: `systemctl --user mask tracker-miner-fs-3.service`;
- desliga o autostart com `~/.config/autostart/tracker-miner-fs-3.desktop` (`Hidden=true`);
- confirma o Dolphin como padrão para pastas: `xdg-mime default org.kde.dolphin.desktop inode/directory`.

Verificar: `systemctl --user is-enabled tracker-miner-fs-3.service` deve responder `masked`, e `pgrep -a tracker` não deve mostrar nada.


## Ctrl+←/→ minimiza ou maximiza a janela em vez de trocar de área

**Sintoma:** nos apps gráficos, `Ctrl+←` minimiza a janela e `Ctrl+→` maximiza. No terminal, os dois trocam de área normalmente.

**Causa:** nos apps gráficos o Toshy transforma o Ctrl físico em Meta. O bloco `GenGUI overrides: Ubuntu` do `toshy_config.py` só confere `DISTRO_ID == 'ubuntu'`, que também vale para o Kubuntu, e transforma `Meta+←/→` em `Meta+PgDown/PgUp` (atalhos do GNOME). No KDE, essas teclas minimizam e maximizam. Como esse bloco vem antes do bloco do KDE, é ele que vale.

**Solução:** `files/toshy/user_apps.py` define `Super-Left → C-Super-Left` e `Super-Right → C-Super-Right` na *slice* do usuário, que tem prioridade. No KDE, `scripts/80-gestos.sh` também liga `Meta+←/→` à troca de área e tira os atalhos de encaixar a janela na metade da tela, que usavam essas teclas.

**Diagnóstico:** o teclado virtual do Toshy é o `XWayKeyz (virtual) Keyboard` em `/proc/bus/input/devices`. Lendo o `/dev/input/eventN` dele, dá para ver as teclas que realmente chegam ao KDE.

## Quick Look: a pré-visualização abre atrás, para de abrir ou pula teclas

**Sintoma:** ao apertar Espaço, aparece um ícone na dock, mas a janela fica atrás; ou funciona algumas vezes e para; ou um `.html` não abre.

**Causas e soluções** (todas em `files/quicklook-dolphin`, exceto o perfil do AppArmor):

- **Janela atrás:** a proteção contra roubo de foco do KWin segura janelas abertas em segundo plano. Uma regra de janela (`fsplevel=0`) não resolveu. Solução: chamar o `ShowFile` do serviço pelo D-Bus passando a janela de origem como mãe (`x11:<id em hexadecimal>`); o KWin a mantém acima da origem.
- **Para de abrir:** no `sushi` 46, depois que a janela de pré-visualização é fechada (Esc, Espaço ou `Close()`), o serviço não mostra mais nenhuma: as novas são criadas mas ficam sem mapear. Solução: reiniciar o serviço (`pkill` no `gjs` do `org.gnome.NautilusPreviewer`) a cada abertura; o D-Bus o sobe de novo em cerca de 0,6 s.
- **Abre e fecha sozinha:** com a tecla segurada, o Toshy repete o comando a cada ~0,1 s (um aperto chegou a gerar 10 chamadas). Solução: ignorar chamadas a menos de 0,7 s da anterior.
- **HTML derruba o serviço:** o WebKit isola cada página com o `bwrap`, e o Ubuntu 24.04 (`kernel.apparmor_restrict_unprivileged_userns = 1`) bloqueia isso para programas sem permissão: `bwrap: setting up uid map: Permission denied` e SIGTRAP (relatório em `/var/crash/_usr_bin_gjs-console.1000.crash`). Solução: `scripts/70-teclado-macos.sh` instala o perfil `/etc/apparmor.d/nautilus-previewer` com `userns`, igual ao que o Ubuntu traz para o GNOME Web (`/etc/apparmor.d/epiphany`).
- **Setas ignoradas depois da primeira:** o `xclip` que guarda a área de transferência fica rodando e herdava a saída e as travas do script, que ficava esperando por ele. Solução: desviar a saída e fechar os descritores das travas nas chamadas do `xclip`.

Não funcionou: tirar o foco da pré-visualização para mandar a seta ao Dolphin (o Dolphin ignora teclas enviadas sem foco, e a troca leva ~0,35 s, perdendo teclas) e selecionar com `org.freedesktop.FileManager1.ShowItems` (puxa o foco para o Dolphin).

Verificar: com uma pré-visualização aberta, `cat /proc/$(pgrep -f "^/usr/bin/gjs /usr/libexec/org.gnome.NautilusPreviewer")/attr/current` deve mostrar `nautilus-previewer (unconfined)`.

## Plasma 6 (Wayland): dock da largura da tela

**Sintoma:** depois de `scripts/30-paineis-macos.sh`, a dock ocupa a largura toda da tela.

**Causa:** no Plasma 6 o painel tem `lengthMode`, e com o padrão (`"fill"`) os limites `minimumLength`/`maximumLength` são ignorados.

**Solução:** `files/layout-macos.js` usa `lengthMode = "fit"` (*Ajustar ao conteúdo*) quando a propriedade existe.

## Plasma 6: brilho no mínimo não apaga a tela

**Sintoma:** com o brilho no mínimo a tela fica fraca, mas acesa. No Plasma 5 ela apagava.

**Causa:** no Plasma 6 o KWin controla a luz de fundo e nunca grava 0. Neste MacBook o kernel 7.0 registra só a interface `acpi_video0` (`i915: Skipping intel_backlight registration`), de 0 a 15, e o KWin para no 1.

**Diagnóstico:** `cat /sys/class/backlight/*/brightness` com o brilho no mínimo mostra 1.

**Solução:** `scripts/85-brilho.sh` (ver [alteracoes.md](alteracoes.md#10-brilho-no-mínimo-apaga-a-tela-scripts85-brilhosh-só-plasma-6)). Um comando novo no kglobalaccel não funcionou: o atalho ficou registrado, mas inativo, e a tecla parou de fazer qualquer coisa. No Wayland o kglobalaccel roda dentro do KWin e só carrega comandos novos ao iniciar a sessão. Por isso a tecla fica com um script do KWin.

## Dolphin 25: volta ao modo Ícones

**Sintoma:** o `scripts/50-dolphin.sh` roda, mas o Dolphin continua no modo Ícones, e o `.directory` que o script criou some.

**Causa:** do Dolphin 24.08 em diante o modo fica num atributo estendido da pasta (`user.kde.fm.viewproperties#1`). O Dolphin apaga o `.directory` sem ler, e sem `Version=4` o conteúdo também é ignorado.

**Solução:** o script grava o atributo com `Version=4`. Para descobrir o formato, o modo foi trocado pelas ações do próprio Dolphin por D-Bus (`qdbus6 org.kde.dolphin-<pid> /dolphin/Dolphin_1/actions/compact org.qtproject.Qt.QAction.trigger`) e o atributo foi lido com `os.getxattr`.

## Quick Look no Wayland

O caminho que funciona está em [alteracoes.md](alteracoes.md#7-teclado-estilo-macos-scripts70-teclado-macossh). O que não funcionou ou atrapalhou:

- **`wl-paste` rouba o foco:** o `wl-clipboard` 2.2.1 do Ubuntu 26.04 não conhece o protocolo `ext_data_control_v1`, o único que o KWin 6.6 oferece. Para ler, ele abre uma janela invisível, que tira o foco do Dolphin. Por isso a leitura é pelo Klipper (`org.kde.klipper /klipper getClipboardContents`), que devolve o `file://` do arquivo copiado.
- **Copiar pelo D-Bus não funciona:** a ação `edit_copy` do Dolphin, chamada por D-Bus, não chega à área de transferência. O Wayland só aceita a cópia depois de uma tecla de verdade, por isso o Ctrl+C sai do Toshy.
- **Área de trabalho:** num teste anterior, Ctrl+C nos ícones da Área de trabalho não copiava nada no Plasma 6.6 em Wayland. Em 29/09/2026 copiou: com o foco na Área de trabalho, Ctrl+A e Ctrl+C deixaram os `file://` no Klipper, e o `⌥⌘C` (copiar caminho) funciona lá. O Quick Look na Área de trabalho não foi testado de novo.
- **Janela da Área de trabalho no Toshy:** no Wayland ela é `plasmashell` sem título, e o Toshy troca o título vazio por `ERR: KeyContext: NoneType in wm_name`. O `matchProps(name="^$")` nunca casa; a função compara direto.
- **Foco:** a pré-visualização do sushi toma o foco ao abrir e a cada arquivo novo. O `ShowFile` do sushi 50 pede uma janela-mãe no formato `wayland:<handle>` (xdg-foreign), que um script de terminal não tem. O script do KWin `quicklook` devolve o foco à janela de origem.

**Testar sem mexer no teclado:** com o Toshy instalado, o usuário tem acesso a `/dev/uinput`. Um teclado virtual criado com `python-evdev` (o Python de `~/.config/toshy/.venv`) passa pelo Toshy como um teclado de verdade, mas o Toshy leva cerca de 2 s para pegar um teclado novo. Ele é tratado como teclado de PC: o ⌘ fica no Alt.

## Scripts do KWin: correção não vale na mesma sessão

**Sintoma:** depois de corrigir o QML de um script do KWin e rodar `kpackagetool6 --upgrade`, o log continua mostrando o erro da versão antiga (`journalctl --user | grep kwin_scripting`).

**Causa:** o KWin guarda em cache o componente QML já carregado.

**Solução:** reiniciar a sessão. Para testar antes, carregue uma cópia com outro nome: `qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.loadDeclarativeScript <arquivo.qml> <nome>` e depois `org.kde.kwin.Scripting.start`.

Outra armadilha: o `DBusCall` do QML manda um array JavaScript como lista de variantes, e um método que espera `QStringList` recusa a chamada sem aviso. Guarde a lista numa propriedade `list<string>` antes de passar.

## Menu global vazio num app já aberto

Um app aberto antes da barra superior ganhar o Menu global continua com o menu dentro da janela. Feche e abra o app de novo.
