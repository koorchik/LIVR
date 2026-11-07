// Runs the LIVR test suite against the npm "livr" package.
// Comparison mirrors js-validator-livr's own tests (ava t.deepEqual):
// strict deep equality, value types matter, key order does not.
// LIVR_MODULE runs it against another copy of the package, e.g. a local checkout:
//   LIVR_MODULE=../../../js-validator-livr TEST_SUITE_DIR=../../test_suite_2.5 node harness.mjs
import fs from 'node:fs';
import path from 'node:path';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const LIVR_MODULE = process.env.LIVR_MODULE ? path.resolve(process.env.LIVR_MODULE) : 'livr';
const LIVR = require(LIVR_MODULE);
const { version } = JSON.parse(fs.readFileSync(require.resolve(`${LIVR_MODULE}/package.json`), 'utf8'));

const SUITE_DIR = process.env.TEST_SUITE_DIR || '../../test_suite';
const SUITES = ['positive', 'negative', 'aliases_positive', 'aliases_negative'];
// LIVR 2.5: schemas that must not build
const SCHEMA_ERRORS = 'schema_errors';

function readJson(dir, name) {
    const file = path.join(dir, `${name}.json`);
    return fs.existsSync(file) ? JSON.parse(fs.readFileSync(file, 'utf8')) : undefined;
}

function deepEqual(a, b) {
    if (a === b) return true;
    if (typeof a !== typeof b || a === null || b === null || typeof a !== 'object') return false;
    if (Array.isArray(a) !== Array.isArray(b)) return false;
    if (Array.isArray(a)) {
        return a.length === b.length && a.every((v, i) => deepEqual(v, b[i]));
    }
    const ka = Object.keys(a);
    const kb = Object.keys(b);
    return ka.length === kb.length && ka.every(k => Object.prototype.hasOwnProperty.call(b, k) && deepEqual(a[k], b[k]));
}

function show(value) {
    const s = JSON.stringify(value);
    return s === undefined ? String(value) : s.length > 300 ? `${s.slice(0, 300)}…` : s;
}

// LIVR 2.5: options.json {"now": "..."} is the current time for the bounds today, yesterday and
// tomorrow. livr reads the system clock, Date.now(), so it is stubbed for the case and restored
function withClock(options, fn) {
    if (!options || options.now === undefined) return fn();
    const now = Date.parse(options.now);
    if (!Number.isFinite(now)) throw new Error(`options.json: a wrong "now": ${show(options.now)}`);
    const realNow = Date.now;
    Date.now = () => now;
    try {
        return fn();
    } finally {
        Date.now = realNow;
    }
}

function runSchemaErrorCase(dir) {
    try {
        const validator = new LIVR.Validator(readJson(dir, 'rules'));
        for (const alias of readJson(dir, 'aliases') || []) validator.registerAliasedRule(alias);
        validator.prepare();
    } catch (e) {
        return null;
    }
    return 'expected building the validator to fail';
}

function runCase(suite, dir) {
    const run = suite === SCHEMA_ERRORS ? () => runSchemaErrorCase(dir) : () => runValidationCase(suite, dir);
    return withClock(readJson(dir, 'options'), run);
}

function runValidationCase(suite, dir) {
    const rules = readJson(dir, 'rules');
    const input = readJson(dir, 'input');
    const aliases = readJson(dir, 'aliases') || [];
    const validator = new LIVR.Validator(rules);
    for (const alias of aliases) validator.registerAliasedRule(alias);

    const output = validator.validate(input);
    const errors = validator.getErrors();

    if (suite.endsWith('positive')) {
        const expected = readJson(dir, 'output');
        if (errors) return `expected no errors, got ${show(errors)}`;
        if (!deepEqual(output, expected)) return `expected output ${show(expected)}, got ${show(output)}`;
    } else {
        const expected = readJson(dir, 'errors');
        if (output) return `expected validation to fail, got output ${show(output)}`;
        if (!deepEqual(errors, expected)) return `expected errors ${show(expected)}, got ${show(errors)}`;
    }
    return null;
}

const result = { id: 'js', package: 'livr', version, source: 'npm', total: 0, passed: 0, failures: [], error: null };

const suites = fs.existsSync(path.join(SUITE_DIR, SCHEMA_ERRORS)) ? [...SUITES, SCHEMA_ERRORS] : SUITES;

for (const suite of suites) {
    const suiteDir = path.join(SUITE_DIR, suite);
    const names = fs.readdirSync(suiteDir).filter(n => !n.startsWith('.')).sort();
    for (const name of names.filter(n => fs.statSync(path.join(suiteDir, n)).isDirectory())) {
        result.total++;
        let message;
        try {
            message = runCase(suite, path.join(suiteDir, name));
        } catch (e) {
            message = `exception: ${e && e.message ? e.message : e}`;
        }
        if (message) result.failures.push({ case: `${suite}/${name}`, message });
        else result.passed++;
    }
}

const json = JSON.stringify(result, null, 2) + '\n';
if (process.env.OUT_FILE) fs.writeFileSync(process.env.OUT_FILE, json);
else process.stdout.write(json);
