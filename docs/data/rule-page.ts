// Rule pages (docs/validation-rules/<rule>.md) start with a summary paragraph after the title,
// followed by an "Error code(s):" line. The overview and the page descriptions are built from them.
export function parseRulePage(src: string) {
  const body = src.replace(/^---[\s\S]*?\n---\n/, '')
  const paragraphs = body.split(/\n\s*\n/).map((p) => p.trim())
  const titleIndex = paragraphs.findIndex((p) => p.startsWith('# '))
  const summary = paragraphs[titleIndex + 1] ?? ''
  const errorsLine = paragraphs.find((p) => /^Error codes?:/.test(p)) ?? ''
  const errors = [...new Set([...errorsLine.matchAll(/`([A-Z_]+)`/g)].map((m) => m[1]))]
  return { summary, errors }
}

export function plainText(markdown: string) {
  return markdown.replace(/\[([^\]]+)\]\([^)]+\)/g, '$1').replace(/`([^`]+)`/g, '$1')
}
