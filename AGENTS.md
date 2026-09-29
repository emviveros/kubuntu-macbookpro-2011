# Instruções para agentes de IA

Este repositório descreve o estado desejado da interface de um MacBook Pro 13" (1280×800) com Kubuntu. O usuário quer **o máximo de conteúdo na tela** e aceita letras menores. A interface e a documentação são em **português do Brasil**.

## Antes de qualquer alteração

1. Descubra o ambiente:
   ```bash
   echo "$XDG_CURRENT_DESKTOP $XDG_SESSION_TYPE"; plasmashell --version
   lsb_release -ds; xrandr --current | head -3
   ```
2. Compare com o ambiente de referência (Plasma 6.6, Wayland, Ubuntu 26.04). Os scripts também funcionam no ambiente anterior (Plasma 5.27, X11, Ubuntu 24.04): onde os dois diferem, eles testam a sessão (`is_wayland` e `$PLASMA` em `scripts/lib.sh`).
   - **Um dos dois ambientes:** rode `./apply.sh` e depois confirme cada item com as verificações abaixo.
   - **Outra versão do Plasma ou outro desktop:** não rode os scripts às cegas. Use [docs/alteracoes.md](docs/alteracoes.md) como especificação do resultado desejado e [docs/outros-ambientes.md](docs/outros-ambientes.md) para achar o equivalente.
3. Confirme com o usuário antes de mexer nos painéis (`30`), porque isso redesenha a área de trabalho.

## Regras

- **Faça backup** antes de alterar. Os scripts fazem isso via `backup()` em `scripts/lib.sh`.
- **Depois de recriar a bandeja do sistema, reinicie o plasmashell.** Sem isso, as teclas de volume param de funcionar (ver [docs/problemas-conhecidos.md](docs/problemas-conhecidos.md)).
- **Não use `sudo` sem pedir.** Os pacotes de pré-requisito (Toshy, `touchegg` do PPA no X11, `gnome-sushi`) estão em [docs/alteracoes.md](docs/alteracoes.md). No Ubuntu 24.04, o `scripts/70-teclado-macos.sh` pede a senha para instalar um perfil do AppArmor em `/etc/apparmor.d/`: rode-o num terminal onde o usuário possa digitar.
- **Scripts do KWin (`files/kwin-*`):** o KWin guarda em cache o QML de um script já carregado na sessão. Depois de corrigir um, a versão nova só vale depois de reiniciar a sessão; para testar antes, carregue uma cópia com outro nome (`org.kde.kwin.Scripting.loadDeclarativeScript` + `start`).
- **Não simule resolução maior** (`xrandr --scale-from`) sem o usuário pedir. O texto fica borrado e isso foi descartado.
- **Nenhum segredo** vai para este repositório, que é público.
- **Ao adicionar um ajuste novo:** crie um script numerado em `scripts/`, registre em `docs/alteracoes.md` e na tabela do `README.md`.

## Verificações

Os comandos abaixo são do Plasma 6. No Plasma 5, troque `kreadconfig6` por `kreadconfig5` e `qdbus6` por `qdbus`.

```bash
# Painéis: esperado "top h=26 none | kickoff, appmenu, panelspacer, systemtray, digitalclock"
# e "bottom h=40 autohide fit | icontasks" (sem pager: o usuário tirou o indicador de áreas)
qdbus6 org.kde.plasmashell /PlasmaShell evaluateScript \
  'panels().forEach(function(p){print(p.location+" h="+p.height+" "+p.hiding+" "+p.lengthMode+" | "+p.widgets().map(function(w){return w.type}).join(", ")+"\n")})'

# Teclas de volume: esperado "true"
qdbus6 org.kde.kglobalaccel /component/kmix org.kde.kglobalaccel.Component.isActive

# Fontes: esperado "Noto Sans,8.3,..." no Wayland ou "Noto Sans,9,..." com DPI 88 no X11
kreadconfig6 --file kdeglobals --group General --key font
xrdb -query | grep dpi                                                        # só X11: 88

# Janelas
kreadconfig6 --file kwinrc --group Windows --key BorderlessMaximizedWindows   # false

# Wayland: scripts do KWin carregados (true, true, true)
for s in gestos-macos brilho-tela quicklook; do qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.isScriptLoaded $s; done

# Toshy rodando: esperado "active"
systemctl --user is-active toshy-config
```
