<script setup lang="ts">
import { computed } from 'vue'
import { useData } from 'vitepress'
import groups from '../../../data/rule-groups.json'

// Shown above the title of a rule page: Rules › String rules
const { frontmatter } = useData()
const group = computed(() => groups.find((g) => g.id === frontmatter.value.group))
</script>

<template>
  <nav v-if="group" class="rule-breadcrumb" aria-label="Breadcrumb">
    <a href="/validation-rules.html">Rules</a>
    <span aria-hidden="true">›</span>
    <a :href="group.link">{{ group.title }}</a>
  </nav>
</template>
