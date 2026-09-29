# Atalhos estilo macOS (scripts/70-teclado-macos.sh). Ficam antes dos atalhos
# gerais do Toshy, então têm prioridade sobre eles.
# ⌘ chega aqui como RC; Ctrl físico chega como Super nos apps gráficos e como
# LC nos terminais, por isso as capturas para a área de transferência têm as duas formas.

keymap("User macOS capturas de tela", {
    C("RC-Shift-Key_3"):        km_screenshot('-f'),                             # Tela inteira → Área de trabalho
    C("RC-Shift-Key_4"):        km_screenshot('-r'),                             # Região → Área de trabalho
    C("RC-Shift-Key_5"):        km_run(['spectacle', '-l']),                     # Painel de captura
    C("Super-RC-Shift-Key_3"):  km_run(['spectacle', '-b', '-n', '-c', '-f']),   # Tela inteira → área de transferência
    C("Super-RC-Shift-Key_4"):  km_run(['spectacle', '-b', '-n', '-c', '-r']),   # Região → área de transferência
    C("LC-RC-Shift-Key_3"):     km_run(['spectacle', '-b', '-n', '-c', '-f']),
    C("LC-RC-Shift-Key_4"):     km_run(['spectacle', '-b', '-n', '-c', '-r']),
}, when = lambda ctx:
    cnfg.screen_has_focus and
    not ctx_app_is_remote
)

# Com a pré-visualização aberta, o foco fica no Dolphin: as setas movem a seleção
# e a pré-visualização acompanha, como no Finder. No Wayland a seleção só pode
# ser lida depois de um Ctrl+C mandado daqui (ver quicklook-wayland).
if QUICKLOOK_WAYLAND:
    def _ql_seta(key):
        return [C(key), C("C-c"), km_run([QUICKLOOK_WL_CMD, '--sync'])]
    _ql_fechar = km_run([QUICKLOOK_WL_CMD, '--close'])
    _ql_espaco, _ql_cmd_y = km_quicklook_wl(space=True), km_quicklook_wl()
else:
    def _ql_seta(key):
        return [C(key), km_run([QUICKLOOK_CMD, '--sync'])]
    _ql_fechar = km_run([QUICKLOOK_CMD, '--close'])
    _ql_espaco, _ql_cmd_y = km_run([QUICKLOOK_CMD, '--space']), km_run([QUICKLOOK_CMD])

keymap("User macOS Quick Look aberto", {
    C("Up"):                    _ql_seta("Up"),
    C("Down"):                  _ql_seta("Down"),
    C("Left"):                  _ql_seta("Left"),
    C("Right"):                 _ql_seta("Right"),
    C("Esc"):                   _ql_fechar,                                      # Esc: fechar
}, when = lambda ctx:
    cnfg.screen_has_focus and
    os.path.exists(QUICKLOOK_OPEN) and
    ctx_quicklook_origin(ctx)
)

keymap("User macOS Quick Look", {
    C("Space"):                 _ql_espaco,                                      # Espaço: pré-visualizar/fechar
    C("RC-y"):                  _ql_cmd_y,                                       # ⌘+Y: pré-visualizar/fechar
    C("Alt-RC-Backspace"):      C("Shift-Delete"),                               # ⌘+Option+Delete: apagar de vez
}, when = lambda ctx:
    cnfg.screen_has_focus and
    ctx_quicklook_origin(ctx)
)

# ⌘+Delete apaga até o começo da linha, como no macOS. O Toshy só faz isso no
# Firefox e no Thunderbird; nos outros apps chegava como Ctrl+Backspace, que
# apaga só a palavra anterior. Gerenciadores de arquivos e a Área de trabalho
# (mover para a lixeira) e terminais (Ctrl+U) já têm regras próprias.
keymap("User macOS ⌘+Delete em texto", {
    C("RC-Backspace"):          [C("Shift-Home"), C("Backspace")],               # Apaga até o começo da linha
}, when = lambda ctx:
    cnfg.screen_has_focus and
    not hmp_is_filemanager(ctx) and
    not ctx_quicklook_origin(ctx) and
    not ctx_app_is_terminal and
    not ctx_app_is_remote
)

# F7/F9: faixa anterior/próxima quando o player oferece; senão volta/avança 10 s
# (vídeo avulso do YouTube). Substitui o tratamento do KDE para essas teclas.
keymap("User macOS teclas de mídia", {
    C("PreviousSong"):          km_run([MIDIA_PULAR_CMD, 'previous']),            # F7
    C("NextSong"):              km_run([MIDIA_PULAR_CMD, 'next']),                # F9
}, when = lambda ctx:
    cnfg.screen_has_focus
)

keymap("User macOS Launchpad", {
    # F4 do MacBook 2011 (sem Fn) é a tecla Dashboard (KEY_DASHBOARD). O atalho
    # extra que o KDE guarda para o lançador se perde quando o plasmashell reinicia.
    C("Dashboard"):             C("Alt-F1"),                                     # F4: lançador de aplicativos
}, when = lambda ctx:
    cnfg.screen_has_focus and
    not ctx_app_is_remote
)

# Ctrl+setas são atalhos do sistema, como no macOS, e valem em qualquer app.
# O Ctrl físico chega como Super nos apps gráficos e como LC nos terminais, e
# continua como LC se a tecla for apertada no terminal e a troca de área mudar o
# foco. Por isso as duas formas. Sem isto, o bloco "GenGUI overrides: Ubuntu"
# do Toshy (só confere DISTRO_ID == 'ubuntu') manda Meta+PgDown/PgUp, que no
# KDE minimizam/maximizam a janela.
keymap("User macOS Ctrl+setas", {
    C("Super-Left"):            C("C-Super-Left"),                               # Área à esquerda
    C("Super-Right"):           C("C-Super-Right"),                              # Área à direita
    C("LC-Left"):               C("C-Super-Left"),
    C("LC-Right"):              C("C-Super-Right"),
    C("LC-Up"):                 C("Super-Up"),                                   # Visão geral
    C("LC-Down"):               C("Super-Down"),                                 # Janelas do app
}, when = lambda ctx:
    cnfg.screen_has_focus and
    not ctx_app_is_remote
)
