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
