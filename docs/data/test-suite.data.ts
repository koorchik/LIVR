import fs from 'node:fs'
import path from 'node:path'
import { defineLoader } from 'vitepress'

export type Suite = 'positive' | 'negative' | 'aliases_positive' | 'aliases_negative'

// The directory of the test suite: test_suite (LIVR 2.0) or test_suite_2.5 (rules added in LIVR 2.5)
export type SuiteDir = 'test_suite' | 'test_suite_2.5'

export interface TestCase {
  dir: SuiteDir
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

const SUITE_DIRS: SuiteDir[] = ['test_suite', 'test_suite_2.5']

// Of test_suite_2.5 only the rule cases are loaded: its alias cases and schema_errors are not shown on the site
const SUITES_2_5: Suite[] = ['positive', 'negative']

// "15-number_beetween" is a historical typo in the directory name
const ruleFromDir = (dir: string) => dir.replace(/^\d+-/, '').replace('beetween', 'between')

export default defineLoader({
  watch: ['../../test_suite/**/*.json', '../../test_suite_2.5/**/*.json'],
  load(files: string[]): TestCase[] {
    const cases = new Map<string, TestCase>()
    const skipped = new Set<string>()

    for (const file of files) {
      const caseDir = path.dirname(file)
      const suite = path.basename(path.dirname(caseDir)) as Suite
      const dir = path.basename(path.dirname(path.dirname(caseDir))) as SuiteDir
      if (!SUITES.includes(suite) || !SUITE_DIRS.includes(dir)) continue
      if (dir === 'test_suite_2.5' && !SUITES_2_5.includes(suite)) continue

      const name = path.basename(caseDir)
      // test_suite and test_suite_2.5 may have cases with the same directory name
      const key = `${dir}/${suite}/${name}`
      const field = path.basename(file, '.json')
      // A case with options.json fixes the clock (e.g. iso_date with "today"), which a live example cannot do
      if (field === 'options') skipped.add(key)
      if (!['rules', 'input', 'aliases', 'output', 'errors'].includes(field)) continue
      const testCase = cases.get(key) ?? { dir, suite, name, rule: ruleFromDir(name), rules: '', input: '' }
      testCase[field as 'rules' | 'input' | 'aliases' | 'output' | 'errors'] = fs.readFileSync(file, 'utf8').trim()
      cases.set(key, testCase)
    }

    for (const key of skipped) cases.delete(key)

    return [...cases.values()].sort(
      (a, b) =>
        SUITE_DIRS.indexOf(a.dir) - SUITE_DIRS.indexOf(b.dir) ||
        SUITES.indexOf(a.suite) - SUITES.indexOf(b.suite) ||
        a.name.localeCompare(b.name)
    )
  }
})
