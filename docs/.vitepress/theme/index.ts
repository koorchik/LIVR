import DefaultTheme from 'vitepress/theme'
import type { Theme } from 'vitepress'
import { h } from 'vue'

import HeroDemo from './components/HeroDemo.vue'
import LivrExample from './components/LivrExample.vue'
import LivrPlayground from './components/LivrPlayground.vue'
import ImplementationCards from './components/ImplementationCards.vue'
import ConformanceTable from './components/ConformanceTable.vue'
import TestCases from './components/TestCases.vue'
import UsersGrid from './components/UsersGrid.vue'
import './custom.css'

export default {
  extends: DefaultTheme,
  Layout() {
    return h(DefaultTheme.Layout, null, {
      'home-hero-image': () => h(HeroDemo)
    })
  },
  enhanceApp({ app }) {
    app.component('LivrExample', LivrExample)
    app.component('LivrPlayground', LivrPlayground)
    app.component('ImplementationCards', ImplementationCards)
    app.component('ConformanceTable', ConformanceTable)
    app.component('TestCases', TestCases)
    app.component('UsersGrid', UsersGrid)
  }
} satisfies Theme
