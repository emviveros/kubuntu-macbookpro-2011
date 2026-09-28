#!/usr/bin/env bash
# Roda no boot seguinte ao MemTest86 (serviço memtest86-coletar.service):
# copia os logs da partição EFI para a área de trabalho, gera o relatório,
# grava um diagnóstico e desfaz tudo que preparar.sh instalou.
#   memtest86-coletar            -> coleta + limpeza (uso normal, pelo systemd)
#   memtest86-coletar --cancelar -> só limpeza, sem relatório
set -u
ESP=${ESP:-/boot/efi}
DIR_ESP=$ESP/EFI/memtest86
MARCA=${MARCA:-/var/lib/memtest86-auto/agendado}

limpar() {
  [ -n "${MT86_TESTE:-}" ] && { echo "(teste: limpeza pulada)"; return; }
  rm -f /etc/grub.d/06_memtest86_uma_vez
  update-grub >/dev/null 2>&1 || echo "AVISO: update-grub falhou"
  find "$ESP/EFI" -maxdepth 2 -iname 'MemTest86-*' -type f -delete
  rm -rf "$DIR_ESP"
  systemctl disable memtest86-coletar.service >/dev/null 2>&1
  rm -f /etc/systemd/system/memtest86-coletar.service
  rm -rf /var/lib/memtest86-auto
  rm -f /usr/local/sbin/memtest86-coletar
}

if [ "${1:-}" = "--cancelar" ]; then
  limpar
  echo "Agendamento cancelado e tudo removido."
  exit 0
fi

[ -f "$MARCA" ] || { echo "Nada agendado."; exit 0; }
. "$MARCA"   # USUARIO, DESKTOP, AGENDADO_EM

[ -n "${MT86_TESTE:-}" ] || mountpoint -q "$ESP" || mount "$ESP"
DEST="$DESKTOP/Teste MemTest86 $(date +%F)"
mkdir -p "$DEST"

# --- diagnóstico: tudo que ajuda a entender o que aconteceu ---
{
  echo "== Coleta em $(date '+%F %T') (agendado em $AGENDADO_EM)"
  echo; echo "== Marca do GRUB (grubenv)"
  grub-editenv "$DIR_ESP/grubenv" list 2>&1
  echo; echo "== Arquivos na partição EFI"
  find "$ESP/EFI" -maxdepth 2 -printf '%TY-%Tm-%Td %TH:%TM  %10s  %p\n' 2>&1 | sort
  echo; echo "== Trecho no grub.cfg"
  grep -c '### memtest86 uma vez ###' /boot/grub/grub.cfg 2>&1
  echo; echo "== Boots recentes"
  journalctl --list-boots --no-pager 2>&1 | tail -5
  echo; echo "== Boot anterior (últimas linhas)"
  journalctl -b -1 --no-pager -n 30 2>&1
} > "$DEST/diagnostico.txt"

# --- copia os logs e relatórios do MemTest86 ---
LOG=""
while IFS= read -r f; do
  nome=$(basename "$f")
  case "$nome" in
    *.log) if file -b "$f" | grep -q UTF-16; then iconv -f UTF-16 -t UTF-8 "$f"; else cat "$f"; fi | tr -d '\r' > "$DEST/$nome"
           LOG="$DEST/$nome" ;;
    *) cp "$f" "$DEST/" ;;
  esac
done < <(find "$ESP/EFI" -maxdepth 2 -iname 'MemTest86-*' -type f | sort)

STATUS=$(grub-editenv "$DIR_ESP/grubenv" list 2>/dev/null | sed -n 's/^mt86_status=//p')

# --- interpreta o log ---
PASSES_INI=0; PASSES_TOTAL="?"; PASSES_OK=0; ERROS=0; INICIO=""; FIM=""
if [ -n "$LOG" ]; then
  PASSES_INI=$(grep -c 'Starting pass #' "$LOG")
  PASSES_TOTAL=$(grep -o 'Starting pass #[0-9]* (of [0-9]*)' "$LOG" | tail -1 | grep -o 'of [0-9]*' | grep -o '[0-9]*')
  PASSES_OK=$(grep -c 'Finished pass #' "$LOG")
  ERROS=$(grep -o -i -E '(cumulative )?error count: [0-9]+' "$LOG" | grep -o -E '[0-9]+$' | sort -n | tail -1)
  ERROS=${ERROS:-0}
  INICIO=$(head -1 "$LOG" | cut -c1-19)
  FIM=$(tail -1 "$LOG" | cut -c1-19)
fi

if [ "$STATUS" = "agendado" ]; then
  COR=warn; TITULO="O teste não chegou a rodar"
  TEXTO="O GRUB não iniciou o MemTest86. O computador ligou direto no Kubuntu. Veja o diagnostico.txt."
elif [ "$STATUS" = "falhou-ao-iniciar" ]; then
  COR=warn; TITULO="O MemTest86 não abriu neste Mac"
  TEXTO="O GRUB tentou abrir o MemTest86, mas o firmware recusou. Nenhuma memória foi testada."
elif [ -z "$LOG" ]; then
  COR=warn; TITULO="O teste começou, mas não deixou log"
  TEXTO="O MemTest86 foi chamado, mas não gravou nada. Isso não quer dizer que não testou: aberto pelo GRUB neste Mac, ele roda o teste inteiro mas não consegue gravar (\"Unable to open file for writing\"). O resultado só existe na tela; veja memtest86/README.md no repositório. O número de erros abaixo NÃO vale."
elif [ "$ERROS" -gt 0 ]; then
  COR=bad; TITULO="Foram encontrados $ERROS erros de memória"
  TEXTO="Há defeito na memória. O próximo passo é testar um pente de cada vez para achar o defeituoso."
elif [ "$PASSES_OK" -gt 0 ] && [ "$PASSES_OK" = "$PASSES_TOTAL" ]; then
  COR=ok; TITULO="Nenhum defeito encontrado"
  TEXTO="A memória inteira foi testada, fora do sistema, em $PASSES_OK passadas completas, sem nenhum erro."
elif [ "$PASSES_OK" -gt 0 ]; then
  COR=ok; TITULO="Nenhum defeito encontrado ($PASSES_OK de $PASSES_TOTAL passadas)"
  TEXTO="O teste foi interrompido antes do fim, mas a memória inteira já tinha sido testada $PASSES_OK vez(es), sem nenhum erro. Uma passada completa já é um bom sinal."
else
  COR=warn; TITULO="Teste interrompido, sem erros até ali"
  TEXTO="O teste não chegou ao fim (desligado antes ou travou), mas não houve nenhum erro até o ponto em que parou."
fi

cat > "$DEST/Relatório.html" <<EOF
<!doctype html>
<html lang="pt-BR"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Teste completo da memória</title>
<style>
:root{--bg:#f6f5f1;--card:#fff;--text:#1f2328;--muted:#5d6470;--line:#e2e0da;
--ok:#1a7f37;--ok-bg:#e6f4ea;--warn:#8a5a00;--warn-bg:#fdf3dc;--bad:#b42318;--bad-bg:#fde8e7}
@media (prefers-color-scheme:dark){:root{--bg:#16181c;--card:#1f2227;--text:#e8e6e3;--muted:#a0a6b0;
--line:#33373e;--ok:#4ac26b;--ok-bg:#16301f;--warn:#e3b341;--warn-bg:#33290f;--bad:#ff7b72;--bad-bg:#3b1715}}
body{margin:0;background:var(--bg);color:var(--text);font:17px/1.6 "Noto Sans",system-ui,sans-serif}
main{max-width:720px;margin:0 auto;padding:32px 16px 64px}
h1{font-size:1.6rem;margin:0 0 4px}.date{color:var(--muted);margin:0 0 24px}
.v{border-radius:12px;padding:20px 22px;margin-bottom:28px;border:1px solid var(--$COR);background:var(--$COR-bg)}
.v strong{color:var(--$COR);font-size:1.35rem;display:block;margin-bottom:4px}
.card{background:var(--card);border:1px solid var(--line);border-radius:12px;padding:4px 20px}
.row{display:flex;justify-content:space-between;gap:16px;padding:12px 0;border-bottom:1px solid var(--line)}
.row:last-child{border-bottom:0}.row span:first-child{color:var(--muted)}.row span:last-child{font-weight:600;text-align:right}
.small{color:var(--muted);font-size:.9rem;margin-top:40px}
</style></head><body><main>
<h1>Memória RAM do MacBook: teste completo</h1>
<p class="date">MemTest86 rodando antes do sistema, de $INICIO a $FIM (UTC)</p>
<div class="v"><strong>$TITULO</strong>$TEXTO</div>
<div class="card">
<div class="row"><span>Passadas completas</span><span>$PASSES_OK de $PASSES_TOTAL</span></div>
<div class="row"><span>Erros encontrados</span><span>$ERROS</span></div>
<div class="row"><span>Situação registrada pelo GRUB</span><span>${STATUS:-desconhecida}</span></div>
</div>
<p class="small">Nesta pasta estão também o log completo do MemTest86 e o arquivo diagnostico.txt, com o que aconteceu em cada etapa.</p>
</main></body></html>
EOF

[ -n "${MT86_TESTE:-}" ] || chown -R "$USUARIO:" "$DEST"
limpar
echo "Relatório em: $DEST"
