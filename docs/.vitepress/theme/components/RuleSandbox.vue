<script setup lang="ts">
import { computed, ref } from 'vue'
import { useData } from 'vitepress'
import JSON5 from 'json5'
import LivrExample from './LivrExample.vue'
import { data as testCases, type TestCase } from '../../../data/test-suite.data'

// The live example of a rule page: the example from the frontmatter and the rule's test suite cases
const { frontmatter } = useData()

interface Option {
  id: string
  label: string
  rules: string
  input: string
  testCase?: TestCase
}

const options = computed<Option[]>(() => {
  const rule = frontmatter.value.title
  const example = frontmatter.value.example ?? {}
  const cases = testCases.filter((c) => (c.suite === 'positive' || c.suite === 'negative') && c.rule === rule)
  return [
    { id: 'example', label: 'Example', rules: example.rules ?? '', input: example.input ?? '' },
    ...cases.map((c) => ({
      id: `${c.suite}/${c.name}`,
      label: c.suite === 'positive' ? 'Test suite: valid data' : 'Test suite: invalid data',
      rules: c.rules,
      input: c.input,
      testCase: c
    }))
  ]
})

const selectedId = ref('example')
const selected = computed(() => options.value.find((o) => o.id === selectedId.value) ?? options.value[0])

const expected = computed(() => {
  const c = selected.value.testCase
  if (!c) return undefined
  return c.output !== undefined ? { output: JSON5.parse(c.output) } : { errors: JSON5.parse(c.errors ?? '{}') }
})
</script>

<template>
  <div class="rule-sandbox">
    <div v-if="options.length > 1" class="rule-sandbox__tabs" role="tablist" aria-label="Examples">
      <button
        v-for="option in options"
        :key="option.id"
        type="button"
        role="tab"
        class="rule-sandbox__tab"
        :class="{ 'rule-sandbox__tab--active': option.id === selected.id }"
        :aria-selected="option.id === selected.id"
        @click="selectedId = option.id"
      >
        {{ option.label }}
      </button>
    </div>
    <LivrExample
      :key="selected.id"
      :rules="selected.rules"
      :input="selected.input"
      :expected="expected"
      :title="selected.testCase ? `test_suite/${selected.id}` : undefined"
    />
    <p v-if="selected.testCase" class="rule-sandbox__note">
      This case comes from the <a href="/how-to-contribute/test-suite.html">LIVR test suite</a> that every implementation
      runs.
      <a :href="`https://github.com/koorchik/LIVR/tree/master/test_suite/${selected.id}`" target="_blank" rel="noopener">
        View the files on GitHub</a
      >
    </p>
  </div>
</template>
