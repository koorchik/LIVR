import type MarkdownIt from 'markdown-it'

// Turns a fenced block like
//
//   ```livr
//   // rules
//   { name: 'required' }
//   // input
//   { name: '' }
//   ```
//
// into an interactive <LivrExample> component. On GitHub the same block still
// reads as a plain code sample. Sections: "rules" (required), "input", "aliases".
const SECTION_RE = /^\s*\/\/\s*(rules|input|aliases)\s*$/i

export function parseLivrBlock(content: string) {
  const sections: Record<string, string[]> = {}
  let current = 'rules'

  for (const line of content.split('\n')) {
    const match = line.match(SECTION_RE)
    if (match) {
      current = match[1].toLowerCase()
      sections[current] = []
      continue
    }
    ;(sections[current] ??= []).push(line)
  }

  const text = (name: string) => (sections[name] ?? []).join('\n').trim()

  return { rules: text('rules'), input: text('input'), aliases: text('aliases') }
}

export function livrExamplePlugin(md: MarkdownIt) {
  const defaultFence = md.renderer.rules.fence!

  md.renderer.rules.fence = (tokens, idx, options, env, self) => {
    const token = tokens[idx]
    const [lang, ...flags] = token.info.trim().split(/\s+/)

    if (lang !== 'livr') return defaultFence(tokens, idx, options, env, self)

    const { rules, input, aliases } = parseLivrBlock(token.content)
    const attrs = [
      `rules="${encodeURIComponent(rules)}"`,
      `input="${encodeURIComponent(input)}"`
    ]
    if (aliases) attrs.push(`aliases="${encodeURIComponent(aliases)}"`)
    if (flags.includes('compact')) attrs.push('compact')

    return `<LivrExample encoded ${attrs.join(' ')} />\n`
  }
}
