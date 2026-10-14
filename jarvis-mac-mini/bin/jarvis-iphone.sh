#!/bin/bash
# Abre o Jarvis do Mac mini aos aparelhos da sua rede Tailscale (iPhone, PCs),
# com HTTPS — o iPhone só dá o microfone a páginas seguras.
#
# Usa "tailscale serve" (só dentro da sua rede Tailscale), nunca "funnel"
# (que abriria à internet). O processamento continua todo no Mac mini.
set -euo pipefail

TS=/Applications/Tailscale.app/Contents/MacOS/Tailscale
CONF="$HOME/Central-IA/jarvis.conf"
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

[ -x "$TS" ] || { echo "❌ Não encontrei a app Tailscale em /Applications."; exit 1; }
[ -f "$CONF" ] || { echo "❌ Falta $CONF — corra primeiro o instalar.sh."; exit 1; }

HOST=$("$TS" status --json | node -e '
  let s = ""; process.stdin.on("data", (d) => (s += d)).on("end", () => {
    const j = JSON.parse(s)
    if (j.BackendState !== "Running") { console.error("Tailscale desligado"); process.exit(1) }
    process.stdout.write((j.Self.DNSName || "").replace(/\.$/, ""))
  })')
[ -n "$HOST" ] || { echo "❌ O Mac mini não tem nome Tailscale (MagicDNS ligado?)."; exit 1; }
echo "Mac mini na Tailscale: $HOST"

# Não substituir nada que já esteja servido nas portas 443/8443 (ex.: outra app).
ATUAL=$("$TS" serve status 2>/dev/null || true)
for porta in 443 8443; do
  if [ "$porta" = 443 ]; then
    url="https://$HOST( |$)"; esperado="localhost:5173"
  else
    url="https://$HOST:8443( |$)"; esperado="localhost:8787"
  fi
  linha=$(printf '%s\n' "$ATUAL" | grep -E "$url" -A2 | grep -E 'proxy' | head -1 || true)
  if [ -n "$linha" ] && ! printf '%s' "$linha" | grep -q "$esperado"; then
    echo "❌ A porta $porta do Tailscale já serve outra coisa:"; printf '%s\n' "$ATUAL"
    echo "   Nada foi alterado."
    exit 1
  fi
done

echo "A ligar o HTTPS da Tailscale (interface :443, bridge :8443)..."
if ! "$TS" serve --bg --https=443 http://localhost:5173 || ! "$TS" serve --bg --https=8443 http://localhost:8787; then
  cat <<'AJUDA'
❌ O Tailscale recusou. Normalmente falta ligar os certificados HTTPS:
   https://login.tailscale.com/admin/dns → "HTTPS Certificates" → Enable.
   Depois volte a correr este script.
AJUDA
  exit 1
fi

# Autorizar este endereço no bridge e na interface (substitui valores antigos).
TMP=$(mktemp)
grep -v -E '^(JARVIS_ALLOWED_ORIGINS|__VITE_ADDITIONAL_SERVER_ALLOWED_HOSTS)=' "$CONF" \
  | grep -v '^# Acesso pelo iPhone' > "$TMP" || true
{
  echo '# Acesso pelo iPhone/PCs via Tailscale (jarvis-iphone.sh)'
  echo "JARVIS_ALLOWED_ORIGINS=\"https://$HOST\""
  echo "__VITE_ADDITIONAL_SERVER_ALLOWED_HOSTS=\"$HOST\""
} >> "$TMP"
cat "$TMP" > "$CONF"; rm -f "$TMP"

launchctl kickstart -k "gui/$(id -u)/pt.centralia.jarvis"
sleep 8
code=$(curl -s -o /dev/null -w '%{http_code}' "https://$HOST" || true)
[ "$code" = "200" ] && echo "✅ Jarvis disponível em https://$HOST" || echo "⚠️  https://$HOST respondeu HTTP $code — ver: tail -n 30 ~/Library/Logs/CentralIA/jarvis.log"

cat <<FIM

No iPhone (com a app Tailscale ligada):
  1. Abra o Safari em  https://$HOST
  2. Partilhar → "Adicionar ao ecrã principal" (fica como uma app).
  3. Toque em INITIALISE e permita o microfone.

Para desligar o acesso remoto:
  $TS serve --https=443 off ; $TS serve --https=8443 off
FIM
