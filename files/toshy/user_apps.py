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

keymap("User macOS Quick Look no Dolphin", {
    C("Space"):                 km_run([QUICKLOOK_CMD, '--space']),              # Espaço: pré-visualizar
    C("RC-y"):                  km_run([QUICKLOOK_CMD]),                         # ⌘+Y: pré-visualizar
    C("Alt-RC-Backspace"):      C("Shift-Delete"),                               # ⌘+Option+Delete: apagar de vez
}, when = lambda ctx:
    cnfg.screen_has_focus and
    matchProps(clas="^dolphin$|^org.kde.dolphin$")(ctx)
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
