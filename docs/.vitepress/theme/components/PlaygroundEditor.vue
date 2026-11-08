<script setup lang="ts">
// CodeMirror 6 editor for the playground. It is created in the browser only (onMounted),
// so the server render is an empty box.
import { onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { EditorView, keymap, lineNumbers, highlightActiveLine, drawSelection, Decoration, placeholder as placeholderExt } from '@codemirror/view'
import { EditorState, StateEffect, StateField, type Extension } from '@codemirror/state'
import { defaultKeymap, history, historyKeymap, indentWithTab } from '@codemirror/commands'
import { bracketMatching, indentOnInput, indentUnit, syntaxHighlighting, HighlightStyle } from '@codemirror/language'
import { closeBrackets, closeBracketsKeymap } from '@codemirror/autocomplete'
import { json5Language } from '../json5Language.js'
import { tags } from '@lezer/highlight'

const props = defineProps<{
  label: string
  readonly?: boolean
  placeholder?: string
  errorLine?: number | null
}>()

const model = defineModel<string>({ required: true })

// The colors of the site's code blocks, so light and dark themes follow the site
const highlightStyle = HighlightStyle.define([
  { tag: [tags.propertyName, tags.definition(tags.propertyName)], color: 'var(--livr-t-key)' },
  { tag: [tags.string, tags.special(tags.string)], color: 'var(--livr-t-string)' },
  { tag: [tags.number, tags.bool, tags.null, tags.atom], color: 'var(--livr-t-number)' },
  { tag: [tags.punctuation, tags.bracket, tags.separator], color: 'var(--livr-t-punct)' },
  { tag: tags.comment, color: 'var(--livr-t-comment)', fontStyle: 'italic' }
])

// Marks the line of a syntax error
const setErrorLine = StateEffect.define<number | null>()
const errorLineField = StateField.define({
  create: () => Decoration.none,
  update(value, transaction) {
    let decorations = value.map(transaction.changes)
    for (const effect of transaction.effects) {
      if (!effect.is(setErrorLine)) continue
      const doc = transaction.state.doc
      const line = effect.value
      decorations = line && line <= doc.lines
        ? Decoration.set([Decoration.line({ class: 'cm-error-line' }).range(doc.line(line).from)])
        : Decoration.none
    }
    return decorations
  },
  provide: (field) => EditorView.decorations.from(field)
})

const host = ref<HTMLElement>()
let view: EditorView | undefined

onMounted(() => {
  const extensions: Extension[] = [
    EditorView.lineWrapping,
    EditorView.contentAttributes.of({ 'aria-label': props.label }),
    json5Language,
    syntaxHighlighting(highlightStyle),
    errorLineField
  ]
  if (props.readonly) {
    extensions.push(EditorState.readOnly.of(true), EditorView.editable.of(false))
  } else {
    extensions.push(
      lineNumbers(),
      history(),
      drawSelection(),
      indentOnInput(),
      bracketMatching(),
      closeBrackets(),
      highlightActiveLine(),
      EditorState.tabSize.of(4),
      indentUnit.of('    '),
      keymap.of([...closeBracketsKeymap, ...defaultKeymap, ...historyKeymap, indentWithTab]),
      EditorView.updateListener.of((update) => {
        if (update.docChanged) model.value = update.state.doc.toString()
      })
    )
    if (props.placeholder) extensions.push(placeholderExt(props.placeholder))
  }

  view = new EditorView({ parent: host.value, state: EditorState.create({ doc: model.value, extensions }) })
  view.dispatch({ effects: setErrorLine.of(props.errorLine ?? null) })
  // Line heights change when the web fonts arrive
  document.fonts?.ready.then(() => view?.requestMeasure())
})

onBeforeUnmount(() => view?.destroy())

// Text set from outside (an example, a link, the result) replaces the document
watch(model, (value) => {
  if (view && value !== view.state.doc.toString()) {
    view.dispatch({ changes: { from: 0, to: view.state.doc.length, insert: value } })
  }
})

watch([() => props.errorLine, model], () => {
  view?.dispatch({ effects: setErrorLine.of(props.errorLine ?? null) })
})
</script>

<template>
  <div ref="host" class="pg-editor" />
</template>
