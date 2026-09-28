# Funções usadas pelos atalhos estilo macOS (scripts/70-teclado-macos.sh)

QUICKLOOK_CMD = os.path.expanduser('~/.local/bin/quicklook-dolphin')

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
