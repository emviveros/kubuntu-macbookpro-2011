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
