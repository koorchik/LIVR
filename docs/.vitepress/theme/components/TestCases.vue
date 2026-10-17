<script setup lang="ts">
import { computed } from 'vue'
import JSON5 from 'json5'
import LivrExample from './LivrExample.vue'
import { data } from '../../../data/test-suite.data'

// <TestCases rule="required" /> shows the test suite cases for one rule,
// <TestCases suite="aliases" /> shows all alias cases.
const props = defineProps<{ rule?: string; suite?: 'aliases' }>()

const cases = computed(() =>
  data.filter((c) =>
    props.suite === 'aliases' ? c.suite.startsWith('aliases_') : !c.suite.startsWith('aliases_') && c.rule === props.rule
  )
)

const expected = (c: (typeof data)[number]) =>
  c.output !== undefined ? { output: JSON5.parse(c.output) } : { errors: JSON5.parse(c.errors ?? '{}') }

const repoUrl = (c: (typeof data)[number]) => `https://github.com/koorchik/LIVR/tree/master/test_suite/${c.suite}/${c.name}`
</script>

<template>
  <details v-if="cases.length" class="livr-tests">
    <summary>
      Test suite cases
      <span class="livr-tests__count">{{ cases.length }}</span>
    </summary>
    <p class="livr-tests__intro">
      These cases come straight from the
      <a href="/how-to-contribute/test-suite.html">LIVR test suite</a> that every implementation runs.
      Edit them to see how the rule behaves.
    </p>
    <div v-for="c in cases" :key="`${c.suite}/${c.name}`" class="livr-tests__case">
      <LivrExample
        :title="`${c.suite}/${c.name}`"
        :rules="c.rules"
        :input="c.input"
        :aliases="c.aliases"
        :expected="expected(c)"
      />
      <a class="livr-tests__source" :href="repoUrl(c)" target="_blank" rel="noopener">View files on GitHub</a>
    </div>
  </details>
</template>
