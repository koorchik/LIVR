// Helpers shared by merge.mjs and issues.mjs.
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';

const list = dir => fs.readdirSync(dir).filter(name => !name.startsWith('.')).sort();

// { "positive/01-required": "<hash of the case files>", … }. The hash tells whether a case
// changed between two runs.
export function testSuiteCases(suiteDir) {
    const cases = {};
    for (const suite of list(suiteDir)) {
        for (const name of list(path.join(suiteDir, suite))) {
            const dir = path.join(suiteDir, suite, name);
            const hash = crypto.createHash('sha256');
            for (const file of list(dir)) {
                hash.update(file).update('\0').update(fs.readFileSync(path.join(dir, file))).update('\0');
            }
            cases[`${suite}/${name}`] = hash.digest('hex').slice(0, 12);
        }
    }
    return cases;
}

// The last run of an implementation that produced results, as
// { generatedAt, version, failing: [case, …], cases: <testSuiteCases of that run> }.
// When the implementation couldn't be installed, merge.mjs carries the previous one over
// in `lastSuccessful`. Returns null if there is no such run.
export function lastSuccessfulRun(conformance, id) {
    const result = conformance?.results?.[id];
    if (result && !result.error) {
        if (!conformance.testSuite?.cases) return null;
        return {
            generatedAt: conformance.generatedAt,
            version: result.version,
            failing: result.failures.map(f => f.case),
            cases: conformance.testSuite.cases,
        };
    }
    return conformance?.lastSuccessful?.[id] ?? null;
}
