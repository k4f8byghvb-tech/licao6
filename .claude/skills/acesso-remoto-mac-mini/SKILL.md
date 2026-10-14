---
name: acesso-remoto-mac-mini
description: Aceder ao Mac mini do escritório a partir do iPhone e dos portáteis/PCs (HP, "msi") para dar ordens à distância — instalar, correr comandos, ver o ecrã — por Remote Control do Claude Code, Partilha de ecrã ou SSH, sempre pela Tailscale. Usar quando a pessoa estiver longe do Mac mini e pedir para fazer algo nele ("estou no iPhone", "estou no portátil", "o Mac mini está no escritório", "liga ao Mac mini", "corre isto no Mac").
---

# Acesso remoto ao Mac mini (iPhone e portáteis)

O Mac mini está no escritório, sempre ligado, com Tailscale. Uma sessão do Claude na nuvem **não** chega ao Mac mini; o trabalho lá faz-se por um dos três caminhos abaixo, a partir de qualquer aparelho da rede Tailscale.

| Aparelho | Sistema | IP Tailscale |
|---|---|---|
| **mac-mini** (destino) | macOS, utilizador TESTER | 100.86.223.31 |
| iphone172 | iOS | 100.82.154.13 |
| laptop-fk1ls943 (HP) | Windows | 100.82.208.12 |
| msi | Windows | 100.109.23.51 |

Confirmar em https://login.tailscale.com/admin/machines que o Mac mini e o aparelho de origem estão **Connected**, com a mesma conta. Um aparelho novo: instalar a Tailscale com essa conta antes de tudo.

Primeiro perguntar só: "Em que aparelho está e a Tailscale está ligada nele?" — depois escolher o caminho.

## Caminho A — Claude no Mac mini, comandado à distância (preferido)

O Claude Code corre no Mac mini em modo Remote Control; tudo o que se pede corre no Mac mini.

- **Preparação (uma vez, precisa do ecrã do Mac mini — no escritório ou pelo Caminho B):**
  `bash ~/licao6/jarvis-mac-mini/bin/claude-remoto.sh`
  Cria o serviço `pt.centralia.claude-remoto`, que arranca sozinho com a sessão. Se `~/licao6` não existir:
  `git clone -b claude/habilidades-mac-mini-y2hff3 https://github.com/k4f8byghvb-tech/licao6.git ~/licao6`
- **Usar:**
  - iPhone: app Claude → **Code** → sessão do Mac mini.
  - Portáteis (HP, msi): app Claude para Windows → **Code**, ou https://claude.ai/code no browser → sessão do Mac mini.
- Este caminho não precisa da Tailscale (passa pela conta Claude), mas a mesma conta tem de estar iniciada nos dois lados.
- Se a sessão não aparecer: `tail -n 30 ~/Library/Logs/CentralIA/claude-remoto.log` no Mac mini (pode pedir novo início de sessão).

## Caminho B — Ver e usar o ecrã do Mac mini (Partilha de ecrã)

1. **No Mac mini (uma vez, no escritório):** Definições do Sistema → Geral → Partilha → ligar **Partilha de ecrã**; em (i), permitir o utilizador TESTER. Se um visualizador de outra marca não entrar, ligar também "Os visualizadores VNC podem controlar o ecrã com a palavra-passe" (palavra-passe escrita pela pessoa).
2. **iPhone:** app de VNC (ex.: RealVNC Viewer ou Screens) → `100.86.223.31`.
3. **Portáteis Windows (HP, msi):** RealVNC Viewer (ou TigerVNC) → `100.86.223.31:5900`.
4. Entrar com o utilizador e a palavra-passe do Mac (a pessoa escreve). Com o ecrã à vista, correr a preparação do Caminho A — a partir daí já não é preciso o ecrã.

## Caminho C — Terminal por SSH

1. **No Mac mini (uma vez):** Definições → Geral → Partilha → ligar **Início de sessão remoto**, só para o utilizador TESTER.
2. **Portáteis Windows:** o SSH já vem no Windows — PowerShell → `ssh <utilizador>@100.86.223.31` (o nome curto do utilizador do Mac aparece em Definições → Utilizadores e grupos; confirmar se é `TESTER` ou `tester`).
3. **iPhone:** app de SSH (ex.: Termius) para o mesmo endereço.
4. Útil para: `bash ~/Central-IA/bin/jarvis-saude.sh`, `bash ~/licao6/jarvis-mac-mini/instalar.sh`, ver registos.

## Diagnóstico rápido (do aparelho de origem)

- Não liga a nada → Tailscale desligada num dos lados, ou o Mac mini em suspensão/desligado (confirmar no admin da Tailscale "Last seen").
- Liga por SSH mas não por VNC (ou ao contrário) → o serviço respetivo está desligado na Partilha do Mac mini.
- Windows recusa ligação → Norton/Firewall a bloquear a saída para 100.86.223.31; permitir a app (VNC/SSH) para a rede Tailscale.

## Regras

- Um passo de cada vez; esperar "feito" antes do seguinte.
- O Claude nunca escreve palavras-passe; a pessoa escreve-as.
- Só pela Tailscale: nunca `tailscale funnel` nem portas abertas no router.
- Aparelhos da receção/clínica não recebem acesso ao Mac mini nem à vault jurídica.
- Não tocar no NAS, no Backup, no Syncthing nem no Docker (seguir a skill `central-ia-mac-mini`).
- Confirmar nomes e preços de apps de terceiros (App Store / sites oficiais) antes de os dar como certos.
