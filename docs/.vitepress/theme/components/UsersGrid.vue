<script setup lang="ts">
import users from '../../../data/users.json'
</script>

<template>
  <div class="users-grid">
    <a v-for="user in users" :key="user.name" :href="user.url" target="_blank" rel="noopener">
      <img :src="user.logo" :alt="user.name" loading="lazy" />
    </a>
  </div>
</template>
