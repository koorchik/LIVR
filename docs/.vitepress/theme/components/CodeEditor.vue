<script setup lang="ts">
import { computed } from 'vue'
import { highlight } from '../highlight'

const props = defineProps<{
  label: string
  readonly?: boolean
  placeholder?: string
}>()

const model = defineModel<string>({ required: true })

// <pre> does not render a trailing newline, but the textarea does: add a space so both have the same height
const highlighted = computed(() => highlight(model.value) + (model.value.endsWith('\n') ? ' ' : ''))
</script>

<template>
  <div class="livr-code" :class="{ 'livr-code--readonly': props.readonly }">
    <div class="livr-code__label">{{ props.label }}</div>
    <div class="livr-code__body">
      <pre class="livr-code__layer" aria-hidden="true"><code v-html="highlighted" /></pre>
      <textarea
        v-if="!props.readonly"
        v-model="model"
        class="livr-code__input"
        :aria-label="props.label"
        :placeholder="props.placeholder"
        spellcheck="false"
        autocapitalize="off"
        autocomplete="off"
        autocorrect="off"
      />
    </div>
  </div>
</template>
