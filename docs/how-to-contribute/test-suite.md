# Test suite

The [`test_suite`](https://github.com/koorchik/LIVR/tree/master/test_suite) directory is the executable part of the specification. Every implementation runs it, and an implementation that passes it behaves like all the others. The cases are plain JSON files, so any language can read them.

## Layout

```text
test_suite/
├── positive/            valid data: check the output
│   └── 01-required/
│       ├── rules.json
│       ├── input.json
│       └── output.json
├── negative/            invalid data: check the errors
│   └── 01-required/
│       ├── rules.json
│       ├── input.json
│       └── errors.json
├── aliases_positive/    like positive, plus aliases.json
└── aliases_negative/    like negative, plus aliases.json
```

Each case is a directory named `NN-rule_name`:

| File | Content |
|---|---|
| `rules.json` | The validation rules |
| `input.json` | The data to validate |
| `output.json` | *positive cases:* the expected output of the validator |
| `errors.json` | *negative cases:* the expected errors |
| `aliases.json` | *alias cases:* a list of [aliases](/rules-aliasing.html) to register before validation |

## Getting the cases

Copy the `test_suite` directory into your implementation's repository and update it when the specification changes. To replace your copy with the current one, run this in the directory that contains it:

```sh
rm -rf test_suite
curl -fsSL https://github.com/koorchik/LIVR/archive/refs/heads/master.tar.gz | tar -xz --strip-components=1 LIVR-master/test_suite
```

## Running the cases

For every case:

1. Create a validator with `rules.json`.
2. For alias cases, register every alias from `aliases.json`.
3. Validate `input.json`.
4. **Positive:** validation must succeed, and the output must be equal to `output.json`.
   **Negative:** validation must fail, and the errors must be equal to `errors.json`.

Compare the values deeply, ignoring the order of object keys. Remember that JSON has a limited set of types, see [Types coercing](/validation-rules/types-coercing.html#the-test-suite-and-types).

In pseudo code:

```js
for (const dir of listDirs('test_suite/positive')) {
    const validator = new Validator(readJson(`${dir}/rules.json`))
    const output = validator.validate(readJson(`${dir}/input.json`))
    assert.deepEqual(output, readJson(`${dir}/output.json`))
}

for (const dir of listDirs('test_suite/negative')) {
    const validator = new Validator(readJson(`${dir}/rules.json`))
    assert.equal(validator.validate(readJson(`${dir}/input.json`)), false)
    assert.deepEqual(validator.getErrors(), readJson(`${dir}/errors.json`))
}
```

Every rule page of this site shows the test suite cases of that rule, and you can edit and run them in the browser. Look for the "Test suite cases" block below each rule.

## Conformance results

The [`conformance/`](https://github.com/koorchik/LIVR/tree/master/conformance) directory contains a small test suite runner for each implementation. CI runs them against the latest version of every implementation, and the results are published on the [implementations page](/introduction/implementations.html#test-suite-results).

When an implementation starts failing cases, because of a regression in a new release or because the test suite got new cases, CI opens an [issue](https://github.com/koorchik/LIVR/issues?q=label%3A%22test+suite%22) that mentions its maintainer. The issue closes by itself once all cases pass.

## Adding cases

Found an edge case that implementations handle differently? Add it to the test suite:

1. Add the case to an existing directory, or create a new `NN-rule_name` directory with the next free number.
2. Check that the [JavaScript implementation](https://github.com/koorchik/js-validator-livr) passes it. The live examples on this site make that easy.
3. Open a pull request and describe the behavior the case defines.
