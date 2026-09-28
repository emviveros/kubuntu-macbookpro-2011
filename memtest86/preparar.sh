#!/usr/bin/env bash
# Agenda o MemTest86 para o PRÓXIMO boot (uma vez só).
#   sudo ./preparar.sh            -> agenda e pergunta se quer reiniciar
#   sudo ./preparar.sh --cancelar -> desfaz tudo sem testar
# Tudo que acontece aqui fica em preparacao.log, nesta pasta.
set -eo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"
ESP=/boot/efi
DIR_ESP=$ESP/EFI/memtest86
MARCA=/var/lib/memtest86-auto/agendado

[ "$EUID" -eq 0 ] || { echo "Rode com sudo: sudo $0"; exit 1; }
USUARIO=${SUDO_USER:?rode com sudo a partir do seu usuário}

if [ "${1:-}" = "--cancelar" ]; then
  exec "$AQUI/coletar.sh" --cancelar
fi

touch "$AQUI/preparacao.log"
exec > >(tee -a "$AQUI/preparacao.log") 2>&1
chown "$USUARIO:" "$AQUI/preparacao.log"
echo "===== $(date '+%F %T') preparar.sh"

falha() { echo "ERRO: $*"; echo "Nada foi agendado. Desfazendo..."; "$AQUI/coletar.sh" --cancelar; exit 1; }

# 1. Conferências
[ -d /sys/firmware/efi ] || falha "o sistema não iniciou em modo EFI"
mountpoint -q "$ESP" || mount "$ESP" || falha "partição EFI não montada"
[ -f "$AQUI/bin/BOOTX64.efi" ] || falha "arquivos do MemTest86 não encontrados em $AQUI/bin (rode ./baixar.sh)"
echo "$(sha256sum "$AQUI/bin/BOOTX64.efi" | cut -c1-64)" | grep -q '^1dbe38feb0e906eaa303e4681f470b18278b6beb038780c0c1d7d0c26d7d5d27$' \
  || falha "BOOTX64.efi diferente do que foi testado"
DESKTOP=$(sudo -u "$USUARIO" xdg-user-dir DESKTOP 2>/dev/null || echo "/home/$USUARIO/Desktop")
[ -d "$DESKTOP" ] || falha "área de trabalho não encontrada ($DESKTOP)"
echo "Área de trabalho: $DESKTOP"

# 2. MemTest86 na partição EFI + marca "rodar uma vez"
find "$ESP/EFI" -maxdepth 2 -iname 'MemTest86-*' -type f -delete   # logs antigos
mkdir -p "$DIR_ESP"
cp -r "$AQUI/bin/." "$DIR_ESP/"
rm -f "$DIR_ESP/grubenv"
grub-editenv "$DIR_ESP/grubenv" create
grub-editenv "$DIR_ESP/grubenv" set mt86_once=1 mt86_status=agendado
grub-editenv "$DIR_ESP/grubenv" list
sync

# 3. Serviço que coleta os resultados no boot seguinte
mkdir -p "$(dirname "$MARCA")"
install -m 755 "$AQUI/coletar.sh" /usr/local/sbin/memtest86-coletar
cat > /etc/systemd/system/memtest86-coletar.service <<'EOF'
[Unit]
Description=Coleta o resultado do MemTest86 e desfaz o agendamento
After=local-fs.target boot-efi.mount
RequiresMountsFor=/boot/efi

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/memtest86-coletar

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable memtest86-coletar.service
printf 'USUARIO=%q\nDESKTOP=%q\nAGENDADO_EM=%q\n' "$USUARIO" "$DESKTOP" "$(date '+%F %T')" > "$MARCA"

# 4. Trecho no GRUB
install -m 755 "$AQUI/06_memtest86_uma_vez" /etc/grub.d/06_memtest86_uma_vez
update-grub
grep -q '### memtest86 uma vez ###' /boot/grub/grub.cfg || falha "trecho não entrou no grub.cfg"
grub-script-check /boot/grub/grub.cfg || falha "grub.cfg com erro de sintaxe"

echo
echo "Tudo pronto. No próximo boot o MemTest86 começa sozinho."
echo "Ele faz 4 passadas e pode levar a noite toda (cada passada testa os 16 GB inteiros)."
echo "Deixe ligado na tomada. No fim, aperte qualquer tecla ou desligue no botão: o log"
echo "já estará salvo. Ao voltar ao Kubuntu, o relatório aparece na área de trabalho."
read -r -p "Reiniciar agora? [s/N] " r
[[ "$r" =~ ^[sS]$ ]] && systemctl reboot
exit 0
