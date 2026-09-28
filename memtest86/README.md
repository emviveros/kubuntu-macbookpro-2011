# Teste completo da RAM com MemTest86

Roda o MemTest86 Free (PassMark) **fora do sistema**, no próximo boot e uma vez só, sem pendrive. No boot seguinte, um serviço copia o log para a área de trabalho, gera um `Relatório.html` e desfaz tudo o que foi instalado.

Motivo: um teste em userspace (`memtester`) só alcança a RAM livre, o que aqui deu cerca de 7 GB dos 16 GB. O `memtest86+` do Ubuntu não salva log nem volta sozinho para o sistema.

## Estado atual (28/09/2026)

| Parte | Situação |
|---|---|
| Iniciar o MemTest86 pelo GRUB, uma vez só, sem risco de loop | **Funciona** no Mac |
| O MemTest86 gravar o log | **Falha no Mac**: `Unable to open file for writing`. Funciona em VM (OVMF). |
| Coleta, relatório e limpeza no boot seguinte | Funciona. Sem log, o relatório avisa que o resultado ficou só na tela. |
| Abrir o MemTest86 direto pelo firmware (`BootNext`, sem GRUB) | **Em teste** com `diagnostico-bootnext.sh` |

Enquanto o log não funcionar no Mac, **fotografe a tela final** e a tela de resumo (aperte uma tecla depois do PASS/FAIL).

## Como usar

```bash
./baixar.sh                    # baixa o MemTest86 para bin/ e confere o sha256 (sem sudo)
sudo ./preparar.sh             # agenda para o próximo boot e pergunta se reinicia
sudo ./preparar.sh --cancelar  # desfaz sem testar
```

As 4 passadas nos 16 GB levaram **14 h** neste Mac. Deixe na tomada. No fim, o MemTest86 espera uma tecla: a versão Free ignora `mt86.cfg`, então não dá para configurar o fim automático.

## Como funciona

| Arquivo | Papel |
|---|---|
| `baixar.sh` | Baixa `memtest86-usb.zip`, extrai a partição EFI da imagem e copia `BOOTX64.efi` e seus arquivos para `bin/`. Os binários não ficam no git. |
| `preparar.sh` | Copia `bin/` para `/boot/efi/EFI/memtest86/`, cria a marca `grubenv` (`mt86_once=1`), instala o serviço de coleta e o trecho do GRUB, e roda `update-grub`. |
| `06_memtest86_uma_vez` | Vai para `/etc/grub.d/`. O GRUB zera a marca **antes** de iniciar e relê para confirmar. Assim, se o teste travar, o boot seguinte é normal. |
| `coletar.sh` | Vira `memtest86-coletar.service`. Copia `MemTest86-*` da partição EFI, gera `diagnostico.txt` e `Relatório.html` em `~/Área de trabalho/Teste MemTest86 <data>/` e remove tudo. |
| `diagnostico-bootnext.sh` | Teste curto, descrito abaixo. |

A marca fica na partição EFI (FAT) porque o GRUB não grava no btrfs.

## Problema: o MemTest86 não grava no Mac

Na tela de resumo, ao salvar o relatório, aparece `Unable to open file for writing`, e nenhum `MemTest86-*.log` é criado. O que já se sabe:

- A partição EFI (`/dev/sda1`, FAT32, 300 MB) está sã e tem espaço. O próprio GRUB grava nela (`save_env`) no mesmo boot.
- Na VM, com o mesmo `grubx64.efi` e o mesmo MemTest86, o log foi gravado em `EFI/memtest86/`.
- Este Mac respeita as entradas `Boot####` da NVRAM: `efibootmgr` mostra `BootCurrent` = Ubuntu.

Hipóteses:
1. Quando o GRUB faz o `chainloader`, o firmware da Apple entrega ao MemTest86 o disco inteiro em vez da partição. Sem sistema de arquivos, nada é gravado.
2. O driver FAT do firmware da Apple só permite leitura no disco interno.

### Diagnóstico: `diagnostico-bootnext.sh`

Cria uma entrada `Boot####` temporária para `\EFI\memtest86\BOOTX64.efi` e aponta o `BootNext` para ela. O firmware abre o MemTest86 direto, sem GRUB, uma vez só. A `BootOrder` não muda.

```bash
sudo ./diagnostico-bootnext.sh              # prepara e reinicia
# no MemTest86: tecla para ficar no menu, F12 (captura) e anotar a mensagem;
# S para começar, esperar ~2 min e desligar no botão
sudo ./diagnostico-bootnext.sh --verificar  # mostra se gravou, copia e limpa tudo
sudo ./diagnostico-bootnext.sh --cancelar   # só limpa
```

- **Se gravar**, a hipótese 1 se confirma. `preparar.sh` passa a usar `BootNext` no lugar do trecho do GRUB, que fica mais simples.
- **Se não gravar**, fica a hipótese 2. A alternativa é um pendrive com o MemTest86: ligar segurando **Option (⌥)** e escolher "EFI Boot". O log fica no pendrive.
- **Se o Mac ignorar o `BootNext`** e iniciar o Kubuntu, a entrada precisa de outro caminho, por exemplo ir temporariamente para o início da `BootOrder`.

Se o Mac insistir em abrir o MemTest86, segure Option ao ligar e escolha o disco do Kubuntu.

## Resultado do teste de 27–28/09/2026

Tirado das fotos da tela, porque não houve log:

- 4/4 passadas em 14h07, 47/48 testes aprovados, **1 erro**.
- O erro foi só no **Test 13 (Hammer test)**: 1 bit (máscara `0x8`) em `0x2CD770AD8`, perto de 11 GB. Os testes 0–10 não tiveram erro.
- A própria tela avisa "RAM may be vulnerable to high frequency row hammer bit flips". Isso é comum em DDR3 e não indica pente defeituoso para uso normal.
- **A CPU ficou entre 81 e 100 °C (média 95 °C)** durante o teste. Isso pede limpeza e troca de pasta térmica.
- Pentes: Corsair `CMSO8GX3M1C1600C11` e `CMSO8GX3M1B1333C9`, 8 GB cada, ambos a 1333 MT/s 9-9-9-24, dual channel.
- O MemTest86 usou só 1 CPU (`Logical Processors: 1`) neste Mac.
