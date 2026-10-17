<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import CodeEditor from './CodeEditor.vue'
import LivrResult from './LivrResult.vue'
import { readPlaygroundHash, runLivr } from '../livr'

declare const __LIVR_VERSION__: string
declare const __LIVR_EXTRA_RULES_VERSION__: string
const livrVersion = __LIVR_VERSION__
const extraRulesVersion = __LIVR_EXTRA_RULES_VERSION__

interface Preset {
  name: string
  rules: string
  data: string
  aliases?: string
}

const PRESETS: Preset[] = [
  {
    name: 'Registration form',
    rules: `{
    name: 'required',
    email: ['required', 'email'],
    gender: { one_of: ['male', 'female'] },
    phone: { max_length: 10 },
    password: ['required', { min_length: 10 }],
    password2: { equal_to_field: 'password' }
}`,
    data: `{
    name: 'John',
    email: 'john@mail.com',
    gender: 'male',
    phone: '+22221212',
    password: 'mypassword1',
    password2: 'mypassword1'
}`
  },
  {
    name: 'Nested object',
    rules: `{
    name: 'required',
    phone: { max_length: 10 },
    address: { nested_object: {
        city: 'required',
        zip: ['required', 'positive_integer']
    }}
}`,
    data: `{
    name: 'Michael',
    phone: '0441234567',
    address: {
        city: 'Kyiv',
        zip: '30552'
    }
}`
  },
  {
    name: 'List of values',
    rules: `{
    order_id: ['required', 'positive_integer'],
    product_ids: { list_of: ['required', 'positive_integer'] }
}`,
    data: `{
    order_id: 10455,
    product_ids: [3455, 3456, 3566]
}`
  },
  {
    name: 'List of objects',
    rules: `{
    order_id: ['required', 'positive_integer'],
    products: ['not_empty_list', { list_of_objects: {
        product_id: ['required', 'positive_integer'],
        quantity: ['required', 'positive_integer']
    }}]
}`,
    data: `{
    order_id: 10345,
    products: [
        { product_id: 3455, quantity: 2 },
        { product_id: 3456, quantity: 0 }
    ]
}`
  },
  {
    name: 'List of different objects',
    rules: `{
    order_id: ['required', 'positive_integer'],
    products: ['required', { list_of_different_objects: [
        'product_type', {
            material: {
                product_type: 'required',
                material_id: ['required', 'positive_integer'],
                quantity: ['required', { min_number: 1 }],
                warehouse_id: 'positive_integer'
            },
            service: {
                product_type: 'required',
                name: ['required', { max_length: 20 }]
            }
        }
    ]}]
}`,
    data: `{
    order_id: 10455,
    products: [{
        product_type: 'material',
        material_id: 345,
        quantity: 5,
        warehouse_id: 24
    }, {
        product_type: 'service',
        name: 'Clean filter'
    }]
}`
  },
  {
    name: 'Modifiers',
    rules: `{
    email: ['trim', 'required', 'email', 'to_lc'],
    country: ['trim', 'to_uc', { length_equal: 2 }],
    newsletter: { default: 'no' }
}`,
    data: `{
    email: '  John.Smith@Example.COM ',
    country: ' ua',
    unknown_field: 'is removed from the output'
}`
  },
  {
    name: 'Rules aliasing',
    aliases: `[{
    name: 'adult_age',
    rules: ['positive_integer', { min_number: 18 }],
    error: 'WRONG_AGE'
}]`,
    rules: `{
    name: 'required',
    age: ['required', 'adult_age']
}`,
    data: `{
    name: 'Viktor',
    age: 16
}`
  },
  {
    name: 'Extra rules',
    rules: `{
    id: ['required', 'uuid'],
    ip: 'ipv4',
    subscribe: ['required', 'boolean'],
    email: [{ required_if: { subscribe: true } }, 'email'],
    tags: ['list_items_unique', { list_length: [1, 3] }],
    birth_date: { iso_date: { max: 'current' } }
}`,
    data: `{
    id: '0b9f4c2e-6a1d-4f3b-9e2a-7c5d8e1f2a3b',
    ip: '192.168.1.300',
    subscribe: true,
    email: '',
    tags: ['livr', 'validation', 'livr'],
    birth_date: '1990-05-17'
}`
  }
]

const rules = ref(PRESETS[0].rules)
const data = ref(PRESETS[0].data)
const aliases = ref('')
const showAliases = ref(false)
const selectedPreset = ref(PRESETS[0].name)
const copied = ref(false)

const result = computed(() => runLivr(rules.value, data.value, aliases.value, { extraRules: true }))

function applyPreset(name: string) {
  const preset = PRESETS.find((p) => p.name === name)
  if (!preset) return
  rules.value = preset.rules
  data.value = preset.data
  aliases.value = preset.aliases ?? ''
  showAliases.value = !!preset.aliases
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
    setTimeout(() => (copied.value = false), 1500)
  } catch {
    // Clipboard is unavailable (e.g. insecure context): the URL in the address bar is up to date anyway
  }
}

function loadFromHash() {
  const state = readPlaygroundHash(location.hash)
  if (!state) return false
  rules.value = state.rules
  data.value = state.data
  aliases.value = state.aliases ?? ''
  showAliases.value = !!aliases.value.trim()
  selectedPreset.value = ''
  return true
}

onMounted(() => {
  loadFromHash()
  window.addEventListener('hashchange', loadFromHash)

  let timer: ReturnType<typeof setTimeout> | undefined
  watch([rules, data, aliases], () => {
    clearTimeout(timer)
    timer = setTimeout(() => history.replaceState(history.state, '', stateHash()), 300)
  })
})
</script>

<template>
  <div class="livr-playground">
    <div class="livr-playground__toolbar">
      <label class="livr-playground__select">
        <span>Example</span>
        <select v-model="selectedPreset" @change="applyPreset(selectedPreset)">
          <option value="" disabled>Custom</option>
          <option v-for="preset in PRESETS" :key="preset.name" :value="preset.name">{{ preset.name }}</option>
        </select>
      </label>
      <label class="livr-playground__toggle">
        <input v-model="showAliases" type="checkbox" />
        <span>Aliases</span>
      </label>
      <span class="livr-playground__spacer" />
      <span class="livr-playground__version">
        livr@{{ livrVersion }} + <a href="/introduction/extensions.html#livr-extra-rules">livr-extra-rules@{{ extraRulesVersion }}</a> (JavaScript)
      </span>
      <button type="button" class="livr-button" @click="copyLink">{{ copied ? 'Copied!' : 'Copy link' }}</button>
    </div>

    <div class="livr-playground__grid">
      <div class="livr-playground__column">
        <CodeEditor v-if="showAliases" v-model="aliases" label="aliases" placeholder="[{ name: 'my_rule', rules: [...], error: 'MY_ERROR' }]" />
        <CodeEditor v-model="rules" label="rules" />
      </div>
      <div class="livr-playground__column">
        <CodeEditor v-model="data" label="input" placeholder="{ }" />
      </div>
      <div class="livr-playground__column">
        <LivrResult :result="result" />
      </div>
    </div>
  </div>
</template>
