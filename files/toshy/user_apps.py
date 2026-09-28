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
