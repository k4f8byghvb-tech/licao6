#!/bin/bash
# Guarda (ou troca) a chave da ElevenLabs no Porta-chaves do macOS.
# A chave é escrita por si quando o macOS a pedir — não fica em nenhum ficheiro.
set -euo pipefail
echo "Cole a chave da ElevenLabs quando for pedida (não aparece no ecrã) e carregue em Enter."
security add-generic-password -U -a "$USER" -s central-ia-elevenlabs -w
echo "Chave guardada. A reiniciar o Jarvis..."
launchctl kickstart -k "gui/$(id -u)/pt.centralia.jarvis" && echo "Pronto."
