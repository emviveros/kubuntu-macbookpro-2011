# Funções usadas pelos atalhos estilo macOS (scripts/70-teclado-macos.sh)

QUICKLOOK_CMD = os.path.expanduser('~/.local/bin/quicklook-dolphin')
MIDIA_PULAR_CMD = os.path.expanduser('~/.local/bin/midia-pular')
# Existe enquanto a pré-visualização está aberta (criado e apagado pelo script)
QUICKLOOK_OPEN = os.path.join(os.environ.get('XDG_RUNTIME_DIR', '/tmp'), 'quicklook-dolphin.open')


def ctx_quicklook_origin(ctx):
    """Janelas onde o Quick Look funciona: o Dolphin e os ícones da Área de trabalho."""
    return (matchProps(clas="^dolphin$|^org.kde.dolphin$")(ctx) or
            # A janela do plasmashell chamada "Área de trabalho @ QRect(...)"
            # ("Desktop @ QRect(...)" em inglês); painéis e menus do Plasma se
            # chamam só "Plasma" e ficam de fora
            matchProps(clas="^plasmashell$", name=r" @ QRect\(")(ctx))

def km_run(cmd_lst):
    """Roda um comando sem esperar por ele."""
    def _km_run(ctx):
        launch_detached(cmd_lst, stdout=DEVNULL, stderr=DEVNULL)
    return _km_run


def km_screenshot(*args):
    """Captura com o Spectacle e salva na Área de trabalho, com nome no estilo do macOS."""
    def _km_screenshot(ctx):
        import datetime
        desk = subprocess.run(['xdg-user-dir', 'DESKTOP'],
                              capture_output=True, text=True).stdout.strip()
        name = datetime.datetime.now().strftime('Captura de Tela %Y-%m-%d às %H.%M.%S.png')
        launch_detached(['spectacle', '-b', *args, '-o', os.path.join(desk, name)],
                        stdout=DEVNULL, stderr=DEVNULL)
    return _km_screenshot
