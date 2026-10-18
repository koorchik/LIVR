import DefaultTheme from 'vitepress/theme'
import type { Theme } from 'vitepress'
import { h } from 'vue'

import HeroDemo from './components/HeroDemo.vue'
import LivrExample from './components/LivrExample.vue'
import LivrPlayground from './components/LivrPlayground.vue'
import ImplementationCards from './components/ImplementationCards.vue'
import ConformanceTable from './components/ConformanceTable.vue'
import RuleBreadcrumb from './components/RuleBreadcrumb.vue'
import RuleSandbox from './components/RuleSandbox.vue'
import RulesOverview from './components/RulesOverview.vue'
import TestCases from './components/TestCases.vue'
import UsersGrid from './components/UsersGrid.vue'
import './custom.css'

export default {
  extends: DefaultTheme,
  Layout() {
    return h(DefaultTheme.Layout, null, {
      'home-hero-image': () => h(HeroDemo),
      'doc-before': () => h(RuleBreadcrumb)
    })
  },
  enhanceApp({ app }) {
    app.component('LivrExample', LivrExample)
    app.component('LivrPlayground', LivrPlayground)
    app.component('ImplementationCards', ImplementationCards)
    app.component('ConformanceTable', ConformanceTable)
    app.component('RuleSandbox', RuleSandbox)
    app.component('RulesOverview', RulesOverview)
    app.component('TestCases', TestCases)
    app.component('UsersGrid', UsersGrid)
  }
} satisfies Theme
