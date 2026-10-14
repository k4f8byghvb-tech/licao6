#!/bin/bash
# Verifica se o Jarvis está a funcionar no Mac mini.
CENTRAL="$HOME/Central-IA"
HAB="$HOME/Vaults/Cerebro Escritorio Ale/Central IA/Jarvis - Habilidades"
[ -f "$CENTRAL/jarvis.conf" ] && . "$CENTRAL/jarvis.conf"
HAB="${JARVIS_HABILIDADES_DIR:-$HAB}"
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

ok()  { printf '✅ %s\n' "$1"; }
av()  { printf '⚠️  %s\n' "$1"; }
er()  { printf '❌ %s\n' "$1"; }

if launchctl print "gui/$(id -u)/pt.centralia.jarvis" 2>/dev/null | grep -q 'state = running'; then
  ok "serviço pt.centralia.jarvis a correr"
else
  er "serviço parado — correr: launchctl kickstart -k gui/$(id -u)/pt.centralia.jarvis"
fi
code=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:5173 || true)
[ "$code" = "200" ] && ok "interface em http://localhost:5173" || er "interface não responde (HTTP $code)"
if nc -z localhost 8787 2>/dev/null; then ok "bridge na porta 8787"; else er "bridge não responde na porta 8787"; fi
if command -v claude >/dev/null; then ok "Claude Code $(claude --version 2>/dev/null | head -1)"; else er "Claude Code não instalado"; fi
if security find-generic-password -s central-ia-elevenlabs >/dev/null 2>&1; then ok "chave ElevenLabs no Porta-chaves"; else av "sem chave ElevenLabs — usa a voz do Chrome/macOS"; fi
n=$(ls "$HAB"/*.md 2>/dev/null | wc -l | tr -d ' ')
[ "$n" -gt 0 ] && ok "$n habilidades em: $HAB" || er "nenhuma habilidade em: $HAB"
[ "${JARVIS_ALLOW_WRITES:-0}" = "1" ] && av "modo de ESCRITA ligado" || ok "modo só de leitura"
if [ -n "${JARVIS_ALLOWED_ORIGINS:-}" ]; then
  code=$(curl -s -o /dev/null -w '%{http_code}' "$JARVIS_ALLOWED_ORIGINS" || true)
  [ "$code" = "200" ] && ok "iPhone/Tailscale: $JARVIS_ALLOWED_ORIGINS" || er "iPhone/Tailscale: $JARVIS_ALLOWED_ORIGINS não responde (HTTP $code)"
fi
echo "--- últimas linhas do registo ---"
tail -n 8 "$HOME/Library/Logs/CentralIA/jarvis.log" 2>/dev/null || echo "(sem registo)"
