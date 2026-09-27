# Kubuntu no MacBook Pro 13" (late 2011)

Ajustes de aproveitamento de tela para um MacBook Pro 8,1 (tela de 1280×800) rodando Kubuntu. O objetivo é caber mais conteúdo na tela, aceitando letras um pouco menores e sem simular uma resolução maior (o texto ficaria borrado).

Se você é um agente de IA reinstalando isto, leia [AGENTS.md](AGENTS.md) primeiro.

## Ambiente onde foi feito

| Item | Valor |
|---|---|
| Máquina | MacBookPro8,1, tela LVDS 1280×800, GPU Intel HD 3000 |
| Sistema | Kubuntu / Ubuntu 24.04 LTS, kernel 6.8 |
| Desktop | KDE Plasma 5.27, sessão **X11** |
| Data | 27/09/2026 |

## Resultado

- **Barra superior** de 26 px no estilo macOS: lançador, **Menu global** (os menus dos apps aparecem na barra), bandeja e relógio.
- **Dock** embaixo só com os ícones das janelas, **oculta** até o mouse encostar na borda.
- **Janelas maximizadas sem barra de título**. As não maximizadas têm botões pequenos, fonte do título de 8 pt e nenhuma borda.
- **Fontes em 9 pt com DPI 88**, o que deixa o texto uns 20% menor que o padrão. Ícones das barras de ferramentas com 16 px.
- **Dolphin** no modo Compacto em todas as pastas.
- **Google Chrome** com escala 0.85.

Os detalhes de cada item (valor anterior, valor novo, arquivo e caminho na interface) estão em [docs/alteracoes.md](docs/alteracoes.md).

## Como aplicar

```bash
git clone https://github.com/emviveros/kubuntu-macbookpro-2011.git
cd kubuntu-macbookpro-2011
./apply.sh          # tudo
./apply.sh 20 50    # só fontes e Dolphin
```

Os scripts fazem backup antes de alterar, em `~/.config/backup-tela-<data>/`. No fim, saia e entre na sessão.

Para desfazer: `scripts/restore.sh ~/.config/backup-tela-<data>`

| Script | O que faz |
|---|---|
| `scripts/10-janelas.sh` | Barras de título compactas, janelas maximizadas sem barra de título |
| `scripts/20-fontes-dpi.sh` | Fontes 9 pt, DPI 88, ícones 16 px (KDE e GTK) |
| `scripts/30-paineis-macos.sh` | Barra superior com Menu global + dock oculta; reinicia o plasmashell |
| `scripts/40-menu-global-gtk.sh` | Apps GTK mandam o menu para a barra superior |
| `scripts/50-dolphin.sh` | Dolphin no modo Compacto (feche o Dolphin antes) |
| `scripts/60-chrome.sh` | Chrome com escala 0.85 (`CHROME_SCALE=0.9 ./scripts/60-chrome.sh` para mudar) |

## Atalhos úteis com janelas sem barra de título

| Atalho | Ação |
|---|---|
| `Alt+F4` | Fechar |
| `Alt+F3` | Menu da janela (restaurar, minimizar, mover) |
| `Meta+PgUp` / `Meta+PgDown` | Maximizar / restaurar |
| `Alt` + arrastar | Mover a janela |

## Mais documentação

- [docs/alteracoes.md](docs/alteracoes.md): cada alteração com arquivo, chave e caminho na interface
- [docs/problemas-conhecidos.md](docs/problemas-conhecidos.md): o que deu errado e como resolver
- [docs/outros-ambientes.md](docs/outros-ambientes.md): como adaptar para Plasma 6, Wayland, GNOME e XFCE
- [docs/ajustes-manuais.md](docs/ajustes-manuais.md): o que precisa ser feito dentro de cada app
