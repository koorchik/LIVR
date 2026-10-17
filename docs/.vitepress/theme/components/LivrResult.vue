<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { formatJson, type RunResult } from '../livr'
import { highlight } from '../highlight'

const props = defineProps<{ result: RunResult }>()

// Exception messages differ between the server build and the minified browser build,
// so they are rendered only in the browser to keep hydration consistent
const isMounted = ref(false)
onMounted(() => (isMounted.value = true))

const view = computed(() => {
  const result = props.result
  if (result.status === 'valid') {
    return { tone: 'ok', badge: 'Valid', label: 'output', code: formatJson(result.output) }
  }
  if (result.status === 'invalid') {
    return { tone: 'fail', badge: 'Invalid', label: 'errors', code: formatJson(result.errors) }
  }
  if (result.source === 'validator') {
    return { tone: 'warn', badge: 'Validator error', label: 'message', code: isMounted.value ? result.message : '' }
  }
  return { tone: 'warn', badge: `Cannot parse ${result.source}`, label: 'message', code: result.message }
})
</script>

<template>
  <div class="livr-result" :class="`livr-result--${view.tone}`" aria-live="polite">
    <div class="livr-code__label">
      <span class="livr-badge" :class="`livr-badge--${view.tone}`">{{ view.badge }}</span>
      <span>{{ view.label }}</span>
    </div>
    <template v-if="view.tone === 'warn'"><pre v-if="view.code" class="livr-result__message">{{ view.code }}</pre></template>
    <pre v-else class="livr-code__layer livr-result__code"><code v-html="highlight(view.code)" /></pre>
  </div>
</template>
