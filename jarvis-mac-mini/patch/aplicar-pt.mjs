#!/usr/bin/env node
/**
 * Adapta o J.A.R.V.I.S (github.com/adewaskar/jarvis) à Central IA do Mac mini:
 *
 *   1. Habilidades: o bridge passa a juntar ao prompt de sistema todos os
 *      ficheiros .md da pasta JARVIS_HABILIDADES_DIR. São lidos a cada ligação,
 *      por isso editar uma habilidade não obriga a reiniciar nada.
 *   2. Voz em português de Portugal: reconhecimento pt-PT no Chrome, Scribe da
 *      ElevenLabs com língua "por", voz local pt-PT (Joana) como alternativa.
 *   3. Palavra de ativação e palavras de interrupção em português.
 *   4. Frases curtas de espera ("A pesquisar.") em português.
 *
 * Uso (na pasta do jarvis):  node /caminho/aplicar-pt.mjs
 *
 * Cada substituição procura um texto exato do commit fixado em instalar.sh. Se
 * o texto não existir (o projeto mudou), o script para sem gravar nada, em vez
 * de deixar o Jarvis meio traduzido. Correr duas vezes não faz mal: o que já
 * está aplicado é reconhecido e saltado.
 */

import { readFileSync, writeFileSync } from 'node:fs'
import process from 'node:process'

const MARCA = 'CENTRAL-IA-PT'

/** [ficheiro, texto original, texto novo] */
const SUBSTITUICOES = [
  // 1. Habilidades no prompt de sistema
  [
    'bridge/server.mjs',
    'const SYSTEM_PROMPT = `You are JARVIS.',
    `// ${MARCA}: habilidades da Central IA, lidas a cada ligação.
import { readdirSync as lerPasta } from 'node:fs'
function carregarHabilidades() {
  const pasta = process.env.JARVIS_HABILIDADES_DIR
  if (!pasta) return ''
  try {
    const textos = lerPasta(pasta)
      .filter((f) => f.endsWith('.md'))
      .sort()
      .map((f) => readFileSync(join(pasta, f), 'utf8').trim())
    if (!textos.length) return ''
    console.log(\`[jarvis] \${textos.length} habilidades carregadas de \${pasta}\`)
    return '\\n\\n# HABILIDADES DA CENTRAL IA (prevalecem sobre o que está acima)\\n\\n' +
      textos.join('\\n\\n---\\n\\n')
  } catch (err) {
    console.warn(\`[jarvis] habilidades não carregadas: \${err.message}\`)
    return ''
  }
}

const SYSTEM_PROMPT = \`You are JARVIS.`,
  ],
  [
    'bridge/server.mjs',
    '      systemPrompt: SYSTEM_PROMPT,',
    `      systemPrompt: SYSTEM_PROMPT + carregarHabilidades(), // ${MARCA}`,
  ],
  // 2. Transcrição ElevenLabs em português
  [
    'bridge/server.mjs',
    "      form.append('model_id', 'scribe_v1')",
    `      form.append('model_id', 'scribe_v1')
      form.append('language_code', process.env.JARVIS_STT_LANG ?? 'por') // ${MARCA}`,
  ],
  // 2. Reconhecimento de voz do Chrome em pt-PT
  ['src/lib/voice.ts', "    rec.lang = 'en-GB'", `    rec.lang = 'pt-PT' // ${MARCA}`],
  // 3. Ativação: "Olá Jarvis", "Ei Jarvis"; o Chrome em pt-PT escreve o nome de várias formas
  [
    'src/lib/voice.ts',
    "/\\b(?:hey|hi|ok|okay|yo)?\\s*(?:jarvis|jarvys|jervis|jarvis's|travis|jarviss|java's|jarv)\\b(?!'s)/i",
    `/(?:^|[^\\p{L}])(?:hey|hi|ok|okay|olá|ola|ei|ó|oh)?\\s*(?:jarvis|jarvys|jervis|járvis|jarvas|jarbas|jarviss|jarv)(?![\\p{L}'])/iu // ${MARCA}`,
  ],
  [
    'src/lib/voice.ts',
    '/\\b(stop|wait|jarvis|cancel|enough|quiet|hold on|shut up|never ?mind|forget it|no)\\b/i',
    `/(?:^|[^\\p{L}])(stop|wait|jarvis|cancel|enough|quiet|pára|espera|chega|cancela|silêncio|esquece)(?!\\p{L})/iu // ${MARCA}`,
  ],
  // 2. Voz local (sem ElevenLabs): preferir pt-PT
  [
    'src/lib/tts.ts',
    "  if (n.startsWith('daniel')) s += 100",
    `  // ${MARCA}: vozes de português de Portugal primeiro (macOS: Joana, Catarina).
  if (/^pt[-_]pt/i.test(v.lang)) s += 120
  else if (/^pt/i.test(v.lang)) s += 45
  if (/\\b(joana|catarina)\\b/.test(n)) s += 20
  if (n.startsWith('daniel')) s += 100`,
  ],
  ['src/lib/tts.ts', '    .filter((v) => /^en/i.test(v.lang))', `    .filter((v) => /^pt/i.test(v.lang)) // ${MARCA}`],
  [
    'src/lib/tts.ts',
    'all.find((v) => /^en/i.test(v.lang)) ?? null',
    `all.find((v) => /^pt/i.test(v.lang)) ?? null // ${MARCA}`,
  ],
  ['src/lib/tts.ts', "u.lang = voice?.lang ?? 'en-GB'", `u.lang = voice?.lang ?? 'pt-PT' // ${MARCA}`],
  // 5. iPhone pelo Tailscale: aberta em https://mac-mini.<tailnet>.ts.net, a
  //    interface fala com o bridge na porta 8443 do mesmo nome (tailscale serve).
  //    No Mac mini (http://localhost:5173) continua a usar ws://localhost:8787.
  [
    'src/config.ts',
    "export const BRIDGE_WS_URL = str(import.meta.env.VITE_BRIDGE_URL) ?? 'ws://localhost:8787'",
    `export const BRIDGE_WS_URL =
  str(import.meta.env.VITE_BRIDGE_URL) ??
  (typeof location !== 'undefined' && location.protocol === 'https:'
    ? \`wss://\${location.hostname}:8443\`
    : 'ws://localhost:8787') // ${MARCA}`,
  ],
]

/** 5. CSP: imagens, som e páginas servidas pelo bridge também via Tailscale. */
const CSP_DE = 'http://localhost:8787 http://127.0.0.1:8787;'
const CSP_PARA = 'http://localhost:8787 http://127.0.0.1:8787 https://*.ts.net:8443;'

/** 4. Frases de espera: inglês -> português de Portugal, sem "sir". */
const FRASES = {
  'Working on it, sir.': 'Estou a tratar disso.',
  'Compiling.': 'A compilar.',
  'Retrieving.': 'A obter.',
  'Accessing the archive.': 'A consultar o arquivo.',
  'Cross-referencing.': 'A cruzar a informação.',
  'Running the query now.': 'A fazer a consulta.',
  'Searching.': 'A pesquisar.',
  'Under way.': 'Em curso.',
  'As you wish, sir.': 'Com certeza.',
  'Very good, sir.': 'Muito bem.',
  'Certainly.': 'Certamente.',
  'Understood.': 'Entendido.',
  'Consider it done.': 'Fica feito.',
  'Directly, sir.': 'De imediato.',
  'Yes, sir?': 'Sim?',
  'Sir?': 'Diga.',
  'At your service, sir.': 'Ao seu dispor.',
  'Standing by.': 'Estou a ouvir.',
  'Awake, sir.': 'Pronto.',
  'Assembling the footage.': 'A montar o vídeo.',
  'Rendering the sequence.': 'A gerar a sequência.',
  'Rendering.': 'A gerar.',
  'Composing it now.': 'A compor.',
  'Opening the browser.': 'A abrir o navegador.',
  'Navigating.': 'A navegar.',
  'Reaching the device.': 'A ligar ao aparelho.',
  'Connecting to your phone.': 'A ligar ao telemóvel.',
  'Checking your mail.': 'A ver o email.',
  'Reading the inbox.': 'A ler a caixa de entrada.',
  'Checking your calendar.': 'A ver a agenda.',
  'Consulting the diary.': 'A consultar a agenda.',
  'Synthesising.': 'A sintetizar.',
  'Queuing it up.': 'A pôr na fila.',
  'Putting it on.': 'A pôr a tocar.',
  'Adjusting it now.': 'A ajustar.',
  'Seeing to it, sir.': 'A tratar disso.',
  'Checking the repository.': 'A ver o repositório.',
  'Consulting the tracker.': 'A consultar as tarefas.',
  'Running the query.': 'A fazer a consulta.',
  'Pulling the figures.': 'A buscar os números.',
  'Consulting the record.': 'A consultar o registo.',
}

const ficheiros = new Map()
const ler = (f) => {
  if (!ficheiros.has(f)) ficheiros.set(f, readFileSync(f, 'utf8'))
  return ficheiros.get(f)
}

const falhas = []
let aplicadas = 0
let saltadas = 0

for (const [f, de, para] of SUBSTITUICOES) {
  const txt = ler(f)
  if (txt.includes(para)) {
    saltadas++
  } else if (txt.split(de).length === 2) {
    ficheiros.set(f, txt.replace(de, () => para))
    aplicadas++
  } else {
    falhas.push(`${f}: não encontrei (ou encontrei mais de uma vez) -> ${de.slice(0, 70)}`)
  }
}

let fill = ler('src/lib/fillers.ts')
for (const [en, pt] of Object.entries(FRASES)) {
  const de = `'${en}'`
  const para = `'${pt.replace(/'/g, "\\'")}'`
  if (fill.includes(de)) {
    fill = fill.split(de).join(para)
    aplicadas++
  } else if (fill.includes(para)) {
    saltadas++
  } else {
    falhas.push(`src/lib/fillers.ts: frase em falta -> ${en}`)
  }
}
ficheiros.set('src/lib/fillers.ts', fill)

const html = ler('index.html')
if (html.includes(CSP_PARA)) {
  saltadas++
} else if (html.includes(CSP_DE)) {
  ficheiros.set('index.html', html.split(CSP_DE).join(CSP_PARA))
  aplicadas++
} else {
  falhas.push('index.html: política CSP não encontrada')
}

if (falhas.length) {
  console.error('O Jarvis mudou e o patch já não encaixa. Nada foi gravado.')
  for (const x of falhas) console.error('  - ' + x)
  process.exit(1)
}

for (const [f, txt] of ficheiros) writeFileSync(f, txt)
console.log(`Patch pt-PT: ${aplicadas} alterações aplicadas, ${saltadas} já estavam feitas.`)
