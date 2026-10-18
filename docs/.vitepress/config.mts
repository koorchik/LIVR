import fs from 'node:fs'
import path from 'node:path'
import { createRequire } from 'node:module'
import { defineConfig, type DefaultTheme } from 'vitepress'
import { livrExamplePlugin } from './markdown/livr-example'
import ruleGroups from '../data/rule-groups.json'
import { parseRulePage, plainText } from '../data/rule-page'

// The playground shows which versions of the JavaScript packages run the examples
function packageVersion(name: string) {
  let dir = path.dirname(createRequire(import.meta.url).resolve(name))
  while (!fs.existsSync(path.join(dir, 'package.json'))) dir = path.dirname(dir)
  return JSON.parse(fs.readFileSync(path.join(dir, 'package.json'), 'utf8')).version
}

const SITE_URL = 'https://livr-spec.org'
const DESCRIPTION =
  'LIVR is a declarative, language independent format for data validation rules: one schema, the same rules and the same error codes in JavaScript, Perl, PHP, Python, Go, Erlang and more.'

// The rules section has its own sidebar that lists every rule, grouped as in docs/data/rule-groups.json
const rulesSidebar: DefaultTheme.SidebarItem[] = [
  {
    text: 'Rules',
    items: [
      { text: 'Overview', link: '/validation-rules.html' },
      { text: 'How it works', link: '/validation-rules/how-it-works.html' },
      { text: 'Types coercing', link: '/validation-rules/types-coercing.html' }
    ]
  },
  ...ruleGroups.map((group) => ({
    text: group.title,
    link: group.link,
    items: group.rules.map((rule) => ({
      text: `<span class="sidebar-rule">${rule}</span>`,
      link: `/validation-rules/${rule}.html`
    }))
  })),
  {
    text: 'Reference',
    items: [
      { text: 'Error codes', link: '/validation-rules/error-codes.html' },
      { text: 'Rules aliasing', link: '/rules-aliasing.html' }
    ]
  }
]

export default defineConfig({
  lang: 'en-US',
  title: 'LIVR',
  titleTemplate: ':title · LIVR',
  description: DESCRIPTION,

  // Keep the `.html` URLs that the GitBook site used, so existing links keep working
  cleanUrls: false,
  lastUpdated: true,

  sitemap: { hostname: SITE_URL },

  head: [
    ['link', { rel: 'icon', href: '/favicon.ico', sizes: '32x32' }],
    ['link', { rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' }],
    ['link', { rel: 'apple-touch-icon', href: '/apple-touch-icon.png' }],
    ['meta', { name: 'theme-color', content: '#1a7fc4' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:site_name', content: 'LIVR' }],
    ['meta', { property: 'og:image', content: `${SITE_URL}/og-image.png` }],
    ['meta', { property: 'og:image:width', content: '1200' }],
    ['meta', { property: 'og:image:height', content: '630' }],
    ['meta', { name: 'twitter:card', content: 'summary_large_image' }]
  ],

  transformPageData(pageData, { siteConfig }) {
    // Rule pages are described by their summary paragraph
    if (pageData.frontmatter.group) {
      pageData.frontmatter.pageClass ??= 'rule-page'
      pageData.frontmatter.aside ??= false
      if (!pageData.frontmatter.description) {
        const src = fs.readFileSync(path.join(siteConfig.srcDir, pageData.relativePath), 'utf8')
        pageData.description = pageData.frontmatter.description = plainText(parseRulePage(src).summary)
      }
    }

    const title = pageData.frontmatter.title ?? pageData.title
    const description = pageData.frontmatter.description ?? DESCRIPTION
    const pagePath = pageData.relativePath.replace(/(^|\/)index\.md$/, '$1').replace(/\.md$/, '.html')

    pageData.frontmatter.head ??= []
    pageData.frontmatter.head.push(
      ['meta', { property: 'og:title', content: title ? `${title} · LIVR` : 'LIVR' }],
      ['meta', { property: 'og:description', content: description }],
      ['meta', { property: 'og:url', content: `${SITE_URL}/${pagePath}` }],
      ['link', { rel: 'canonical', href: `${SITE_URL}/${pagePath}` }]
    )
  },

  vite: {
    define: {
      __LIVR_VERSION__: JSON.stringify(packageVersion('livr')),
      __LIVR_EXTRA_RULES_VERSION__: JSON.stringify(packageVersion('livr-extra-rules'))
    }
  },

  markdown: {
    config(md) {
      md.use(livrExamplePlugin)
    }
  },

  themeConfig: {
    logo: { light: '/logo.svg', dark: '/logo-dark.svg', alt: 'LIVR' },
    siteTitle: false,

    nav: [
      { text: 'Introduction', link: '/introduction.html', activeMatch: '^/introduction' },
      { text: 'Rules', link: '/validation-rules.html', activeMatch: '^/(validation-rules|rules-aliasing)' },
      { text: 'Implementations', link: '/introduction/implementations.html' },
      { text: 'Playground', link: '/playground.html' },
      {
        text: 'v2.0',
        items: [
          { text: 'Changelog', link: '/changes.html' },
          { text: 'Test suite', link: '/how-to-contribute/test-suite.html' },
          { text: 'Contributing', link: '/how-to-contribute.html' }
        ]
      }
    ],

    sidebar: {
      '/validation-rules': rulesSidebar,
      '/rules-aliasing': rulesSidebar,
      '/': [
        {
          text: 'Introduction',
          items: [
            { text: 'Overview', link: '/introduction.html' },
            { text: 'Motivation', link: '/introduction/motivation.html' },
            { text: 'Core concepts', link: '/introduction/core-concepts.html' },
            { text: 'Principles', link: '/introduction/principles.html' },
            { text: 'Examples', link: '/introduction/examples.html' }
          ]
        },
        {
          text: 'Specification',
          items: [
            { text: 'Validation rules', link: '/validation-rules.html' },
            { text: 'How it works', link: '/validation-rules/how-it-works.html' },
            { text: 'Types coercing', link: '/validation-rules/types-coercing.html' },
            { text: 'Error codes', link: '/validation-rules/error-codes.html' },
            { text: 'Rules aliasing', link: '/rules-aliasing.html' }
          ]
        },
        {
          text: 'Ecosystem',
          items: [
            { text: 'Implementations', link: '/introduction/implementations.html' },
            { text: 'Extensions', link: '/introduction/extensions.html' },
            { text: 'Users', link: '/users.html' },
            { text: 'Playground', link: '/playground.html' }
          ]
        },
        {
          text: 'Contributing',
          items: [
            { text: 'How to contribute', link: '/how-to-contribute.html' },
            { text: 'Create own implementation', link: '/how-to-contribute/create-own-implementation.html' },
            { text: 'Test suite', link: '/how-to-contribute/test-suite.html' },
            { text: 'Create own plugins', link: '/how-to-contribute/create-own-plugins.html' },
            { text: 'Improve this documentation', link: '/how-to-contribute/improve-livr-documentation.html' }
          ]
        },
        {
          text: 'About',
          items: [
            { text: 'Changelog', link: '/changes.html' },
            { text: 'License', link: '/license-and-copyright.html' }
          ]
        }
      ]
    },

    outline: { level: [2, 3] },

    socialLinks: [{ icon: 'github', link: 'https://github.com/koorchik/LIVR' }],

    editLink: {
      pattern: 'https://github.com/koorchik/LIVR/edit/master/docs/:path',
      text: 'Edit this page on GitHub'
    },

    search: { provider: 'local' },

    footer: {
      message: 'Released under the <a href="/license-and-copyright.html">Artistic License 2.0</a>.'
    }
  }
})
