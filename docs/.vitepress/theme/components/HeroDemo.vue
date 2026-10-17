<script setup lang="ts">
import { computed } from 'vue'
import { formatJson, runLivr } from '../livr'
import { highlight } from '../highlight'

const rules = `{
  name:    'required',
  email:   ['required', 'email'],
  age:     ['positive_integer', { min_number: 18 }],
  address: { nested_object: {
    city: 'required',
    zip:  'positive_integer'
  }}
}`

const input = `{
  email: 'john@', age: 16, role: 'admin',
  address: { city: 'Kyiv', zip: 'O1001' }
}`

const result = computed(() => {
  const r = runLivr(rules, input)
  return r.status === 'invalid' ? formatJson(r.errors) : ''
})
</script>

<template>
  <div class="hero-demo" aria-label="Example: LIVR rules, input data and the resulting error codes">
    <div class="hero-demo__window">
      <div class="hero-demo__dots" aria-hidden="true"><span /><span /><span /></div>
      <section>
        <h4>rules</h4>
        <pre><code v-html="highlight(rules)" /></pre>
      </section>
      <section>
        <h4>input</h4>
        <pre><code v-html="highlight(input)" /></pre>
      </section>
      <section class="hero-demo__errors">
        <h4>errors <span class="livr-badge livr-badge--fail">Invalid</span></h4>
        <pre><code v-html="highlight(result)" /></pre>
      </section>
    </div>
  </div>
</template>
