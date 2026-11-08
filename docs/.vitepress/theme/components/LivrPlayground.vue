<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import PlaygroundEditor from './PlaygroundEditor.vue'
import { formatJson, readPlaygroundHash, runLivr } from '../livr'
import { PRESETS, type Preset } from '../playground-presets'

declare const __LIVR_VERSION__: string
declare const __LIVR_EXTRA_RULES_VERSION__: string
const livrVersion = __LIVR_VERSION__
const extraRulesVersion = __LIVR_EXTRA_RULES_VERSION__

const GROUPS = ['LIVR 2.0', 'LIVR 2.5', 'Aliases'] as const
const SOURCE_NAMES: Record<string, string> = { rules: 'Rules', aliases: 'Aliases', input: 'Data', validator: 'Rules' }

const rules = ref(PRESETS[0].rules)
const data = ref(PRESETS[0].data)
const aliases = ref('')
const tab = ref<'rules' | 'aliases'>('rules')
const selectedPreset = ref(PRESETS[0].name)
const copied = ref(false)

// Editors and results run in the browser only: livr's messages differ between the server and the
// minified browser build, and CodeMirror needs the DOM
const isMounted = ref(false)

const result = computed(() => runLivr(rules.value, data.value, aliases.value, { extraRules: true }))

function countErrors(errors: unknown): number {
  if (errors === null || errors === undefined) return 0
  if (typeof errors === 'string') return 1
  return Object.values(errors as object).reduce((sum: number, value) => sum + countErrors(value), 0)
}

function countAliases(text: string) {
  return (text.match(/\bname\s*:/g) ?? []).length
}

const view = computed(() => {
  const r = result.value
  if (r.status === 'valid') {
    return { tone: 'valid', title: 'Valid', note: 'Output after the rules ran', code: formatJson(r.output) }
  }
  if (r.status === 'invalid') {
    const count = countErrors(r.errors)
    return { tone: 'invalid', title: count === 1 ? '1 error' : `${count} errors`, note: 'Error codes by field', code: formatJson(r.errors) }
  }
  const where = SOURCE_NAMES[r.source] + (r.line ? `, line ${r.line}` : '')
  const note = r.source === 'validator' ? 'The rules are not valid LIVR' : `Fix the ${where.toLowerCase()}`
  return { tone: 'error', title: 'Can’t run', note, where, message: r.message.replace(/^LIVR: /, '') }
})

const errorIn = computed(() => (result.value.status === 'error' ? result.value.source : null))
const errorLine = computed(() => (result.value.status === 'error' ? result.value.line ?? null : null))
const aliasCount = computed(() => countAliases(aliases.value))

function applyPreset(preset: Preset) {
  rules.value = preset.rules
  data.value = preset.data
  aliases.value = preset.aliases ?? ''
  tab.value = 'rules'
}

function onPresetChange() {
  const preset = PRESETS.find((p) => p.name === selectedPreset.value)
  if (preset) applyPreset(preset)
}

function stateHash() {
  const state: Record<string, string> = { rules: rules.value, data: data.value }
  if (aliases.value.trim()) state.aliases = aliases.value
  return '#' + encodeURIComponent(JSON.stringify(state))
}

async function copyLink() {
  const url = location.href.split('#')[0] + stateHash()
  try {
    await navigator.clipboard.writeText(url)
    copied.value = true
    setTimeout(() => (copied.value = false), 2000)
  } catch {
    // Clipboard is unavailable (e.g. insecure context): the URL in the address bar is up to date anyway
  }
}

function loadFromHash() {
  const state = readPlaygroundHash(location.hash)
  if (!state) return
  rules.value = state.rules
  data.value = state.data
  aliases.value = state.aliases ?? ''
  selectedPreset.value = ''
  tab.value = 'rules'
}

onMounted(() => {
  loadFromHash()
  isMounted.value = true
  window.addEventListener('hashchange', loadFromHash)

  let timer: ReturnType<typeof setTimeout> | undefined
  watch([rules, data, aliases], () => {
    clearTimeout(timer)
    timer = setTimeout(() => history.replaceState(history.state, '', stateHash()), 300)
  })
})
</script>

<template>
  <div class="pg">
    <div class="pg-toolbar">
      <label class="pg-select">
        <span class="visually-hidden">Example</span>
        <select v-model="selectedPreset" @change="onPresetChange">
          <option value="" disabled>Load an example…</option>
          <optgroup v-for="group in GROUPS" :key="group" :label="group">
            <option v-for="preset in PRESETS.filter((p) => p.group === group)" :key="preset.name" :value="preset.name">
              {{ preset.name }}
            </option>
          </optgroup>
        </select>
      </label>
      <button type="button" class="pg-button" aria-live="polite" @click="copyLink">{{ copied ? 'Link copied' : 'Copy link' }}</button>
      <span class="pg-spacer" />
      <span class="pg-version" title="The JavaScript reference implementation runs the rules in your browser">
        <a href="https://js.livr-spec.org">livr {{ livrVersion }}</a>
        <span>+</span>
        <a href="/introduction/extensions.html#livr-extra-rules">livr-extra-rules {{ extraRulesVersion }}</a>
      </span>
    </div>

    <div class="pg-workspace">
      <section class="pg-pane pg-pane--rules" aria-label="Rules and aliases">
        <div class="pg-head" role="tablist">
          <button
            type="button"
            role="tab"
            class="pg-tab"
            :class="{ 'pg-tab--error': errorIn === 'rules' || errorIn === 'validator' }"
            :aria-selected="tab === 'rules'"
            @click="tab = 'rules'"
          >
            Rules
          </button>
          <button
            type="button"
            role="tab"
            class="pg-tab"
            :class="{ 'pg-tab--error': errorIn === 'aliases' }"
            :aria-selected="tab === 'aliases'"
            @click="tab = 'aliases'"
          >
            Aliases<span v-if="aliasCount" class="pg-count">{{ aliasCount }}</span>
          </button>
        </div>
        <div class="pg-body" role="tabpanel">
          <template v-if="isMounted">
            <PlaygroundEditor v-if="tab === 'rules'" key="rules" v-model="rules" label="Rules" :error-line="errorIn === 'rules' ? errorLine : null" />
            <PlaygroundEditor
              v-else
              key="aliases"
              v-model="aliases"
              label="Aliases"
              placeholder="[{ name: 'adult_age', rules: ['positive_integer', { min_number: 18 }], error: 'WRONG_AGE' }]"
              :error-line="errorIn === 'aliases' ? errorLine : null"
            />
          </template>
        </div>
      </section>

      <section class="pg-pane pg-pane--data" aria-label="Data">
        <div class="pg-head" :class="{ 'pg-head--error': errorIn === 'input' }">
          <span class="pg-title">Data</span>
        </div>
        <div class="pg-body">
          <PlaygroundEditor v-if="isMounted" v-model="data" label="Data" :error-line="errorIn === 'input' ? errorLine : null" />
        </div>
      </section>

      <section class="pg-pane pg-result" :class="isMounted ? `pg-result--${view.tone}` : ''" aria-label="Result">
        <div class="pg-head pg-verdict" aria-live="polite">
          <template v-if="isMounted">
            <span class="pg-mark" aria-hidden="true" />
            <span class="pg-verdict-title">{{ view.title }}</span>
            <span class="pg-verdict-note">{{ view.note }}</span>
          </template>
        </div>
        <div class="pg-body">
          <template v-if="isMounted">
            <div v-if="view.tone === 'error'" class="pg-message" role="alert">
              <strong>{{ view.where }}:</strong> {{ view.message }}
            </div>
            <PlaygroundEditor v-else :model-value="view.code ?? ''" label="Result" readonly />
          </template>
        </div>
      </section>
    </div>
  </div>
</template>
