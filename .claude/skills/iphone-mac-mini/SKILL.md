---
name: iphone-mac-mini
description: Ligar o iPhone ao Mac mini do escritório para dar ordens à distância (instalar, correr comandos, ver o ecrã) — por Remote Control do Claude Code, Partilha de ecrã pelo Tailscale ou SSH. Usar quando a pessoa estiver fora do escritório, no iPhone, e pedir para fazer algo no Mac mini ("estou no iPhone", "o Mac mini está no escritório", "liga ao Mac mini", "corre isto no Mac").
---

# iPhone → Mac mini

O Mac mini está no escritório, sempre ligado, com Tailscale (IP 100.86.223.31, nome `mac-mini`). O iPhone tem a app Tailscale. Uma sessão do Claude na nuvem **não** chega ao Mac mini: o trabalho no Mac tem de ser feito por um dos caminhos abaixo.

Primeiro, perguntar só: "Tem a Tailscale ligada no iPhone?" e escolher o caminho.

## Caminho A — Claude no Mac mini, comandado pelo iPhone (preferido)

O Claude Code corre no Mac mini em modo Remote Control; no iPhone, a app Claude → **Code** mostra essa sessão e tudo o que se pede corre no Mac mini.

- Preparação (uma vez, precisa do ecrã do Mac mini — no escritório ou pelo Caminho B):
  `bash ~/licao6/jarvis-mac-mini/bin/claude-remoto.sh`
  (cria o serviço `pt.centralia.claude-remoto`, que arranca sozinho com a sessão.)
  Se `~/licao6` ainda não existir: `git clone -b claude/habilidades-mac-mini-y2hff3 https://github.com/k4f8byghvb-tech/licao6.git ~/licao6`.
- Depois: no iPhone, app Claude → Code → sessão do Mac mini. Daí corre o `instalar.sh` do Jarvis, o `jarvis-saude.sh`, etc.
- Registo: `~/Library/Logs/CentralIA/claude-remoto.log`. Se a sessão não aparecer no iPhone: ver o registo (pode pedir novo início de sessão).

## Caminho B — Ver o ecrã do Mac mini no iPhone (Partilha de ecrã)

1. Tem de estar ligada no Mac mini: Definições do Sistema → Geral → Partilha → **Partilha de ecrã** (com o utilizador TESTER). Se não estiver, só se liga no escritório.
2. No iPhone: uma app de VNC (ex.: "RealVNC Viewer" ou "Screens"), ligar a `100.86.223.31` com a Tailscale ligada; utilizador e palavra-passe do Mac (escritos por ela).
3. Com o ecrã à vista, abrir o Terminal e correr o Caminho A — a partir daí não é preciso o ecrã.

## Caminho C — Terminal por SSH (alternativa)

Definições → Geral → Partilha → **Início de sessão remoto** no Mac mini; no iPhone uma app de SSH (ex.: Termius) para `TESTER@100.86.223.31`. Só pela Tailscale; nunca abrir portas no router.

## Regras

- Um passo de cada vez; esperar "feito" antes do seguinte.
- O Claude nunca escreve palavras-passe; ela escreve.
- Nunca `tailscale funnel` nem portas abertas no router.
- Não tocar no NAS, no Backup, no Syncthing nem no Docker (seguir a skill `central-ia-mac-mini`).
- Confirmar nomes e preços de apps de terceiros na App Store antes de os dar como certos.
