# Instruções para agentes de IA

Este repositório descreve o estado desejado da interface de um MacBook Pro 13" (1280×800) com Kubuntu. O usuário quer **o máximo de conteúdo na tela** e aceita letras menores. A interface e a documentação são em **português do Brasil**.

## Antes de qualquer alteração

1. Descubra o ambiente:
   ```bash
   echo "$XDG_CURRENT_DESKTOP $XDG_SESSION_TYPE"; plasmashell --version
   lsb_release -ds; xrandr --current | head -3
   ```
2. Compare com o ambiente de referência (Plasma 5.27, X11, Ubuntu 24.04):
   - **Mesmo ambiente:** rode `./apply.sh` e depois confirme cada item com as verificações abaixo.
   - **Plasma 6, Wayland ou outro desktop:** não rode os scripts às cegas. Use [docs/alteracoes.md](docs/alteracoes.md) como especificação do resultado desejado e [docs/outros-ambientes.md](docs/outros-ambientes.md) para achar o equivalente.
3. Confirme com o usuário antes de mexer nos painéis (`30`), porque isso redesenha a área de trabalho.

## Regras

- **Faça backup** antes de alterar. Os scripts fazem isso via `backup()` em `scripts/lib.sh`.
- **Depois de recriar a bandeja do sistema, reinicie o plasmashell.** Sem isso, as teclas de volume param de funcionar (ver [docs/problemas-conhecidos.md](docs/problemas-conhecidos.md)).
- **Não use `sudo` sem pedir.** Só o pacote `appmenu-gtk3-module` exige instalação, e ele costuma vir com o Kubuntu.
- **Não simule resolução maior** (`xrandr --scale-from`) sem o usuário pedir. O texto fica borrado e isso foi descartado.
- **Nenhum segredo** vai para este repositório, que é público.
- **Ao adicionar um ajuste novo:** crie um script numerado em `scripts/`, registre em `docs/alteracoes.md` e na tabela do `README.md`.

## Verificações

```bash
# Painéis: esperado "top h=26 ... appmenu ..." e "bottom h=40 autohide | icontasks"
qdbus org.kde.plasmashell /PlasmaShell evaluateScript \
  'panels().forEach(function(p){print(p.location+" h="+p.height+" "+p.hiding+" | "+p.widgets().map(function(w){return w.type}).join(", ")+"\n")})'

# Teclas de volume: esperado "true"
qdbus org.kde.kglobalaccel /component/kmix org.kde.kglobalaccel.Component.isActive

# DPI: esperado 88 (depois do login)
xrdb -query | grep dpi

# Janelas e fontes
kreadconfig5 --file kwinrc --group Windows --key BorderlessMaximizedWindows   # true
kreadconfig5 --file kdeglobals --group General --key font                     # Noto Sans,9,...
```

No Plasma 6, troque `kreadconfig5` por `kreadconfig6` e `qdbus` por `qdbus6`.
