# Funções usadas pelos atalhos estilo macOS (scripts/70-teclado-macos.sh)

QUICKLOOK_CMD = os.path.expanduser('~/.local/bin/quicklook-dolphin')        # X11
QUICKLOOK_WL_CMD = os.path.expanduser('~/.local/bin/quicklook-wayland')     # Wayland
QUICKLOOK_WAYLAND = SESSION_TYPE == 'wayland'
# Área de transferência de antes do Quick Look (Wayland), restaurada ao fechar
QUICKLOOK_CLIP = os.path.join(os.environ.get('XDG_RUNTIME_DIR', '/tmp'), 'quicklook-dolphin.clip')
MIDIA_PULAR_CMD = os.path.expanduser('~/.local/bin/midia-pular')
# Existe enquanto a pré-visualização está aberta (criado e apagado pelo script)
QUICKLOOK_OPEN = os.path.join(os.environ.get('XDG_RUNTIME_DIR', '/tmp'), 'quicklook-dolphin.open')


def ctx_quicklook_origin(ctx):
    """Janelas onde o Quick Look funciona: o Dolphin e os ícones da Área de trabalho."""
    if matchProps(clas="^dolphin$|^org.kde.dolphin$")(ctx):
        return True
    if QUICKLOOK_WAYLAND:
        # No Wayland a Área de trabalho é "plasmashell" sem título; os menus do
        # Plasma são "org.kde.plasmashell" e ficam de fora. O Toshy troca o
        # título vazio por "ERR: KeyContext: NoneType in wm_name", por isso o
        # matchProps() não serve aqui.
        return (ctx.wm_class == "plasmashell" and
                (not ctx.wm_name or ctx.wm_name.startswith("ERR:")))
    # X11: a janela do plasmashell chamada "Área de trabalho @ QRect(...)"
    # ("Desktop @ QRect(...)" em inglês); painéis e menus do Plasma se chamam
    # só "Plasma" e ficam de fora
    return matchProps(clas="^plasmashell$", name=r" @ QRect\(")(ctx)

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


_quicklook_last = 0.0

def km_quicklook_wl(space=False):
    """Quick Look no Wayland: abre ou fecha a pré-visualização do item selecionado.

    Manda Ctrl+C à janela em foco e lê o endereço pelo Klipper. Se nada foi
    copiado como arquivo (renomeando, filtrando), digita o Espaço normalmente.
    A área de transferência de antes é guardada e volta quando a
    pré-visualização fecha (quicklook-wayland --closed).
    """
    def _km_quicklook_wl(ctx):
        global _quicklook_last
        import time, dbus
        # Com a tecla segurada as chamadas se repetem; cada uma abriria ou
        # fecharia a pré-visualização
        now = time.time()
        if now - _quicklook_last < 0.7:
            return None
        _quicklook_last = now
        if os.path.exists(QUICKLOOK_OPEN):
            launch_detached([QUICKLOOK_WL_CMD, '--close'], stdout=DEVNULL, stderr=DEVNULL)
            return None
        try:
            klipper = dbus.Interface(dbus.SessionBus().get_object('org.kde.klipper', '/klipper'),
                                     'org.kde.klipper.klipper')
            before = str(klipper.getClipboardContents())
            with open(QUICKLOOK_CLIP, 'w') as f:
                f.write(before)
            klipper.clearClipboardContents()
        except Exception as e:
            error(f'Quick Look: Klipper indisponível: {e}')
            return C("Space") if space else None

        def _after_copy(ctx):
            uri = ''
            for _ in range(12):
                time.sleep(0.025)
                text = str(klipper.getClipboardContents())
                if text:
                    if text.startswith('file://'):
                        uri = text.split()[0]
                    break
            if uri:
                launch_detached([QUICKLOOK_WL_CMD, '--show', uri], stdout=DEVNULL, stderr=DEVNULL)
                return None
            launch_detached([QUICKLOOK_WL_CMD, '--restore'], stdout=DEVNULL, stderr=DEVNULL)
            return C("Space") if space else None

        return [C("C-c"), _after_copy]
    return _km_quicklook_wl
