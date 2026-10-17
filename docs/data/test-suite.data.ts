import fs from 'node:fs'
import path from 'node:path'
import { defineLoader } from 'vitepress'

export type Suite = 'positive' | 'negative' | 'aliases_positive' | 'aliases_negative'

export interface TestCase {
  suite: Suite
  name: string // e.g. "01-required"
  rule: string // e.g. "required"
  rules: string
  input: string
  aliases?: string
  output?: string
  errors?: string
}

declare const data: TestCase[]
export { data }

const SUITES: Suite[] = ['positive', 'negative', 'aliases_positive', 'aliases_negative']

// "15-number_beetween" is a historical typo in the directory name
const ruleFromDir = (dir: string) => dir.replace(/^\d+-/, '').replace('beetween', 'between')

export default defineLoader({
  watch: ['../../test_suite/**/*.json'],
  load(files: string[]): TestCase[] {
    const cases = new Map<string, TestCase>()

    for (const file of files) {
      const caseDir = path.dirname(file)
      const suite = path.basename(path.dirname(caseDir)) as Suite
      if (!SUITES.includes(suite)) continue

      const name = path.basename(caseDir)
      const key = `${suite}/${name}`
      const testCase = cases.get(key) ?? { suite, name, rule: ruleFromDir(name), rules: '', input: '' }
      const field = path.basename(file, '.json') as 'rules' | 'input' | 'aliases' | 'output' | 'errors'
      testCase[field] = fs.readFileSync(file, 'utf8').trim()
      cases.set(key, testCase)
    }

    return [...cases.values()].sort(
      (a, b) => SUITES.indexOf(a.suite) - SUITES.indexOf(b.suite) || a.name.localeCompare(b.name)
    )
  }
})
