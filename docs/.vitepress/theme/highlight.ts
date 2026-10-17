// Tiny highlighter for JSON / JS object literals, used by the live editors.
// Shiki runs only at build time, so editable blocks need something that works in the browser.
const TOKEN_RE =
  /(\/\/[^\n]*|\/\*[\s\S]*?(?:\*\/|$))|("(?:\\.|[^"\\\n])*"?|'(?:\\.|[^'\\\n])*'?)|(-?\b\d+(?:\.\d+)?(?:[eE][+-]?\d+)?\b)|\b(true|false|null|undefined)\b|([A-Za-z_$][\w$]*)(?=\s*:)|([{}[\],:])/g

const escapeHtml = (text: string) =>
  text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')

export function highlight(code: string) {
  let html = ''
  let last = 0

  for (const match of code.matchAll(TOKEN_RE)) {
    const [token, comment, string, number, keyword, key] = match
    const index = match.index!
    html += escapeHtml(code.slice(last, index))
    last = index + token.length

    let cls = 'p'
    if (comment) cls = 'c'
    else if (string) cls = /^\s*:/.test(code.slice(last)) ? 'k' : 's'
    else if (number) cls = 'n'
    else if (keyword) cls = 'b'
    else if (key) cls = 'k'

    html += `<span class="t-${cls}">${escapeHtml(token)}</span>`
  }

  return html + escapeHtml(code.slice(last))
}
