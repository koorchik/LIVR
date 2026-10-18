import { createContentLoader } from 'vitepress'
import groups from './rule-groups.json'
import { parseRulePage } from './rule-page'

export interface RuleInfo {
  name: string
  group: string
  url: string
  summary: string // first paragraph of the page, markdown
  syntax: string
  errors: string[]
}

export interface RuleGroup {
  id: string
  title: string
  link: string
  description: string
  rules: RuleInfo[]
}

declare const data: RuleGroup[]
export { data }

export default createContentLoader('validation-rules/*.md', {
  includeSrc: true,
  transform(pages): RuleGroup[] {
    const rules = new Map<string, RuleInfo>()
    for (const page of pages) {
      const { group, syntax, title } = page.frontmatter
      if (!group) continue
      rules.set(title, { name: title, group, url: page.url, syntax, ...parseRulePage(page.src ?? '') })
    }

    return groups.map((group) => ({
      ...group,
      rules: group.rules.map((name) => {
        const rule = rules.get(name)
        if (!rule) throw new Error(`docs/data/rule-groups.json: no page for the rule "${name}"`)
        return rule
      })
    }))
  }
})
