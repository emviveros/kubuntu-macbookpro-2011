#!/usr/bin/env bash
# Baixa o MemTest86 Free (PassMark) e extrai para bin/ os arquivos que vão para a
# partição EFI. Os binários não ficam no repositório (licença da PassMark);
# o sha256 garante que é a mesma versão testada (V11.7, imagem de 2026-05-04).
# Precisa de: curl, unzip, 7z (p7zip-full). Não usa sudo.
set -euo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"
URL=https://www.memtest86.com/downloads/memtest86-usb.zip
SHA_BOOTX64=1dbe38feb0e906eaa303e4681f470b18278b6beb038780c0c1d7d0c26d7d5d27

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
echo "Baixando $URL ..."
# o site recusa (403) o user-agent padrão do curl
curl -sSfL -A 'Mozilla/5.0 (X11; Linux x86_64)' -o "$TMP/mt86.zip" "$URL"
unzip -q "$TMP/mt86.zip" memtest86-usb.img -d "$TMP"
7z x -y -o"$TMP/parts" "$TMP/memtest86-usb.img" >/dev/null
7z x -y -o"$TMP/esp" "$TMP/parts/1.EFI System Partition.img" EFI/BOOT license.rtf >/dev/null

B=$TMP/esp/EFI/BOOT
[ "$(sha256sum "$B/BOOTX64.efi" | cut -c1-64)" = "$SHA_BOOTX64" ] || {
  echo "ERRO: BOOTX64.efi baixado é outra versão. Teste numa VM antes de atualizar SHA_BOOTX64 aqui e nos scripts."
  exit 1
}
rm -rf "$AQUI/bin"; mkdir -p "$AQUI/bin/Benchmark"
cp "$B/BOOTX64.efi" "$B/unifont.bin" "$B/blacklist.cfg" "$B/mt86.png" "$TMP/esp/license.rtf" "$AQUI/bin/"
echo "Pronto: $AQUI/bin"; ls -la "$AQUI/bin"
