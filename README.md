# Kubuntu no MacBook Pro 13" (late 2011)

Ajustes de aproveitamento de tela para um MacBook Pro 8,1 (tela de 1280×800) rodando Kubuntu. O objetivo é caber mais conteúdo na tela, aceitando letras um pouco menores e sem simular uma resolução maior (o texto ficaria borrado).

Se você é um agente de IA reinstalando isto, leia [AGENTS.md](AGENTS.md) primeiro.

## Ambiente onde foi feito

| Item | Valor |
|---|---|
| Máquina | MacBookPro8,1, tela LVDS 1280×800, GPU Intel HD 3000 |
| Sistema | Kubuntu / Ubuntu 26.04 LTS, kernel 7.0 |
| Desktop | KDE Plasma 6.6, sessão **Wayland** |
| Data | 29/09/2026 |

Os scripts começaram no Kubuntu 24.04 (Plasma 5.27, X11) e continuam funcionando lá: onde o Wayland exige outro caminho, eles detectam a sessão.

## Resultado

- **Barra superior** de 26 px no estilo macOS: lançador, **Menu global** (os menus dos apps aparecem na barra), bandeja e relógio.
- **Dock** embaixo, centralizada e do tamanho dos ícones das janelas, **oculta** até o mouse encostar na borda.
- **Barras de título compactas**: botões pequenos, fonte do título de 8 pt e nenhuma borda. As maximizadas mantêm a barra, para não perder fechar/minimizar.
- **Fontes em 9 pt com DPI 88** (no Wayland, 8,3 pt, que dá o mesmo tamanho), o que deixa o texto uns 20% menor que o padrão. Ícones das barras de ferramentas com 16 px.
- **Dolphin** no modo Compacto em todas as pastas.
- **Google Chrome** com escala 0.85.
- **Teclado como no Mac** (Toshy): ⌘+C/V/Q/Tab, capturas com ⌘+Shift+3/4/5 e Quick Look (Espaço) no Dolphin, navegando com as setas (na Área de trabalho só no X11). Os pré-requisitos são instalados por `scripts/00-pacotes.sh`; ver [docs/alteracoes.md](docs/alteracoes.md#7-teclado-estilo-macos-scripts70-teclado-macossh).
- **Gestos do trackpad** estilo macOS: Mission Control, App Exposé, trocar de área de trabalho, Launchpad.
- **Teclas de mídia** controlam o VLC, o YouTube e o YouTube Music. Num vídeo avulso, F7/F9 voltam/avançam 10 s.
- **Brilho no mínimo apaga a tela**, como no macOS; F2 acende de novo.

Os detalhes de cada item (valor anterior, valor novo, arquivo e caminho na interface) estão em [docs/alteracoes.md](docs/alteracoes.md).

## Como aplicar

```bash
git clone https://github.com/emviveros/kubuntu-macbookpro-2011.git
cd kubuntu-macbookpro-2011
./apply.sh          # tudo
./apply.sh 20 50    # só fontes e Dolphin
```

Os scripts fazem backup antes de alterar, em `~/.config/backup-tela-<data>/`. Num sistema novo, rode o `./apply.sh` num terminal: ele pede a senha do sudo para instalar os pacotes e o instalador do Toshy faz perguntas. No fim, reinicie o computador: o Toshy só pega o teclado depois disso, e os scripts do KWin (gestos) só carregam por completo numa sessão nova. O Google Chrome não é instalado pelos scripts.

Para desfazer: `scripts/restore.sh ~/.config/backup-tela-<data>`

| Script | O que faz |
|---|---|
| `scripts/00-pacotes.sh` | Instala o que falta: Toshy, Touchégg 2.x (PPA, só no X11), gnome-sushi, xclip, xdotool, VLC e outros. Pede sudo |
| `scripts/10-janelas.sh` | Barras de título compactas, sem bordas |
| `scripts/20-fontes-dpi.sh` | Fontes 9 pt, DPI 88 (no Wayland, 8,3 pt), ícones 16 px (KDE e GTK) |
| `scripts/30-paineis-macos.sh` | Barra superior com Menu global + dock oculta; reinicia o plasmashell |
| `scripts/40-menu-global-gtk.sh` | Apps GTK mandam o menu para a barra superior |
| `scripts/50-dolphin.sh` | Dolphin no modo Compacto (feche o Dolphin antes) |
| `scripts/60-chrome.sh` | Chrome com escala 0.85 (`CHROME_SCALE=0.9 ./scripts/60-chrome.sh` para mudar) e sem estragar o cache de fontes do sistema |
| `scripts/70-teclado-macos.sh` | Com o Toshy: ⌘ como no Mac, ⌘+Shift+3/4/5 para capturas, Espaço para pré-visualizar no Dolphin e na Área de trabalho |
| `scripts/80-gestos.sh` | Gestos de 3 e 4 dedos (Touchégg 2.x no X11, script do KWin no Wayland), 4 áreas de trabalho |
| `scripts/85-brilho.sh` | Plasma 6: a tecla de diminuir o brilho apaga a tela no mínimo |
| `scripts/90-antigravity.sh` | Google Antigravity: app 2.0 (`antigravity`), IDE (`antigravity-ide`) e CLI (`agy`), sem estragar o cache de fontes do sistema |

## Atalhos úteis para janelas

| Atalho | Ação |
|---|---|
| `Alt+F4` | Fechar |
| `Alt+F3` | Menu da janela (restaurar, minimizar, mover) |
| `Meta+PgUp` / `Meta+PgDown` | Maximizar / restaurar |
| `Alt` + arrastar | Mover a janela |

## Mais documentação

- [docs/alteracoes.md](docs/alteracoes.md): cada alteração com arquivo, chave e caminho na interface
- [docs/problemas-conhecidos.md](docs/problemas-conhecidos.md): o que deu errado e como resolver
- [docs/outros-ambientes.md](docs/outros-ambientes.md): diferenças entre Plasma 5/X11 e Plasma 6/Wayland, e como adaptar para GNOME e XFCE
- [docs/ajustes-manuais.md](docs/ajustes-manuais.md): o que precisa ser feito dentro de cada app
- [memtest86/](memtest86/README.md): teste completo da RAM fora do sistema (MemTest86 no próximo boot, com relatório), fora do `apply.sh`
