#!/usr/bin/env bash
# Diagnóstico curto (~5 min): o Mac abre o MemTest86 direto pelo firmware
# (BootNext, sem GRUB) e, assim, o MemTest86 consegue gravar na partição EFI?
#   sudo ./diagnostico-bootnext.sh            -> prepara e pergunta se reinicia
#   sudo ./diagnostico-bootnext.sh --verificar -> depois do boot: mostra o resultado e limpa tudo
#   sudo ./diagnostico-bootnext.sh --cancelar  -> só limpa
# Tudo fica registrado em diagnostico-bootnext.log, nesta pasta.
set -eo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"
ESP=/boot/efi
DIR_ESP=$ESP/EFI/memtest86
ESTADO=/var/lib/memtest86-diag/entrada
ROTULO="MemTest86 (diagnostico)"

[ "$EUID" -eq 0 ] || { echo "Rode com sudo: sudo $0 $*"; exit 1; }
USUARIO=${SUDO_USER:?rode com sudo a partir do seu usuário}
touch "$AQUI/diagnostico-bootnext.log"; chown "$USUARIO:" "$AQUI/diagnostico-bootnext.log"
exec > >(tee -a "$AQUI/diagnostico-bootnext.log") 2>&1
echo "===== $(date '+%F %T') diagnostico-bootnext.sh ${1:-preparar}"
mountpoint -q "$ESP" || mount "$ESP"
# disco e número da partição EFI, para a entrada de boot
PART_DEV=$(findmnt -no SOURCE "$ESP")
DISCO=/dev/$(lsblk -no PKNAME "$PART_DEV")
PART=$(cat "/sys/class/block/$(basename "$PART_DEV")/partition")

limpar() {
  if [ -f "$ESTADO" ]; then
    n=$(cat "$ESTADO")
    efibootmgr -q -b "$n" -B && echo "Entrada Boot$n removida."
  fi
  efibootmgr | grep '^BootNext' >/dev/null && efibootmgr -q -N && echo "BootNext pendente removido."
  find "$ESP" -maxdepth 3 -iname 'MemTest86-*' -type f -delete
  rm -rf "$DIR_ESP" "$(dirname "$ESTADO")"
  echo "Limpeza concluída. BootOrder atual:"; efibootmgr | grep -E '^Boot(Current|Order)'
}

case "${1:-}" in
  --cancelar) limpar; exit 0 ;;
  --verificar)
    [ -f "$ESTADO" ] || { echo "Nada preparado."; exit 0; }
    echo "== Entradas de boot"; efibootmgr
    echo; echo "== Arquivos do MemTest86 na partição EFI"
    achados=$(find "$ESP" -maxdepth 3 -iname 'MemTest86-*' -type f)
    if [ -n "$achados" ]; then
      DESKTOP=$(sudo -u "$USUARIO" xdg-user-dir DESKTOP)
      DEST="$DESKTOP/Diagnóstico MemTest86 $(date +%F)"
      mkdir -p "$DEST"
      while IFS= read -r f; do ls -la "$f"; cp "$f" "$DEST/"; done <<< "$achados"
      chown -R "$USUARIO:" "$DEST"
      echo; echo "RESULTADO: o MemTest86 CONSEGUIU gravar. Cópias em: $DEST"
    else
      echo "(nenhum)"
      echo; echo "RESULTADO: nada foi gravado."
    fi
    echo; limpar; exit 0 ;;
  "") ;;
  *) echo "Opção desconhecida: $1"; exit 1 ;;
esac

# --- preparar ---
[ -d /sys/firmware/efi ] || { echo "ERRO: sistema não iniciou em modo EFI"; exit 1; }
[ ! -f "$ESTADO" ] || { echo "Já preparado. Use --verificar ou --cancelar."; exit 1; }
echo "$(sha256sum "$AQUI/bin/BOOTX64.efi" | cut -c1-64)" | grep -q '^1dbe38feb0e906eaa303e4681f470b18278b6beb038780c0c1d7d0c26d7d5d27$' \
  || { echo "ERRO: BOOTX64.efi diferente do que foi testado"; exit 1; }

echo "== Antes"; efibootmgr
mkdir -p "$DIR_ESP"
cp -r "$AQUI/bin/." "$DIR_ESP/"
sync

saida=$(efibootmgr --create-only --disk "$DISCO" --part "$PART" --label "$ROTULO" --loader '\EFI\memtest86\BOOTX64.efi')
n=$(printf '%s\n' "$saida" | grep -F "$ROTULO" | grep -o '^Boot[0-9A-Fa-f]\{4\}' | cut -c5- | tail -1)
[ -n "$n" ] || { echo "ERRO: não consegui criar a entrada de boot"; limpar; exit 1; }
mkdir -p "$(dirname "$ESTADO")"; echo "$n" > "$ESTADO"
efibootmgr -q --bootnext "$n"
echo; echo "== Depois (BootNext deve ser $n; BootOrder não muda)"; efibootmgr

cat <<EOF

Pronto. Ao reiniciar:
  1. Se aparecer a tela do MemTest86 SEM passar pelo menu do GRUB, o Mac aceitou o BootNext.
     (Se cair direto no Kubuntu, o Mac ignorou; rode --verificar mesmo assim.)
  2. Na tela do MemTest86, antes do teste começar, aperte uma tecla para ficar no menu
     e depois F12 (captura de tela). Anote a mensagem que aparecer.
  3. Comece o teste (S), deixe rodar uns 2 minutos e desligue segurando o botão.
  4. De volta ao Kubuntu:  sudo $AQUI/diagnostico-bootnext.sh --verificar
O BootNext vale uma vez só: o boot seguinte volta ao normal sozinho.
EOF
read -r -p "Reiniciar agora? [s/N] " r
[[ "$r" =~ ^[sS]$ ]] && systemctl reboot
exit 0
