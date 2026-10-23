import fs from 'node:fs'
import path from 'node:path'
import { defineLoader } from 'vitepress'

// Static facts live in implementations.json (edit that file to add an implementation).
// At build time we enrich them with live data: latest package version, repository
// activity, and the result of running the LIVR test suite (conformance.json, produced in CI).
// Set LIVR_DOCS_OFFLINE=1 to skip network requests.

export interface Implementation {
  id: string
  language: string
  name?: string
  logo?: string
  repo: string
  site?: string // documentation site of the implementation, if it has one
  package?: { registry: string; name: string; url: string }
  spec: string
  maintainer: { name: string; url: string }
  note?: string
  live: {
    version?: string
    lastActivity?: string
    stars?: number
    archived?: boolean
  }
  conformance?: Conformance
}

export interface Conformance {
  version?: string
  total: number
  passed: number
  failures: { case: string; message?: string; note?: string }[]
  notes?: string[]
  error?: string | null
}

export interface ImplementationsData {
  implementations: Implementation[]
  conformanceGeneratedAt?: string
  testSuiteTotal?: number
}

declare const data: ImplementationsData
export { data }

const TIMEOUT_MS = 8000
const CACHE_TTL_MS = 6 * 60 * 60 * 1000

async function getJson(url: string): Promise<any> {
  const headers: Record<string, string> = { accept: 'application/json', 'user-agent': 'livr-spec.org docs build' }
  if (url.startsWith('https://api.github.com/') && process.env.GITHUB_TOKEN) {
    headers.authorization = `Bearer ${process.env.GITHUB_TOKEN}`
  }
  const response = await fetch(url, { headers, signal: AbortSignal.timeout(TIMEOUT_MS) })
  if (!response.ok) throw new Error(`${response.status} ${url}`)
  return response.json()
}

const registryVersion: Record<string, (name: string) => Promise<string | undefined>> = {
  npm: async (name) => (await getJson(`https://registry.npmjs.org/${name}/latest`)).version,
  cpan: async (name) => (await getJson(`https://fastapi.metacpan.org/v1/release/${name.replace(/::/g, '-')}`)).version,
  pypi: async (name) => (await getJson(`https://pypi.org/pypi/${name}/json`)).info.version,
  rubygems: async (name) => (await getJson(`https://rubygems.org/api/v1/gems/${name}.json`)).version,
  hex: async (name) => (await getJson(`https://hex.pm/api/packages/${name}`)).latest_stable_version,
  pub: async (name) => (await getJson(`https://pub.dev/api/packages/${name}`)).latest.version,
  go: async (name) =>
    (await getJson(`https://proxy.golang.org/${name.toLowerCase()}/@latest`)).Version.replace(/^v/, '').replace('+incompatible', ''),
  maven: async (name) => {
    const [group, artifact] = name.split(':')
    const url = `https://repo1.maven.org/maven2/${group.replace(/\./g, '/')}/${artifact}/maven-metadata.xml`
    const response = await fetch(url, { signal: AbortSignal.timeout(TIMEOUT_MS) })
    if (!response.ok) throw new Error(`${response.status} ${url}`)
    return (await response.text()).match(/<release>([^<]+)<\/release>/)?.[1]
  },
  cocoapods: async (name) => {
    const versions = (await getJson(`https://trunk.cocoapods.org/api/v1/pods/${name}`)).versions
    return versions.at(-1)?.name
  },
  packagist: async (name) => {
    const versions = (await getJson(`https://repo.packagist.org/p2/${name}.json`)).packages[name]
    return versions?.[0]?.version
  }
}

async function repoInfo(repo: string): Promise<Implementation['live']> {
  const url = new URL(repo)
  const slug = url.pathname.replace(/^\/|\/$/g, '')

  if (url.hostname === 'github.com') {
    const info = await getJson(`https://api.github.com/repos/${slug}`)
    return { lastActivity: info.pushed_at, stars: info.stargazers_count, archived: info.archived }
  }

  // GitLab instances (e.g. framagit.org)
  const info = await getJson(`https://${url.hostname}/api/v4/projects/${encodeURIComponent(slug)}`)
  return { lastActivity: info.last_activity_at, stars: info.star_count, archived: info.archived }
}

async function fetchLive(item: Omit<Implementation, 'live'>): Promise<Implementation['live']> {
  const [repo, version] = await Promise.allSettled([
    repoInfo(item.repo),
    item.package && registryVersion[item.package.registry]?.(item.package.name)
  ])

  return {
    ...(repo.status === 'fulfilled' ? repo.value : {}),
    ...(version.status === 'fulfilled' && version.value ? { version: version.value } : {})
  }
}

function readJson(file: string | undefined) {
  return file && fs.existsSync(file) ? JSON.parse(fs.readFileSync(file, 'utf8')) : undefined
}

async function loadLive(items: Omit<Implementation, 'live'>[], cacheFile: string) {
  if (process.env.LIVR_DOCS_OFFLINE) return {}

  const cached = readJson(cacheFile)
  if (cached && Date.now() - cached.fetchedAt < CACHE_TTL_MS) return cached.live

  const entries = await Promise.all(items.map(async (item) => [item.id, await fetchLive(item)] as const))
  const live = Object.fromEntries(entries)

  fs.mkdirSync(path.dirname(cacheFile), { recursive: true })
  fs.writeFileSync(cacheFile, JSON.stringify({ fetchedAt: Date.now(), live }, null, 2))
  return live
}

export default defineLoader({
  watch: ['./implementations.json', './conformance.json'],
  async load(files: string[]): Promise<ImplementationsData> {
    const implementationsFile = files.find((f) => f.endsWith('implementations.json'))!
    const conformanceFile = files.find((f) => f.endsWith('conformance.json'))
    const cacheFile = path.join(path.dirname(implementationsFile), '../.vitepress/cache/implementations-live.json')

    const items: Omit<Implementation, 'live'>[] = readJson(implementationsFile)
    const conformance = readJson(conformanceFile)
    const live = await loadLive(items, cacheFile)

    return {
      implementations: items.map((item) => ({
        ...item,
        live: live[item.id] ?? {},
        conformance: conformance?.results?.[item.id]
      })),
      conformanceGeneratedAt: conformance?.generatedAt,
      testSuiteTotal: conformance?.testSuite?.total
    }
  }
})
