# Adaptar para outros ambientes

A especificação do resultado desejado está em [alteracoes.md](alteracoes.md). Aqui estão os equivalentes conhecidos fora do ambiente de referência (Plasma 5.27 em X11). **Os itens abaixo não foram testados nesta máquina.** Confira os nomes de chaves e pacotes na versão instalada antes de aplicar.

## KDE Plasma 6 (Kubuntu 25.04 em diante)

- **Ferramentas:** `kwriteconfig6`, `kreadconfig6`, `qdbus6`, `kquitapp6`, `kstart`. O `scripts/lib.sh` detecta isso sozinho.
- **Janelas, fontes e Dolphin:** usam os mesmos arquivos e chaves; devem funcionar como estão.
- **Painéis:** o script de layout (`files/layout-macos.js`) usa a mesma API. O Plasma 6 cria painéis *flutuantes* por padrão; para ganhar os pixels da margem, desative em *Modo de edição → Flutuante*. O Plasma 6 também tem *Ajustar ao conteúdo* na largura do painel, uma alternativa melhor que `minimumLength`/`maximumLength` para a dock.
- **Teclas de volume:** confirme se o problema de registro ainda acontece; se sim, a mesma solução (reiniciar o plasmashell) vale.

## Wayland (Plasma 6 usa por padrão)

- `forceFontDPI` e `xrdb` **não se aplicam**. Use *Configurações → Tela e monitor → Escala* (ex.: 90%, se a versão permitir abaixo de 100%) ou só reduza as fontes para 8–9 pt.
- **Chrome:** use `--ozone-platform-hint=auto` junto com `--force-device-scale-factor`.
- **Menu global:** apps GTK no Wayland dependem do suporte do app; o `appmenu-gtk-module` pode não funcionar.

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
