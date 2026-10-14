#!/bin/bash
# Arranca o Jarvis (bridge :8787 + interface :5173) no Mac mini.
# Chamado pelo launchd (pt.centralia.jarvis); não precisa de ser corrido à mão.
set -euo pipefail

CENTRAL="$HOME/Central-IA"
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Configuração sem segredos (voz, modo de escrita, pasta das habilidades).
if [ -f "$CENTRAL/jarvis.conf" ]; then
  set -a
  # shellcheck source=/dev/null
  . "$CENTRAL/jarvis.conf"
  set +a
fi

# Chave da ElevenLabs: só no Porta-chaves do macOS, nunca em ficheiros.
if KEY=$(security find-generic-password -s central-ia-elevenlabs -w 2>/dev/null); then
  export ELEVENLABS_API_KEY="$KEY"
fi
unset KEY

export JARVIS_HABILIDADES_DIR="${JARVIS_HABILIDADES_DIR:-$HOME/Vaults/Cerebro Escritorio Ale/Central IA/Jarvis - Habilidades}"
export TZ="${TZ:-Europe/Lisbon}"

echo "[central-ia] $(date '+%F %T') a arrancar o Jarvis (escrita=${JARVIS_ALLOW_WRITES:-0}, voz ElevenLabs=$([ -n "${ELEVENLABS_API_KEY:-}" ] && echo sim || echo não))"
cd "$CENTRAL/jarvis"
if [ "${JARVIS_ALLOW_WRITES:-0}" = "1" ]; then
  exec node scripts/start.mjs --writes
fi
exec node scripts/start.mjs
