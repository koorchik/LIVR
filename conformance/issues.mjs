#!/usr/bin/env node
// Keeps one GitHub issue per implementation that fails the LIVR test suite, so that its
// maintainer finds out.
//
//   node conformance/issues.mjs <conformance.json> <previous conformance.json> [--dry-run]
//
// The previous conformance.json is the one published on livr-spec.org; `{}` means there are
// no previous results yet.
//
// An issue is opened when an implementation fails cases that it passed in the previous run:
// - a regression: an unchanged case fails in a new version of the implementation;
// - a test suite update: a new or changed case fails.
// Without previous results for an implementation (the first run, or a newly added one), any
// failing case opens an issue, which reports the failures as a test suite update.
// A case that starts failing with the same version and unchanged case files points at the
// runner, not at the implementation, so it's only reported as a warning. Failures explained
// in notes.json (platform limitations) are ignored. Failures that were there before don't
// open an issue, but an open issue lists them too.
//
// While an issue is open, its description lists all failing cases, and newly failing cases
// are announced in a comment (editing the description doesn't notify anybody). The issue is
// closed once all cases pass. Issues are found by the "test suite" label and a hidden marker
// with the implementation id; an issue closed by hand isn't reopened.
//
// Needs GITHUB_TOKEN and GITHUB_REPOSITORY. With --dry-run nothing is written to GitHub.
// When GITHUB_STEP_SUMMARY is set, the report is appended to it.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { lastSuccessfulRun } from './results.mjs';

const here = path.dirname(fileURLToPath(import.meta.url));

const LABEL = 'test suite';
const BRANCH = 'master';
const SITE = 'https://livr-spec.org';
const REPO = process.env.GITHUB_REPOSITORY || 'koorchik/LIVR';
const REPO_URL = `${process.env.GITHUB_SERVER_URL || 'https://github.com'}/${REPO}`;
const API = `${process.env.GITHUB_API_URL || 'https://api.github.com'}/repos/${REPO}`;
const RUN_URL = process.env.GITHUB_RUN_ID && `${REPO_URL}/actions/runs/${process.env.GITHUB_RUN_ID}`;
const MARKER = /<!-- livr-conformance (.*?) -->/;
const KINDS = ['regression', 'new', 'changed', 'suite', 'failing'];

const readJson = file => JSON.parse(fs.readFileSync(file, 'utf8'));
const implementations = new Map(
    readJson(path.join(here, '..', 'docs', 'data', 'implementations.json')).map(impl => [impl.id, impl])
);

// Decides what happens to the issue of every implementation.
// `issues` maps implementation ids to their open issues: { number, url, body, cases }.
export function plan(current, previous, issues) {
    const actions = [];
    for (const [id, result] of Object.entries(current.results)) {
        const issue = issues.get(id);
        if (result.error) {
            actions.push({ id, result, type: 'skip', issue, unexplained: [] });
            continue;
        }

        const failing = result.failures.filter(f => !f.note);
        const base = lastSuccessfulRun(previous, id);
        const found = {};
        const unexplained = [];
        for (const { case: name } of base ? [] : failing) {
            if (!issue?.cases[name]) found[name] = { kind: 'suite' };
        }
        for (const { case: name } of base ? failing : []) {
            if (base.failing.includes(name)) continue;
            if (!(name in base.cases)) found[name] = { kind: 'new' };
            else if (base.cases[name] !== current.testSuite.cases[name]) found[name] = { kind: 'changed' };
            else if (base.version !== result.version) found[name] = { kind: 'regression', passedIn: base.version };
            else unexplained.push(name);
        }

        const cases = Object.fromEntries(
            failing.map(f => [f.case, found[f.case] ?? issue?.cases[f.case] ?? { kind: 'failing' }])
        );
        const announce = Object.keys(found).filter(name => !issue?.cases[name]);
        const action = { id, result, issue, cases, announce, unexplained };

        if (!failing.length) action.type = issue ? 'close' : 'none';
        else if (issue) action.type = 'update';
        else action.type = announce.length ? 'open' : 'none';
        actions.push(action);
    }
    return actions;
}

function describe(id, result) {
    const impl = implementations.get(id) || {};
    const github = impl.maintainer?.url?.match(/^https:\/\/github\.com\/([A-Za-z0-9-]+)\/?$/);
    return {
        language: impl.language || id,
        repo: impl.repo,
        pkg: result.package || id,
        version: result.version,
        maintainer: github ? `@${github[1]}` : impl.maintainer?.name,
    };
}

const caseUrl = name => `${REPO_URL}/tree/${BRANCH}/test_suite/${name}`;

function kindLabel({ kind, passedIn }) {
    if (kind === 'regression') return passedIn ? `regression, passed in ${passedIn}` : 'regression';
    if (kind === 'new') return 'new case';
    if (kind === 'changed') return 'updated case';
    return '';
}

function fence(text) {
    const ticks = '`'.repeat(Math.max(2, ...(text.match(/`+/g) || []).map(t => t.length)) + 1);
    return `${ticks}text\n${text}\n${ticks}`;
}

function caseList(cases, messages = {}) {
    const items = Object.entries(cases)
        .sort(([a, x], [b, y]) => KINDS.indexOf(x.kind) - KINDS.indexOf(y.kind) || a.localeCompare(b))
        .map(([name, entry]) => {
            const label = kindLabel(entry);
            const line = `- [\`${name}\`](${caseUrl(name)})${label ? ` — ${label}` : ''}`;
            const message = messages[name];
            if (!message) return line;
            const short = message.length > 1000 ? `${message.slice(0, 1000)}…` : message;
            return `${line}\n\n${fence(short).replace(/^/gm, '  ')}`;
        });
    return items.join(Object.keys(messages).length ? '\n\n' : '\n');
}

function marker(id, cases) {
    return `<!-- livr-conformance ${JSON.stringify({ id, cases })} -->`;
}

export function issueTitle(action) {
    const { pkg, version, language } = describe(action.id, action.result);
    return Object.values(action.cases).some(c => c.kind === 'regression')
        ? `Regression in ${pkg} ${version} (${language})`
        : `${pkg} ${version} (${language}) fails LIVR test suite cases`;
}

export function issueBody(action) {
    const { id, result, cases } = action;
    const { pkg, version, language, repo, maintainer } = describe(id, result);
    const entries = Object.values(cases);
    const has = kind => entries.some(c => c.kind === kind);
    const passedIn = [...new Set(entries.map(c => c.passedIn).filter(Boolean))];
    const suite = `[LIVR test suite](${SITE}/how-to-contribute/test-suite.html)`;
    const current = `**${pkg} ${version}**`;

    const intro = [];
    if (has('regression')) {
        const before = passedIn.length === 1 ? `**${passedIn[0]}**` : 'an earlier version';
        intro.push(`The ${suite} run found that ${current} fails cases that ${before} passed, so this looks like a regression.`);
    }
    if (has('new') || has('changed') || has('suite')) {
        intro.push(intro.length
            ? 'The test suite was also extended, and some of the new or updated cases fail too. These are not regressions: the test suite became stricter and found bugs that need fixing.'
            : `The ${suite} was extended, and ${current} fails some of its cases. This is not a regression in your release: the test suite became stricter and found bugs in the implementation that need fixing.`);
    }
    if (!intro.length) intro.push(`${current} fails the ${suite} cases below.`);

    const messages = Object.fromEntries(result.failures.map(f => [f.case, f.message]));
    const noted = result.failures.filter(f => f.note).length;
    const from = result.source === 'git' ? 'its repository' : result.source;
    const [, repoName] = REPO.split('/');
    const removal = new URLSearchParams({
        title: `Remove ${pkg} (${language}) from the implementations list`,
        body: `${pkg} (${repo || language}) is no longer maintained, please remove it from ${SITE}/introduction/implementations.html.`,
    });

    return [
        marker(id, cases),
        `Hi${maintainer ? ` ${maintainer}` : ''}!`,
        '',
        intro.join('\n\n'),
        '',
        '### Failing cases',
        '',
        caseList(cases, messages),
        ...(noted ? ['', `${noted} more case${noted > 1 ? 's fail' : ' fails'} for documented reasons (platform limitations) and ${noted > 1 ? "aren't" : "isn't"} counted, see the [test suite results](${SITE}/introduction/implementations.html#test-suite-results).`] : []),
        '',
        '### How it was tested',
        '',
        `[\`conformance/${id}/\`](${REPO_URL}/tree/${BRANCH}/conformance/${id}) installs ${pkg} ${version} from ${from} the way a user would and runs every test suite case against it. \`conformance/run.sh ${id}\` repeats the run locally (needs Docker).`,
        ...(result.notes?.length ? ['', ...result.notes.map(note => `- ${note}`)] : []),
        '',
        '### Get the test suite',
        '',
        `The cases are in the [\`test_suite/\`](${REPO_URL}/tree/${BRANCH}/test_suite) directory of the LIVR repository; the format is described in [Test suite](${SITE}/how-to-contribute/test-suite.html). To replace your copy with the current one, run this in the directory that contains it:`,
        '',
        '```sh',
        'rm -rf test_suite',
        `curl -fsSL ${REPO_URL}/archive/refs/heads/${BRANCH}.tar.gz | tar -xz --strip-components=1 ${repoName}-${BRANCH}/test_suite`,
        '```',
        '',
        "### What's next",
        '',
        'This issue is updated after every test suite run and closes by itself once all cases pass. If you think a case is wrong, please comment here.',
        '',
        `If ${pkg} is no longer maintained, please [open an issue](${REPO_URL}/issues/new?${removal}) to remove it from the [implementations list](${SITE}/introduction/implementations.html) on livr-spec.org.`,
        '',
        `<sub>Updated by the ${RUN_URL ? `[test suite run](${RUN_URL})` : 'test suite run'} on ${new Date().toISOString().slice(0, 10)}.</sub>`,
    ].join('\n');
}

export function announceComment(action) {
    const { pkg, version, maintainer } = describe(action.id, action.result);
    const cases = Object.fromEntries(action.announce.map(name => [name, action.cases[name]]));
    return [
        `${maintainer ? `${maintainer}, the` : 'The'} test suite run found more failing cases in **${pkg} ${version}**:`,
        '',
        caseList(cases),
        '',
        'The description above lists all failing cases.',
    ].join('\n');
}

export function closeComment(action) {
    const { pkg, version } = describe(action.id, action.result);
    return `All test suite cases pass in **${pkg} ${version}** now, closing.`;
}

// The footer changes on every run, so it doesn't count as a change of the description.
const withoutFooter = body => body.replace(/\n<sub>[^\n]*<\/sub>\s*$/, '');

async function github(method, url, body) {
    const token = process.env.GITHUB_TOKEN;
    const res = await fetch(`${API}${url}`, {
        method,
        headers: {
            accept: 'application/vnd.github+json',
            'x-github-api-version': '2022-11-28',
            ...(token && { authorization: `Bearer ${token}` }),
            ...(body && { 'content-type': 'application/json' }),
        },
        body: body && JSON.stringify(body),
    });
    if (!res.ok) throw new Error(`${method} ${url}: ${res.status} ${await res.text()}`);
    return res.status === 204 ? null : res.json();
}

async function openIssues() {
    const issues = new Map();
    const list = await github('GET', `/issues?state=open&labels=${encodeURIComponent(LABEL)}&per_page=100`);
    for (const issue of list) {
        const match = !issue.pull_request && issue.body?.match(MARKER);
        if (!match) continue;
        try {
            const { id, cases } = JSON.parse(match[1]);
            if (!issues.has(id)) issues.set(id, { number: issue.number, url: issue.html_url, body: issue.body, cases: cases || {} });
        } catch {
            console.error(`Ignoring a broken marker in ${issue.html_url}`);
        }
    }
    return issues;
}

async function ensureLabel() {
    try {
        await github('GET', `/labels/${encodeURIComponent(LABEL)}`);
    } catch {
        await github('POST', '/labels', {
            name: LABEL,
            color: '1a7fc4',
            description: 'An implementation fails the LIVR test suite (managed by CI)',
        });
    }
}

// Returns a line for the report.
async function apply(action, dryRun) {
    const { type, issue } = action;
    const verb = (now, then) => (dryRun ? `would ${now}` : then);
    const count = Object.keys(action.cases || {}).length;
    const failing = `${count} failing case${count === 1 ? '' : 's'}`;

    if (type === 'skip') return `not run (${action.result.error})${issue ? `, left ${issue.url} as is` : ''}`;
    if (type === 'none') return count ? `${failing}, no new failures, no issue` : 'all cases pass';

    if (type === 'open') {
        const title = issueTitle(action);
        if (dryRun) return `would open "${title}" (${failing})`;
        await ensureLabel();
        const created = await github('POST', '/issues', { title, body: issueBody(action), labels: [LABEL] });
        return `opened ${created.html_url} (${failing})`;
    }

    if (type === 'close') {
        if (!dryRun) {
            await github('POST', `/issues/${issue.number}/comments`, { body: closeComment(action) });
            await github('PATCH', `/issues/${issue.number}`, { state: 'closed', state_reason: 'completed' });
        }
        return `${verb('close', 'closed')} ${issue.url}: all cases pass`;
    }

    const body = issueBody(action);
    const edit = withoutFooter(body) !== withoutFooter(issue.body);
    if (!dryRun) {
        if (action.announce.length) await github('POST', `/issues/${issue.number}/comments`, { body: announceComment(action) });
        if (edit) await github('PATCH', `/issues/${issue.number}`, { body });
    }
    const what = [
        action.announce.length && `${verb('comment on', 'commented on')} new failures (${action.announce.join(', ')})`,
        edit && verb('update the description', 'updated the description'),
    ].filter(Boolean).join(', ') || 'nothing changed';
    return `${issue.url} (${failing}): ${what}`;
}

async function main() {
    const args = process.argv.slice(2);
    const dryRun = args.includes('--dry-run');
    const [currentFile, previousFile] = args.filter(arg => arg !== '--dry-run');
    if (!currentFile || !previousFile) {
        console.error('Usage: node conformance/issues.mjs <conformance.json> <previous conformance.json> [--dry-run]');
        process.exit(2);
    }
    if (!fs.existsSync(previousFile)) {
        // Without them every failure would look new. Pass a file with {} if there are none yet.
        console.error(`The previous results (${previousFile}) are unavailable, leaving the issues as they are.`);
        process.exit(1);
    }

    const current = readJson(currentFile);
    const previous = readJson(previousFile);
    const report = [];
    if (!previous.results) report.push('There are no previous results, so every failing implementation gets an issue.', '');

    let issues;
    try {
        issues = await openIssues();
    } catch (e) {
        if (!dryRun) throw e;
        console.error(`Couldn't read the open issues, assuming there are none: ${e.message}`);
        issues = new Map();
    }

    let failed = false;
    const rows = [];
    for (const action of plan(current, previous, issues)) {
        let line;
        try {
            line = await apply(action, dryRun);
        } catch (e) {
            failed = true;
            line = `error: ${e.message}`;
        }
        rows.push(`| ${action.id} | ${line.replaceAll('|', '\\|')} |`);
        console.log(`${action.id}: ${line}`);
        for (const name of action.unexplained) {
            const warning = `${action.id}: ${name} fails now, but the case and ${action.result.package} ${action.result.version} are the same as in the previous run. Check the runner.`;
            report.push(`- ⚠️ ${warning}`);
            console.log(process.env.GITHUB_ACTIONS ? `::warning title=Test suite::${warning}` : `warning: ${warning}`);
        }
    }

    if (process.env.GITHUB_STEP_SUMMARY) {
        const summary = [
            `### Test suite issues${dryRun ? ' (dry run)' : ''}`,
            '',
            '| Implementation | Issue |',
            '| --- | --- |',
            ...rows,
            '',
            ...report,
            '',
        ].join('\n');
        fs.appendFileSync(process.env.GITHUB_STEP_SUMMARY, summary + '\n');
    }
    if (failed) process.exit(1);
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) await main();
