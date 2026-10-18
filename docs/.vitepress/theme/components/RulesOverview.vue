<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vitepress'
import { data as groups, type RuleInfo } from '../../../data/rules.data'

// <RulesOverview /> shows all rules with a filter, <RulesOverview group="string" /> shows one group
const props = defineProps<{ group?: string }>()
const router = useRouter()

const query = ref('')

const matches = (rule: RuleInfo, q: string) =>
  [rule.name, rule.summary, rule.syntax, ...rule.errors].some((text) => text.toLowerCase().includes(q))

const visibleGroups = computed(() => {
  const q = query.value.trim().toLowerCase()
  return groups
    .filter((g) => !props.group || g.id === props.group)
    .map((g) => ({ ...g, rules: q ? g.rules.filter((r) => matches(r, q)) : g.rules }))
    .filter((g) => g.rules.length)
})
const total = groups.reduce((sum, g) => sum + g.rules.length, 0)
const found = computed(() => visibleGroups.value.reduce((sum, g) => sum + g.rules.length, 0))

// Errors that say something about the rule: FORMAT_ERROR is returned by almost every rule
const tileErrors = (rule: RuleInfo) => {
  const specific = rule.errors.filter((e) => e !== 'FORMAT_ERROR')
  return specific.length ? specific : rule.errors
}

const escapeHtml = (text: string) => text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
const inlineMarkdown = (text: string) =>
  escapeHtml(text)
    .replace(/\[([^\]]+)\]\([^)]+\)/g, '$1')
    .replace(/`([^`]+)`/g, '<code>$1</code>')

function onKeydown(event: KeyboardEvent) {
  if (event.key === 'Enter' && found.value) router.go(visibleGroups.value[0].rules[0].url)
  if (event.key === 'Escape') query.value = ''
}

// Rules used to be sections of the group pages: /validation-rules/string-rules.html#min-length
onMounted(() => {
  if (!props.group) return
  const name = decodeURIComponent(location.hash.slice(1)).replace(/-/g, '_')
  const rule = groups.find((g) => g.id === props.group)?.rules.find((r) => r.name === name)
  if (rule) location.replace(rule.url)
})
</script>

<template>
  <div class="rules-overview">
    <div v-if="!props.group" class="rules-overview__filter">
      <input
        v-model="query"
        type="search"
        placeholder="Filter by name or error code"
        aria-label="Filter rules"
        @keydown="onKeydown"
      />
      <span class="rules-overview__count">{{ query.trim() ? `${found} of ${total}` : `${total} rules` }}</span>
    </div>

    <section v-for="group in visibleGroups" :key="group.id" class="rules-overview__group">
      <div v-if="!props.group" class="rules-overview__group-header">
        <a :href="group.link" class="rules-overview__group-title">{{ group.title }}</a>
        <span class="rules-overview__group-description">{{ group.description }}</span>
      </div>
      <div class="rules-overview__grid">
        <a v-for="rule in group.rules" :key="rule.name" :href="rule.url" class="rule-tile">
          <code class="rule-tile__name">{{ rule.name }}</code>
          <span class="rule-tile__summary" v-html="inlineMarkdown(rule.summary)" />
          <code class="rule-tile__syntax">{{ rule.syntax }}</code>
          <span v-if="rule.errors.length" class="rule-tile__errors">
            <span v-for="error in tileErrors(rule)" :key="error" class="rule-tile__error">{{ error }}</span>
          </span>
          <span v-else class="rule-tile__errors"><span class="rule-tile__error rule-tile__error--none">no errors</span></span>
        </a>
      </div>
    </section>

    <p v-if="!found" class="rules-overview__empty">
      No rules match “{{ query }}”. Projects can add their own rules, see
      <a href="/rules-aliasing.html">Rules aliasing</a> and
      <a href="/how-to-contribute/create-own-plugins.html">Create own plugins</a>.
    </p>
  </div>
</template>
