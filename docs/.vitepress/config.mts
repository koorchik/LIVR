import fs from 'node:fs'
import path from 'node:path'
import { createRequire } from 'node:module'
import { defineConfig, type DefaultTheme } from 'vitepress'
import { livrExamplePlugin } from './markdown/livr-example'

// The playground shows which version of the JavaScript implementation runs the examples
const livrEntry = createRequire(import.meta.url).resolve('livr')
const livrVersion = JSON.parse(fs.readFileSync(path.join(path.dirname(livrEntry), '../package.json'), 'utf8')).version

const SITE_URL = 'https://livr-spec.org'
const DESCRIPTION =
  'LIVR is a declarative, language independent format for data validation rules: one schema, the same rules and the same error codes in JavaScript, Perl, PHP, Python, Go, Erlang and more.'

function ruleGroup(text: string, page: string, rules: string[]): DefaultTheme.SidebarItem {
  return {
    text,
    link: page,
    collapsed: true,
    items: rules.map((rule) => ({
      text: rule,
      link: `${page}#${rule.replace(/_/g, '-')}`
    }))
  }
}

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
    ['link', { rel: 'icon', href: '/favicon.ico', sizes: '48x48' }],
    ['link', { rel: 'icon', type: 'image/png', href: '/favicon-32.png', sizes: '32x32' }],
    ['link', { rel: 'apple-touch-icon', href: '/apple-touch-icon.png' }],
    ['meta', { name: 'theme-color', content: '#218acc' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:site_name', content: 'LIVR' }],
    ['meta', { property: 'og:image', content: `${SITE_URL}/icon-512.png` }],
    ['meta', { name: 'twitter:card', content: 'summary' }]
  ],

  transformPageData(pageData) {
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
    define: { __LIVR_VERSION__: JSON.stringify(livrVersion) }
  },

  markdown: {
    config(md) {
      md.use(livrExamplePlugin)
    }
  },

  themeConfig: {
    logo: { src: '/logo.png', alt: 'LIVR' },
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

    sidebar: [
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
          ruleGroup('Common rules', '/validation-rules/common-rules.html', [
            'required', 'not_empty', 'not_empty_list', 'any_object'
          ]),
          ruleGroup('String rules', '/validation-rules/string-rules.html', [
            'string', 'eq', 'one_of', 'max_length', 'min_length', 'length_between', 'length_equal', 'like'
          ]),
          ruleGroup('Numeric rules', '/validation-rules/numeric-rules.html', [
            'integer', 'positive_integer', 'decimal', 'positive_decimal', 'max_number', 'min_number', 'number_between'
          ]),
          ruleGroup('Special rules', '/validation-rules/special-rules.html', [
            'email', 'url', 'iso_date', 'equal_to_field'
          ]),
          ruleGroup('Metarules', '/validation-rules/metarules.html', [
            'nested_object', 'variable_object', 'list_of', 'list_of_objects', 'list_of_different_objects', 'or'
          ]),
          ruleGroup('Modifiers', '/validation-rules/modifiers.html', [
            'trim', 'to_lc', 'to_uc', 'remove', 'leave_only', 'default'
          ]),
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
    ],

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
