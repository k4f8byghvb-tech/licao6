---
name: jarvis-mac-mini
description: Gere o Jarvis (assistente de voz) da Central IA no Mac mini — instalar, voz ElevenLabs, ligar ferramentas e evoluir as habilidades (faturação, direito geral, leitura de artigos, produção de texto, agenda). Usar quando pedirem "Jarvis", "assistente de voz", "habilidades do Jarvis", "o Jarvis respondeu mal" ou "põe o Jarvis a correr".
---

# Jarvis no Mac mini

Tudo o que é do Jarvis corre e é guardado **no Mac mini** (servidor sempre ligado da Central IA). Nunca instalar nem correr o Jarvis nos PCs, no telemóvel ou no NAS.

- Código e instruções: `jarvis-mac-mini/` neste repositório (ler o `README.md` antes de agir).
- No Mac mini: `~/Central-IA/jarvis` (programa), `~/Central-IA/jarvis.conf` (configuração), `~/Central-IA/bin/` (scripts), serviço launchd `pt.centralia.jarvis`, registo em `~/Library/Logs/CentralIA/jarvis.log`.
- Habilidades ativas: `~/Vaults/Cerebro Escritorio Ale/Central IA/Jarvis - Habilidades/*.md` (lidas a cada ligação; não é preciso reiniciar).

## Evoluir uma habilidade

1. Perguntar o que o Jarvis fez mal e o que devia ter feito.
2. Acrescentar a regra, curta e concreta, ao ficheiro certo da pasta de habilidades no Mac mini (e ao mesmo ficheiro em `jarvis-mac-mini/habilidades/` deste repositório, para ficar versionado).
3. Recarregar a página do Jarvis e testar com o mesmo pedido.
4. Regras de conteúdo jurídico ou fiscal: dizer a norma e mandar confirmar (Diário da República, Portal das Finanças, contabilista); nunca prazos ou taxas de memória.

## Regras

- Modo só de leitura por defeito (`JARVIS_ALLOW_WRITES=0`); só mudar a pedido explícito, explicando o que passa a poder fazer.
- A chave da ElevenLabs fica no Porta-chaves (`jarvis-voz.sh`); o Claude nunca a escreve.
- Dados de pacientes e clientes: mostrar no ecrã, não falar em voz alta; nunca para pesquisa na web.
- Seguir a skill `central-ia-mac-mini` para tudo o resto do Mac mini (NAS, Syncthing, Docker, Ollama).
