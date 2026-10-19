<script setup lang="ts">
import { computed } from 'vue'
import { data } from '../../../data/implementations.data'
import type { Implementation } from '../../../data/implementations.data'

const props = defineProps<{ compact?: boolean }>()

const REGISTRY_LABELS: Record<string, string> = {
  npm: 'npm',
  cpan: 'CPAN',
  packagist: 'Packagist',
  pypi: 'PyPI',
  go: 'Go',
  maven: 'Maven Central',
  rubygems: 'RubyGems',
  hex: 'Hex',
  luarocks: 'LuaRocks',
  raku: 'raku.land',
  cocoapods: 'CocoaPods'
}

const items = computed(() => {
  const list = data.implementations
  return props.compact ? list.filter((item) => item.spec === '2.0' && !item.live.archived) : list
})

const title = (item: Implementation) => (item.name ? `${item.language} · ${item.name}` : item.language)
const initials = (item: Implementation) => item.language.replace(/[^A-Za-z#+]/g, '').slice(0, 2)
const host = (url: string) => new URL(url).host

function activity(item: Implementation) {
  if (!item.live.lastActivity) return ''
  const date = new Date(item.live.lastActivity)
  return date.toLocaleDateString('en-US', { month: 'short', year: 'numeric', timeZone: 'UTC' })
}

function conformance(item: Implementation) {
  const c = item.conformance
  if (!c) return null
  if (c.error) return { tone: 'muted', text: 'Test suite: not run', title: c.error }
  const tone = c.passed === c.total ? 'ok' : c.passed / c.total >= 0.9 ? 'warn' : 'fail'
  const tested = c.version ? `Tested version: ${c.version}` : ''
  return { tone, text: `Test suite: ${c.passed}/${c.total}`, title: tested }
}
</script>

<template>
  <div v-if="props.compact" class="impl-tiles">
    <a v-for="item in items" :key="item.id" class="impl-tile" :href="item.site ?? item.repo" target="_blank" rel="noopener">
      <img v-if="item.logo" :src="item.logo" :alt="`${item.language} logo`" loading="lazy" />
      <span v-else class="impl-fallback">{{ initials(item) }}</span>
      <span class="impl-tile__name">{{ title(item) }}</span>
    </a>
  </div>

  <div v-else class="impl-cards">
    <article v-for="item in items" :key="item.id" class="impl-card" :class="{ 'impl-card--muted': item.live.archived || item.spec !== '2.0' }">
      <header class="impl-card__head">
        <img v-if="item.logo" class="impl-card__logo" :src="item.logo" :alt="`${item.language} logo`" loading="lazy" />
        <span v-else class="impl-card__logo impl-fallback">{{ initials(item) }}</span>
        <div>
          <h3 class="impl-card__title">
            <a :href="item.repo" target="_blank" rel="noopener">{{ title(item) }}</a>
          </h3>
          <div class="impl-card__tags">
            <span class="livr-badge" :class="item.spec === '2.0' ? 'livr-badge--brand' : 'livr-badge--warn'">LIVR {{ item.spec }}</span>
            <span v-if="item.live.archived" class="livr-badge livr-badge--muted">archived</span>
            <span
              v-if="conformance(item)"
              class="livr-badge"
              :class="`livr-badge--${conformance(item)!.tone}`"
              :title="conformance(item)!.title"
            >{{ conformance(item)!.text }}</span>
          </div>
        </div>
      </header>

      <dl class="impl-card__meta">
        <template v-if="item.package">
          <dt>{{ REGISTRY_LABELS[item.package.registry] ?? item.package.registry }}</dt>
          <dd>
            <a :href="item.package.url" target="_blank" rel="noopener"><code>{{ item.package.name }}</code></a>
            <span v-if="item.live.version" class="impl-card__version">{{ item.live.version.startsWith('v') ? '' : 'v' }}{{ item.live.version }}</span>
          </dd>
        </template>
        <template v-if="item.site">
          <dt>Docs</dt>
          <dd><a :href="item.site" target="_blank" rel="noopener">{{ host(item.site) }}</a></dd>
        </template>
        <dt>Maintainer</dt>
        <dd><a :href="item.maintainer.url" target="_blank" rel="noopener">@{{ item.maintainer.name }}</a></dd>
        <template v-if="activity(item)">
          <dt>Last activity</dt>
          <dd>
            {{ activity(item) }}
            <span v-if="item.live.stars" class="impl-card__stars" :title="`${item.live.stars} stars`">★ {{ item.live.stars }}</span>
          </dd>
        </template>
      </dl>

      <p v-if="item.note" class="impl-card__note">{{ item.note }}</p>
    </article>
  </div>
</template>
