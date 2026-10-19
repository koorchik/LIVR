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
and `note` on individual failures (for example, platform limitations). `testSuite.cases`
maps every case to a hash of its files, so the next run can tell which cases changed.
When an implementation couldn't be installed, its last successful run is carried over
from the previous results into `lastSuccessful`.

The site publishes the merged file as
[livr-spec.org/conformance.json](https://livr-spec.org/conformance.json).

## Issues for maintainers

After every run on `master`, [`issues.mjs`](issues.mjs) compares the results with the
previous ones (the published `conformance.json`) and keeps one issue per failing
implementation, labeled `test suite`, that mentions its maintainer:

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
