<script setup lang="ts">
import { computed } from 'vue'
import { useData } from 'vitepress'
import groups from '../../../data/rule-groups.json'

// Shown above the title of a rule page: Rules › String rules, and a badge for rules of a draft version
const { frontmatter } = useData()
const group = computed(() => groups.find((g) => g.id === frontmatter.value.group))
</script>

<template>
  <nav v-if="group" class="rule-breadcrumb" aria-label="Breadcrumb">
    <a href="/validation-rules.html">Rules</a>
    <span aria-hidden="true">›</span>
    <a :href="group.link">{{ group.title }}</a>
    <span v-if="frontmatter.since" class="livr-badge livr-badge--warn rule-breadcrumb__since">
      LIVR {{ frontmatter.since }} draft
    </span>
  </nav>
</template>
