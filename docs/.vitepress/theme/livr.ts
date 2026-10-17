import LIVR from 'livr'
import JSON5 from 'json5'

export type Source = 'rules' | 'input' | 'aliases' | 'validator'

export type RunResult =
  | { status: 'valid'; output: unknown }
  | { status: 'invalid'; errors: unknown }
  | { status: 'error'; source: Source; message: string }

export interface Expected {
  output?: unknown
  errors?: unknown
}

class SourceError extends Error {
  constructor(public source: Source, message: string) {
    super(message)
  }
}

function parse(text: string, source: Source, fallback: unknown) {
  if (!text.trim()) return fallback
  try {
    return JSON5.parse(text)
  } catch (e) {
    const message = (e as Error).message.replace(/^JSON5: /, '')
    throw new SourceError(source, message)
  }
}

export function runLivr(rulesText: string, inputText: string, aliasesText = ''): RunResult {
  try {
    const rules = parse(rulesText, 'rules', {})
    const input = parse(inputText, 'input', {})
    const aliases = parse(aliasesText, 'aliases', [])

    if (!Array.isArray(aliases)) {
      throw new SourceError('aliases', 'Aliases must be an array of { name, rules, error? } objects')
    }

    let validator
    try {
      validator = new LIVR.Validator(rules)
      for (const alias of aliases) validator.registerAliasedRule(alias)
      const output = validator.validate(input)
      return output ? { status: 'valid', output } : { status: 'invalid', errors: validator.getErrors() }
    } catch (e) {
      throw new SourceError('validator', e instanceof Error ? e.message : String(e))
    }
  } catch (e) {
    if (e instanceof SourceError) return { status: 'error', source: e.source, message: e.message }
    throw e
  }
}

// Order-independent comparison of JSON values (object key order does not matter)
function canonical(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(canonical)
  if (value && typeof value === 'object') {
    return Object.fromEntries(
      Object.keys(value as object)
        .sort()
        .map((key) => [key, canonical((value as Record<string, unknown>)[key])])
    )
  }
  return value
}

export function isSameJson(a: unknown, b: unknown) {
  return JSON.stringify(canonical(a)) === JSON.stringify(canonical(b))
}

export function matchesExpected(result: RunResult, expected: Expected) {
  if ('output' in expected) return result.status === 'valid' && isSameJson(result.output, expected.output)
  if ('errors' in expected) return result.status === 'invalid' && isSameJson(result.errors, expected.errors)
  return false
}

export function formatJson(value: unknown) {
  return JSON.stringify(value, null, 2)
}

// Same hash format as the original LIVR playground: {"rules": "...", "data": "..."}
export interface PlaygroundState {
  rules: string
  data: string
  aliases?: string
}

export function playgroundUrl(state: PlaygroundState) {
  const payload: PlaygroundState = { rules: state.rules, data: state.data }
  if (state.aliases?.trim()) payload.aliases = state.aliases
  return `/playground.html#${encodeURIComponent(JSON.stringify(payload))}`
}

export function readPlaygroundHash(hash: string): PlaygroundState | null {
  if (!hash || hash.length < 2) return null
  try {
    const state = JSON.parse(decodeURIComponent(hash.slice(1)))
    if (typeof state.rules !== 'string') return null
    return { rules: state.rules, data: typeof state.data === 'string' ? state.data : '', aliases: state.aliases ?? '' }
  } catch {
    return null
  }
}
