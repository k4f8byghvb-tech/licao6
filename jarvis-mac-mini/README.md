# Jarvis da Central IA — assistente de voz no Mac mini

Assistente de voz (base: [adewaskar/jarvis](https://github.com/adewaskar/jarvis), licença MIT) adaptado para:

- **correr sempre no Mac mini** — arranca sozinho com a sessão e volta a arrancar se cair (launchd);
- **falar e ouvir em português de Portugal**;
- **habilidades próprias**: faturação da clínica, direito geral, leitura de artigos, produção de texto e agenda/email;
- **só leitura por defeito**: lê, resume e prepara, mas não envia, não apaga e não paga nada.

Os três passos do vídeo (Instalar · A voz · Conectar) estão abaixo, um de cada vez. Avance para o seguinte só depois de o anterior ficar ✅.

---

## Passo 1 · Instalar (no Mac mini)

1. No Mac mini, abra o **Terminal** e confirme que tem o Node.js 20 ou mais recente: `node -v`.
   Se não tiver, instale a versão **LTS** de https://nodejs.org (ficheiro .pkg).
2. Confirme o Claude Code: `claude --version`. Se faltar:
   `curl -fsSL https://claude.ai/install.sh | bash` e depois `claude` para iniciar sessão com a sua conta.
3. Traga este repositório para o Mac mini e corra o instalador:

   ```bash
   git clone https://github.com/k4f8byghvb-tech/licao6.git ~/licao6
   bash ~/licao6/jarvis-mac-mini/instalar.sh
   ```

4. Abra o **Chrome do Mac mini** em http://localhost:5173 → **INITIALISE** → permita o microfone → diga **"Olá Jarvis"**.

O instalador:

| Faz | Não faz |
|---|---|
| Descarrega o Jarvis numa versão fixa e testada para `~/Central-IA/jarvis` | Não toca no NAS, no Time Machine, no Docker, no Ollama nem no Syncthing |
| Aplica o patch pt-PT (`patch/aplicar-pt.mjs`) | Não abre portas no router (a interface só existe em `localhost`) |
| Copia as habilidades para a vault (ver abaixo) | Não substitui habilidades que já tenham sido editadas |
| Cria o serviço `pt.centralia.jarvis` (arranque automático) | Não guarda chaves em ficheiros |

## Passo 2 · A voz (ElevenLabs — opcional)

Sem chave, o Jarvis já fala e ouve em português, com a voz do Chrome/macOS. Para uma voz melhor:

1. Em https://elevenlabs.io crie uma chave de API e escolha uma voz que fale bem português; copie o **Voice ID**.
2. No Terminal do Mac mini: `bash ~/Central-IA/bin/jarvis-voz.sh` e cole a chave quando for pedida (fica no **Porta-chaves** do macOS, não em ficheiros).
3. Abra `~/Central-IA/jarvis.conf`, tire o `#` de `JARVIS_VOICE_ID=` e cole o Voice ID. Depois: `bash ~/Central-IA/bin/jarvis-reiniciar.sh`.

> **Privacidade (RGPD):** com a ElevenLabs ligada, o áudio do que diz e do que o Jarvis responde passa pelos servidores dela; sem ela, o reconhecimento de voz do Chrome envia o áudio à Google. Não dite dados de pacientes ou de clientes em voz alta — peça para os **mostrar no ecrã** (as habilidades já mandam o Jarvis fazer isso). Antes de usar a ElevenLabs com dados profissionais, confirme o contrato de subcontratante (DPA) e a localização dos dados.
> As perguntas em si vão para o Claude da sua conta, como no resto da Central.

## Passo 3 · Conectar (agenda, email, ferramentas)

- **Gmail e Google Calendar**: o Jarvis usa o **Chrome do Mac mini**, que já tem sessão iniciada, através da extensão Claude in Chrome (já instalada). Basta pedir: "Como está o meu dia?".
- **Outras ferramentas (MCP)**: o Jarvis só vê os servidores que estão em `~/.claude.json` no Mac mini (os conectores do claude.ai não aparecem). Para juntar um: `claude mcp add --scope user <nome> ...` e `bash ~/Central-IA/bin/jarvis-reiniciar.sh`.
- **Modo de escrita**: por defeito está só leitura. Mudar `JARVIS_ALLOW_WRITES=1` no `jarvis.conf` deixa o Jarvis enviar emails, clicar, escrever e apagar ficheiros **sem perguntar ao sistema** — só ligar depois de umas semanas a usar em modo leitura, e de preferência só quando precisar.

## Passo 4 · Habilidades — como evoluem

As habilidades são ficheiros `.md` em:

```
~/Vaults/Cerebro Escritorio Ale/Central IA/Jarvis - Habilidades/
```

(ou `~/Central-IA/habilidades/` se a vault não existir). São juntadas às instruções do Jarvis **a cada nova ligação**, por isso:

- **Para evoluir uma habilidade**, edite o ficheiro no Obsidian (no Mac mini ou no PC "msi", que sincroniza pelo Syncthing) e recarregue a página do Jarvis. Não é preciso reinstalar nem reiniciar.
- **Para criar uma nova**, crie outro `.md` na mesma pasta (a ordem é a do nome: `07-…`, `08-…`).
- Quando o Jarvis responder mal, escreva a regra que faltou na habilidade certa ("Quando eu pedir X, faz Y"). É assim que ele melhora com o uso.

| Ficheiro | Para quê |
|---|---|
| `00-identidade.md` | PT-PT, respostas curtas em voz, textos longos no ecrã, não inventar |
| `01-mac-mini-e-privacidade.md` | Tudo no Mac mini; pastas das vaults; RGPD e sigilo; nada se apaga |
| `02-faturacao.md` | Conferir faturas (ATCUD, QR, isenção de IVA dos atos médico-dentários), contas por receber, fecho mensal |
| `03-direito-geral.md` | Resposta + norma; confirmar no Diário da República; quando chamar um advogado |
| `04-leitura-de-artigos.md` | O que muda · se afeta · se há prazo; resumo de uma página no ecrã |
| `05-producao-de-texto.md` | Emails, cartas, avisos, cobranças — sempre no ecrã, nunca enviados sozinho |
| `06-produtividade.md` | "Como está o meu dia?", agenda da semana, emails com prazos |

## Passo 5 · Usar no iPhone (pelo Tailscale)

O iPhone é só o microfone e o ecrã: **todo o processamento continua no Mac mini**. A ligação passa só pela sua rede Tailscale (`tailscale serve`, nunca `funnel`), por isso não fica aberta à internet.

1. No Mac mini, depois do Passo 1: `bash ~/Central-IA/bin/jarvis-iphone.sh`
   - Se disser que falta HTTPS: em https://login.tailscale.com/admin/dns ligue **HTTPS Certificates** e volte a correr o script.
   - Se a porta 443 já servir outra app, o script para sem mudar nada.
2. No iPhone, com a app Tailscale ligada, abra no **Safari** o endereço que o script mostrou (`https://mac-mini.<…>.ts.net`).
3. **Partilhar → Adicionar ao ecrã principal**, depois **INITIALISE** e permita o microfone.

No iPhone recomenda-se a chave da ElevenLabs (Passo 2): o reconhecimento de voz do Safari é menos fiável. Com o ecrã bloqueado o Jarvis deixa de ouvir.

## Manutenção

| Situação | Comando no Terminal do Mac mini |
|---|---|
| Está tudo a funcionar? | `bash ~/Central-IA/bin/jarvis-saude.sh` |
| Reiniciar | `bash ~/Central-IA/bin/jarvis-reiniciar.sh` |
| Ver o registo | `tail -f ~/Library/Logs/CentralIA/jarvis.log` |
| Atualizar (depois de `git -C ~/licao6 pull`) | `bash ~/licao6/jarvis-mac-mini/instalar.sh` |
| Desligar o acesso pelo iPhone | `/Applications/Tailscale.app/Contents/MacOS/Tailscale serve --https=443 off` e o mesmo com `--https=8443` |
| Desligar o arranque automático | `launchctl bootout gui/$(id -u)/pt.centralia.jarvis` |

**Depois de um reinício do Mac mini** o serviço arranca sozinho; falta só abrir http://localhost:5173 no Chrome e carregar em **INITIALISE** (o Chrome exige um clique antes de ligar o microfone).

**Atualizar a versão do Jarvis**: o `instalar.sh` fixa um commit testado (`JARVIS_COMMIT`). Só mudar depois de confirmar que `patch/aplicar-pt.mjs` continua a encaixar — se não encaixar, o patch para sem gravar nada e diz o que mudou.

## O que ainda não está feito

- Testado: o patch pt-PT compila (também com o acesso Tailscale) e as habilidades carregam.
- Não testado aqui: o launchd, o microfone no Mac mini e o acesso pelo iPhone — confirmar com `jarvis-saude.sh` na primeira instalação.
