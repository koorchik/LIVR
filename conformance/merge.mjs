#!/usr/bin/env node
// Merges per-implementation results (<id>.json, written by conformance/run.sh)
// into a single conformance.json and attaches the notes from notes.json.
//
//   node conformance/merge.mjs [results-dir] [output-file] [previous-file]
//
// Defaults: conformance/out and <results-dir>/conformance.json. previous-file is the
// conformance.json of the previous run (published on livr-spec.org): when an implementation
// can't be installed now, its last successful run is carried over from it, so that
// issues.mjs still has something to compare the next run with.
// When GITHUB_STEP_SUMMARY is set, a Markdown table is appended to it.
//
// Results of the LIVR 2.5 suite (<id>.v2.5.json, SUITE=2.5 conformance/run.sh) go to
// suites["2.5"]: { testSuite, results }. The top level stays the 2.0 suite, so issues.mjs,
// which reads only the top level, opens no issues for 2.5 until it is released.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { lastSuccessfulRun, testSuiteCases } from './results.mjs';

const here = path.dirname(fileURLToPath(import.meta.url));
const resultsDir = path.resolve(process.argv[2] || path.join(here, 'out'));
const outFile = path.resolve(process.argv[3] || path.join(resultsDir, 'conformance.json'));
const previousFile = process.argv[4] && path.resolve(process.argv[4]);

const notes = JSON.parse(fs.readFileSync(path.join(here, 'notes.json'), 'utf8'));

const suiteCases = testSuiteCases(path.join(here, '..', 'test_suite'));
const suiteTotal = Object.keys(suiteCases).length;
const suite25Dir = path.join(here, '..', 'test_suite_2.5');
const suite25Cases = fs.existsSync(suite25Dir) ? testSuiteCases(suite25Dir) : {};

let previous = null;
if (previousFile && fs.existsSync(previousFile)) {
    try {
        previous = JSON.parse(fs.readFileSync(previousFile, 'utf8'));
    } catch (e) {
        console.error(`Ignoring ${previousFile}: ${e.message}`);
    }
}

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
const results25 = {};
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
    const is25 = file.endsWith('.v2.5.json');
    // The suites have their own case names, so each has its own notes
    const caseNotes = (is25 ? extra['cases_2.5'] : extra.cases) || {};
    result.notes = extra.notes || [];
    result.failures = (result.failures || []).map(f =>
        caseNotes[f.case] ? { ...f, note: caseNotes[f.case] } : f
    );
    if (is25) results25[result.id] = result;
    else results[result.id] = result;
}

const lastSuccessful = {};
for (const [id, result] of Object.entries(results)) {
    const run = result.error && lastSuccessfulRun(previous, id);
    if (run) lastSuccessful[id] = run;
}

const merged = { generatedAt: new Date().toISOString(), testSuite: { total: suiteTotal, cases: suiteCases }, results };
if (Object.keys(lastSuccessful).length) merged.lastSuccessful = lastSuccessful;
if (Object.keys(results25).length) {
    merged.suites = {
        '2.5': { testSuite: { total: Object.keys(suite25Cases).length, cases: suite25Cases }, results: results25 },
    };
}
fs.mkdirSync(path.dirname(outFile), { recursive: true });
fs.writeFileSync(outFile, JSON.stringify(merged, null, 2) + '\n');
console.log(`Wrote ${outFile} (${Object.keys(results).length} implementations, ${suiteTotal} test cases)`);
if (merged.suites) {
    console.log(`  2.5: ${Object.keys(results25).length} implementations, ${merged.suites['2.5'].testSuite.total} test cases`);
}

if (process.env.GITHUB_STEP_SUMMARY) {
    fs.appendFileSync(process.env.GITHUB_STEP_SUMMARY, summaryTable('LIVR test suite conformance', results, suiteTotal));
    if (merged.suites) {
        const { testSuite } = merged.suites['2.5'];
        fs.appendFileSync(process.env.GITHUB_STEP_SUMMARY, summaryTable('LIVR 2.5 suite', results25, testSuite.total));
    }
}

function summaryTable(title, results, total) {
    const rows = Object.values(results).map(r => {
        // Failures explained in notes.json (platform limitations) are not counted, as on the site
        const notCounted = r.failures.filter(f => f.note).map(f => `\`${f.case}\``);
        const score = r.error ? `⚠️ ${r.error}` : `${r.passed}/${r.total - notCounted.length}`;
        const failing = [
            r.failures.filter(f => !f.note).map(f => `\`${f.case}\``).join(', '),
            notCounted.length ? `not counted: ${notCounted.join(', ')}` : '',
        ].filter(Boolean).join('; ') || '—';
        return `| ${r.id} | ${r.package ?? ''} ${r.version ?? ''} | ${score} | ${failing} |`;
    });
    const table = [
        `### ${title} (${total} cases)`,
        '',
        '| Implementation | Package | Passed | Failing cases |',
        '| --- | --- | --- | --- |',
        ...rows,
        '',
    ].join('\n');
    return table + '\n';
}
