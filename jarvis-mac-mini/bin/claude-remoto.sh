#!/bin/bash
# Deixa o Claude Code do Mac mini sempre disponível na app Claude do iPhone
# (Remote Control). Corre uma vez no Mac mini; depois arranca sozinho com a sessão.
#
#   bash ~/licao6/jarvis-mac-mini/bin/claude-remoto.sh
set -euo pipefail
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
PASTA="$HOME/licao6"
AGENT="$HOME/Library/LaunchAgents/pt.centralia.claude-remoto.plist"
mkdir -p "$HOME/Library/Logs/CentralIA"

command -v claude >/dev/null || { echo "❌ Falta o Claude Code: curl -fsSL https://claude.ai/install.sh | bash  e depois  claude  para iniciar sessão."; exit 1; }
[ -d "$PASTA" ] || git clone --quiet -b claude/habilidades-mac-mini-y2hff3 https://github.com/k4f8byghvb-tech/licao6.git "$PASTA"

cat > "$AGENT" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>pt.centralia.claude-remoto</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/script</string><string>-q</string><string>/dev/null</string>
    <string>/bin/bash</string><string>-lc</string>
    <string>export PATH="\$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:\$PATH"; exec claude remote-control</string>
  </array>
  <key>WorkingDirectory</key><string>$PASTA</string>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>ThrottleInterval</key><integer>60</integer>
  <key>StandardOutPath</key><string>$HOME/Library/Logs/CentralIA/claude-remoto.log</string>
  <key>StandardErrorPath</key><string>$HOME/Library/Logs/CentralIA/claude-remoto.log</string>
</dict>
</plist>
PLIST
plutil -lint "$AGENT" >/dev/null
launchctl bootout "gui/$(id -u)/pt.centralia.claude-remoto" 2>/dev/null && sleep 2 || true
launchctl bootstrap "gui/$(id -u)" "$AGENT"
sleep 10
echo "--- registo ---"; tail -n 15 "$HOME/Library/Logs/CentralIA/claude-remoto.log" || true
cat <<FIM

Se o registo mostrar um link ou pedir para iniciar sessão, faça-o (é a sua conta).
Depois, no iPhone: app Claude → Code → a sessão "licao6" do Mac mini aparece na lista.
Parar:  launchctl bootout gui/\$(id -u)/pt.centralia.claude-remoto
FIM
