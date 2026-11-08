// A small JSON5 mode for CodeMirror: keys, strings, numbers, true/false/null, comments and
// brackets. The JavaScript parser reads a top-level { } as a block of labels, so keys would be
// highlighted inconsistently.
import { StreamLanguage } from '@codemirror/language';

const NUMBER = /^[+-]?(?:0x[0-9a-f]+|(?:\d+\.?\d*|\.\d+)(?:e[+-]?\d+)?|Infinity|NaN)/i;
const IDENTIFIER = /^[A-Za-z_$][\w$]*/;
const BEFORE_COLON = /^\s*:/;

function readString(stream, quote) {
  let escaped = false;
  let ch;
  while ((ch = stream.next()) !== undefined) {
    if (ch === quote && !escaped) return;
    escaped = !escaped && ch === '\\';
  }
}

export const json5Language = StreamLanguage.define({
  name: 'json5',
  startState: () => ({ depth: 0, inComment: false }),
  copyState: state => ({ ...state }),
  token(stream, state) {
    if (state.inComment) {
      if (stream.skipTo('*/')) {
        stream.match('*/');
        state.inComment = false;
      } else {
        stream.skipToEnd();
      }
      return 'comment';
    }
    if (stream.eatSpace()) return null;
    if (stream.match('//')) {
      stream.skipToEnd();
      return 'comment';
    }
    if (stream.match('/*')) {
      state.inComment = true;
      return 'comment';
    }

    const ch = stream.peek();
    if (ch === '"' || ch === '\'') {
      stream.next();
      readString(stream, ch);
      return stream.match(BEFORE_COLON, false) ? 'propertyName' : 'string';
    }
    if (stream.match(NUMBER)) return 'number';
    if (stream.match(IDENTIFIER)) {
      if (stream.match(BEFORE_COLON, false)) return 'propertyName';
      const word = stream.current();
      if (word === 'true' || word === 'false') return 'bool';
      if (word === 'null') return 'null';
      return 'variableName';
    }
    if (ch === '{' || ch === '[') {
      stream.next();
      state.depth++;
      return 'bracket';
    }
    if (ch === '}' || ch === ']') {
      stream.next();
      state.depth = Math.max(0, state.depth - 1);
      return 'bracket';
    }
    stream.next();
    return ch === ',' || ch === ':' ? 'punctuation' : null;
  },
  indent(state, textAfter, context) {
    const closing = /^[}\]]/.test(textAfter) ? 1 : 0;
    return Math.max(0, state.depth - closing) * context.unit;
  },
  languageData: {
    closeBrackets: { brackets: ['(', '[', '{', '\'', '"'] },
    indentOnInput: /^\s*[}\]]$/
  }
});
