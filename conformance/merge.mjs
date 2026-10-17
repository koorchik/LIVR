#!/usr/bin/env node
// Merges per-implementation results (<id>.json, written by conformance/run.sh)
// into a single conformance.json and attaches the notes from notes.json.
//
//   node conformance/merge.mjs [results-dir] [output-file]
//
// Defaults: conformance/out and <results-dir>/conformance.json.
// When GITHUB_STEP_SUMMARY is set, a Markdown table is appended to it.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const resultsDir = path.resolve(process.argv[2] || path.join(here, 'out'));
const outFile = path.resolve(process.argv[3] || path.join(resultsDir, 'conformance.json'));

const notes = JSON.parse(fs.readFileSync(path.join(here, 'notes.json'), 'utf8'));

const suiteDir = path.join(here, '..', 'test_suite');
const suiteTotal = fs.readdirSync(suiteDir)
    .filter(s => !s.startsWith('.'))
    .reduce((n, s) => n + fs.readdirSync(path.join(suiteDir, s)).filter(c => !c.startsWith('.')).length, 0);

function findResultFiles(dir) {
    // download-artifact puts each artifact in its own sub-directory.
    const files = [];
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
        const full = path.join(dir, entry.name);
        if (entry.isDirectory()) files.push(...findResultFiles(full));
        else if (entry.name.endsWith('.json') && full !== outFile && entry.name !== 'conformance.json') files.push(full);
    }
    return files;
}

const results = {};
for (const file of findResultFiles(resultsDir).sort()) {
    let result;
    try {
        result = JSON.parse(fs.readFileSync(file, 'utf8'));
    } catch (e) {
        console.error(`Skipping ${file}: ${e.message}`);
        continue;
    }
    if (!result || typeof result.id !== 'string') continue;

    const extra = notes[result.id] || {};
    result.notes = extra.notes || [];
    result.failures = (result.failures || []).map(f =>
        extra.cases && extra.cases[f.case] ? { ...f, note: extra.cases[f.case] } : f
    );
    results[result.id] = result;
}

const merged = { generatedAt: new Date().toISOString(), testSuite: { total: suiteTotal }, results };
fs.mkdirSync(path.dirname(outFile), { recursive: true });
fs.writeFileSync(outFile, JSON.stringify(merged, null, 2) + '\n');
console.log(`Wrote ${outFile} (${Object.keys(results).length} implementations, ${suiteTotal} test cases)`);

if (process.env.GITHUB_STEP_SUMMARY) {
    const rows = Object.values(results).map(r => {
        const score = r.error ? `⚠️ ${r.error}` : `${r.passed}/${r.total}`;
        const failing = r.failures.map(f => `\`${f.case}\``).join(', ') || '—';
        return `| ${r.id} | ${r.package ?? ''} ${r.version ?? ''} | ${score} | ${failing} |`;
    });
    const table = [
        `### LIVR test suite conformance (${suiteTotal} cases)`,
        '',
        '| Implementation | Package | Passed | Failing cases |',
        '| --- | --- | --- | --- |',
        ...rows,
        '',
    ].join('\n');
    fs.appendFileSync(process.env.GITHUB_STEP_SUMMARY, table + '\n');
}
