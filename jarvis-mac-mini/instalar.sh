#!/bin/bash
# Instala ou atualiza o Jarvis da Central IA no Mac mini.
#
#   bash ~/licao6/jarvis-mac-mini/instalar.sh
#
# Pode correr-se as vezes que for preciso: não apaga nada, não toca no NAS,
# no Docker, no Ollama nem no Syncthing, e nunca substitui habilidades que
# já tenham sido editadas.
set -euo pipefail

# Commit do Jarvis testado com o patch pt-PT. Mudar só depois de testar.
JARVIS_REPO="https://github.com/adewaskar/jarvis.git"
JARVIS_COMMIT="1c4016afdf86f7043efc6882ceffef84ad0d8783"

AQUI="$(cd "$(dirname "$0")" && pwd)"
CENTRAL="$HOME/Central-IA"
LOGS="$HOME/Library/Logs/CentralIA"
AGENT="$HOME/Library/LaunchAgents/pt.centralia.jarvis.plist"
VAULT_JURIDICA="$HOME/Vaults/Cerebro Escritorio Ale"
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

passo() { printf '\n▶ %s\n' "$1"; }
parar() { printf '\n❌ %s\n' "$1"; exit 1; }

[ "$(uname)" = "Darwin" ] || parar "Este instalador é para o Mac mini (macOS)."

passo "1/7 A verificar o Node.js (precisa da versão 20 ou mais recente)"
command -v node >/dev/null || parar "Falta o Node.js. Instale a versão LTS em https://nodejs.org (ficheiro .pkg) e volte a correr este script."
NODE_MAIOR=$(node -p 'process.versions.node.split(".")[0]')
[ "$NODE_MAIOR" -ge 20 ] || parar "O Node.js é a versão $NODE_MAIOR. Instale a LTS em https://nodejs.org e volte a correr."
echo "   Node.js $(node -v) ✅"

passo "2/7 A verificar o Claude Code (é o 'cérebro' do Jarvis)"
if ! command -v claude >/dev/null; then
  parar "Falta o Claude Code. No Terminal corra:  curl -fsSL https://claude.ai/install.sh | bash
   Depois escreva  claude  , inicie sessão com a sua conta e volte a correr este script."
fi
echo "   $(claude --version 2>/dev/null | head -1) ✅  (se ainda não iniciou sessão: escreva 'claude' no Terminal)"

passo "3/7 A descarregar o Jarvis para $CENTRAL/jarvis"
mkdir -p "$CENTRAL/bin" "$LOGS"
if [ ! -d "$CENTRAL/jarvis/.git" ]; then
  git clone --quiet "$JARVIS_REPO" "$CENTRAL/jarvis"
fi
cd "$CENTRAL/jarvis"
ATUAL=$(git rev-parse HEAD)
if [ "$ATUAL" != "$JARVIS_COMMIT" ]; then
  # Alterações locais (o patch pt-PT) são guardadas antes de mudar de versão.
  git stash push --quiet --include-untracked -m "central-ia $(date +%F)" || true
  git fetch --quiet origin "$JARVIS_COMMIT" 2>/dev/null || git fetch --quiet origin
  git -c advice.detachedHead=false checkout --quiet "$JARVIS_COMMIT"
fi
echo "   versão $(git rev-parse --short HEAD) ✅"

passo "4/7 A instalar as dependências (pode demorar alguns minutos)"
npm ci --no-audit --no-fund --loglevel=error
echo "   dependências ✅"

passo "5/7 A pôr o Jarvis em português de Portugal e a ligar as habilidades"
node "$AQUI/patch/aplicar-pt.mjs"

if [ -d "$VAULT_JURIDICA" ]; then
  HAB="$VAULT_JURIDICA/Central IA/Jarvis - Habilidades"
else
  HAB="$CENTRAL/habilidades"
fi
mkdir -p "$HAB"
for f in "$AQUI"/habilidades/*.md; do
  destino="$HAB/$(basename "$f")"
  if [ -e "$destino" ]; then
    cmp -s "$f" "$destino" || echo "   (mantida a versão editada de $(basename "$f"); a nova está em $f)"
  else
    cp "$f" "$destino"
    echo "   + $(basename "$f")"
  fi
done
echo "   habilidades em: $HAB ✅"

passo "6/7 A preparar o arranque automático (launchd)"
cp "$AQUI/bin/"jarvis-*.sh "$CENTRAL/bin/"
chmod +x "$CENTRAL/bin/"jarvis-*.sh
if [ ! -f "$CENTRAL/jarvis.conf" ]; then
  cat > "$CENTRAL/jarvis.conf" <<CONF
# Configuração do Jarvis da Central IA (sem segredos — a chave da ElevenLabs
# fica no Porta-chaves; para a guardar: bash ~/Central-IA/bin/jarvis-voz.sh).
# Depois de mudar este ficheiro: bash ~/Central-IA/bin/jarvis-reiniciar.sh

# Pasta das habilidades (ficheiros .md; editáveis no Obsidian, sem reiniciar).
JARVIS_HABILIDADES_DIR="$HAB"

# Voz da ElevenLabs: tirar o # e pôr o ID da voz escolhida em elevenlabs.io → Voices.
# JARVIS_VOICE_ID=

# 0 = só leitura (recomendado). 1 = pode enviar, apagar, clicar e escrever ficheiros.
JARVIS_ALLOW_WRITES=0
CONF
fi
sed "s#__HOME__#$HOME#g" "$AQUI/launchd/pt.centralia.jarvis.plist" > "$AGENT"
plutil -lint "$AGENT" >/dev/null
launchctl bootout "gui/$(id -u)/pt.centralia.jarvis" 2>/dev/null && sleep 2 || true
launchctl bootstrap "gui/$(id -u)" "$AGENT"
echo "   serviço pt.centralia.jarvis ativo ✅"

passo "7/7 A confirmar"
for _ in $(seq 1 30); do
  curl -s -o /dev/null http://localhost:5173 && break
  sleep 2
done
bash "$CENTRAL/bin/jarvis-saude.sh" || true

cat <<FIM

Pronto. Próximo passo:
  Abra o Chrome do Mac mini em  http://localhost:5173 , carregue em INITIALISE,
  permita o microfone e diga "Olá Jarvis".
FIM
