# Roda no login, antes do Plasma (~/.config/plasma-workspace/env/).
# O Chrome 154 regrava o cache de fontes do usuário num formato mais novo
# (cache-12) e troca os arquivos cache-9 do fontconfig do sistema por links para
# ele. O fontconfig do sistema lê o formato errado e o plasmashell cai ao
# desenhar texto. O 60-chrome.sh já abre o Chrome com um cache separado; isto
# limpa o estrago se o Chrome for aberto de outro jeito. O fontconfig refaz o
# cache sozinho.
if [ -d "$HOME/.cache/fontconfig" ]; then
    find "$HOME/.cache/fontconfig" -maxdepth 1 \( -type l -name '*.cache-*' -o -name '*.cache-1[0-9]' \) -delete 2>/dev/null
fi
