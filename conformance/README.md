# Conformance

Runs the LIVR [test suite](../test_suite) against every known implementation and
reports how many cases each one passes. The results feed the implementations table
on [livr-spec.org](https://livr-spec.org).

Every implementation is installed the way a user would get it (npm, CPAN, PyPI,
hex, …, or from its repository if it isn't published) inside the language's
official Docker image, so local runs and CI behave the same.

## Run locally

Requires Docker (and Node.js for the summary line).

```sh
conformance/run.sh js        # one implementation
conformance/run.sh all       # all of them, one after another
node conformance/merge.mjs   # merge conformance/out/*.json into conformance/out/conformance.json
```

Each run writes `conformance/out/<id>.json` and the full install/run log to
`conformance/out/<id>.log`.

### LIVR 2.5 suite

```sh
SUITE=2.5 conformance/run.sh js   # runs test_suite_2.5, writes conformance/out/js.v2.5.json
```

The 2.5 suite has the same layout as `test_suite`. A case may have `options.json` with
`{"now": "…"}`, the current time for `iso_date` bounds. Only harnesses listed in `CLOCK_IDS` in
`run.sh` fix the clock to it, the way the tests of the implementation do (the JavaScript harness
stubs `Date.now()` for the case); the other implementations run a copy of the suite without such
cases. The 2.5 suite also has `schema_errors/`: schemas that must not build, a case passes
when creating the validator (with its aliases registered) fails. Only the JavaScript harness runs
them for now; the other harnesses read the four usual directories. `merge.mjs` puts the 2.5 results into `suites["2.5"]` of `conformance.json`, and the site shows
them in a separate column. `issues.mjs` reads only the top level (the 2.0 suite), so issues are opened only for the
2.0 suite: most implementations don't have the 2.5 rules yet.

To run the JavaScript harness against a local checkout of js-validator-livr, without Docker:

```sh
cd conformance/js
LIVR_MODULE=<path to js-validator-livr> TEST_SUITE_DIR=../../test_suite_2.5 node harness.mjs
```

`livr-swift-validator` builds only against Apple's Foundation. On a Mac with Xcode,
run it without Docker: `NATIVE=1 conformance/run.sh swift`.

## How a case is judged

For each case in `positive`, `negative`, `aliases_positive` and `aliases_negative`,
the harness creates a validator from `rules.json`, registers the aliases from
`aliases.json` (alias suites only), and validates `input.json`.

- **positive**: passes if validation succeeds and the output equals `output.json`.
- **negative**: passes if validation fails and the errors equal `errors.json`.

How values are compared follows each implementation's own test runner. For example,
the Perl harness compares scalars as strings like `is_deeply` does, while the
JavaScript harness is type-strict like `t.deepEqual`. The comment at the top of
each harness explains its comparison rules.

## Result format

```json
{
  "id": "js",
  "package": "livr",
  "version": "2.10.2",
  "source": "npm",
  "total": 70,
  "passed": 63,
  "failures": [{ "case": "negative/01-required", "message": "expected errors …, got …" }],
  "error": null
}
```

`error` is set when the implementation couldn't be installed or built. `merge.mjs`
combines all results into `{ generatedAt, testSuite: { total, cases }, results: { <id>: … } }`
and adds the explanations from [`notes.json`](notes.json): `notes` per implementation
and `note` on individual failures. A failure gets a note only when the implementation
can't pass the case because of its language (for example, PHP and Lua decode `{}` and
`[]` to the same value), not for bugs. Such cases are not counted: the site shows PHP
with two of them as 68/68, and an implementation that passes everything else gets a
green badge. Notes for the cases of the 2.5 suite go under `cases_2.5`, because
the two suites have different case names. `testSuite.cases`
maps every case to a hash of its files, so the next run can tell which cases changed.
When an implementation couldn't be installed, its last successful run is carried over
from the previous results into `lastSuccessful`.

The site publishes the merged file as
[livr-spec.org/conformance.json](https://livr-spec.org/conformance.json).

## Issues for maintainers

After every run on `master`, [`issues.mjs`](issues.mjs) compares the results with the
previous ones (the published `conformance.json`) and keeps one issue per failing
implementation, in the implementation's own GitHub repository (`repo` in
[`implementations.json`](../docs/data/implementations.json)), that mentions its maintainer:

- **Regression:** a case that passed before fails in a new version of the implementation.
- **Test suite update:** a new or changed case fails. Without previous results for an
  implementation (the first run, or a newly added implementation), every failing case
  counts as one.

The issue lists the failing cases, explains how to get the current test suite, and links
to a prefilled issue for asking to remove an unmaintained implementation from the site.
The issue and every comment on it say that the results on
[livr-spec.org](https://livr-spec.org/introduction/implementations.html) are updated
automatically every week.
While it's open, new failures are announced in a comment. It's closed automatically when
all cases pass. Failures explained in `notes.json` are not counted. A case that starts
failing with the same version and unchanged case files points at the runner, so it only
shows up as a warning in the job summary. In pull requests the script runs with
`--dry-run` and only reports in the job summary what it would do.

When the implementation's repository isn't on GitHub, is archived or has issues turned
off, the issue is opened in this repository instead. Only repositories where the token can
push get the `test suite` label; elsewhere the script finds its issues by their author and
a hidden marker. An open issue found in the wrong repository (opened in this one before, or
the implementation moved) is moved: a new issue is opened where it belongs, and the old one
is closed with a link to it.

Opening issues in other people's repositories needs the `ISSUES_TOKEN` secret: a classic
personal access token with the `public_repo` scope (fine-grained tokens and the workflow's
own token can't do it). The issues are opened on behalf of the token's account.

```sh
node conformance/issues.mjs conformance/out/conformance.json previous.json --dry-run
```

`previous.json` is a downloaded [livr-spec.org/conformance.json](https://livr-spec.org/conformance.json),
or a file with `{}` to see what happens without previous results.

## Add an implementation

1. Create `conformance/<id>/` with:
   - `container.sh`, which installs the implementation and runs the harness. It is
     run with `sh` from a copy of the directory, sources `common.sh` and can call
     `fail "<reason>"` if the install fails. It gets `TEST_SUITE_DIR` and `OUT_FILE`
     in the environment.
   - The harness itself, which writes the result JSON above to `$OUT_FILE`.
2. Add the id and its Docker image to `IDS` and `image_for` in [`run.sh`](run.sh).
3. Add the id to the matrix in [`.github/workflows/conformance.yml`](../.github/workflows/conformance.yml).
4. Add the same id to the docs' implementations list, so the site can show the result.
