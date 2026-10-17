<script setup lang="ts">
import { computed, ref } from 'vue'
import CodeEditor from './CodeEditor.vue'
import LivrResult from './LivrResult.vue'
import { matchesExpected, playgroundUrl, runLivr, formatJson, type Expected } from '../livr'
import { highlight } from '../highlight'

const props = defineProps<{
  rules: string
  input?: string
  aliases?: string
  // Set by the markdown plugin: values are URI-encoded so they survive HTML attributes
  encoded?: boolean
  expected?: Expected
  title?: string
}>()

const decode = (value = '') => (props.encoded ? decodeURIComponent(value) : value)

const initial = {
  rules: decode(props.rules),
  input: decode(props.input),
  aliases: decode(props.aliases)
}

const rules = ref(initial.rules)
const input = ref(initial.input)
const aliases = ref(initial.aliases)

const result = computed(() => runLivr(rules.value, input.value, aliases.value))
const isDirty = computed(
  () => rules.value !== initial.rules || input.value !== initial.input || aliases.value !== initial.aliases
)
const passes = computed(() => (props.expected ? matchesExpected(result.value, props.expected) : null))
const expectedCode = computed(() => {
  if (!props.expected) return ''
  return formatJson('output' in props.expected ? props.expected.output : props.expected.errors)
})
const link = computed(() => playgroundUrl({ rules: rules.value, data: input.value, aliases: aliases.value }))

function reset() {
  rules.value = initial.rules
  input.value = initial.input
  aliases.value = initial.aliases
}
</script>

<template>
  <div class="livr-example">
    <div class="livr-example__bar">
      <span class="livr-example__title">
        <template v-if="props.title">{{ props.title }}</template>
        <template v-else>Live example <span class="livr-example__hint">· edit rules or input</span></template>
      </span>
      <span class="livr-example__actions">
        <button v-if="isDirty" type="button" class="livr-link-button" @click="reset">Reset</button>
        <a :href="link" class="livr-link-button">Open in playground</a>
      </span>
    </div>

    <div class="livr-example__grid">
      <div class="livr-example__editors">
        <CodeEditor v-if="aliases || initial.aliases" v-model="aliases" label="aliases" />
        <CodeEditor v-model="rules" label="rules" />
        <CodeEditor v-model="input" label="input" placeholder="{ }" />
      </div>
      <div class="livr-example__results" :class="{ 'livr-example__results--pair': props.expected }">
        <LivrResult :result="result" />
        <div v-if="props.expected" class="livr-expected" :class="passes ? 'livr-expected--ok' : 'livr-expected--fail'">
          <div class="livr-code__label">
            <span class="livr-badge" :class="passes ? 'livr-badge--ok' : 'livr-badge--fail'">
              {{ passes ? 'Matches test suite' : 'Differs from test suite' }}
            </span>
            <span>expected {{ 'output' in props.expected ? 'output' : 'errors' }}</span>
          </div>
          <pre class="livr-code__layer livr-result__code"><code v-html="highlight(expectedCode)" /></pre>
        </div>
      </div>
    </div>
  </div>
</template>
