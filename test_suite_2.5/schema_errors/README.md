# Schema errors

Schemas that must not build (LIVR 2.5 draft, sections 2.5, 2.6, 3.3 and 6). Building the
validator fails when a rule gets arguments that do not match its signature: a wrong type, an
unknown option or value, a missing required argument, an argument for a rule that takes none, an
empty rule list `[]` where a new rule takes rules, bounds that no value could pass, or an invalid
field reference.

Each directory holds one schema error:

- `rules.json`: the schema;
- `aliases.json`: aliased rules to register, when the error is inside an alias.

A case passes when building the validator (with the aliases registered) fails. How the failure is
reported (an exception, an error value) is up to the implementation. In languages that build
validators lazily, the harness forces the build (for example `validator.prepare()` in JavaScript).

Not in this directory, because these schemas are valid (their cases are in `positive/` and
`negative/`). Arguments after the ones a rule takes are implementation-defined (ignored or a schema
error), so no case passes them, except to a rule that takes no arguments (`{"boolean": 1}`, a
schema error):

- a number where a rule takes a string, or a string with a number where it takes a number: they
  are interchangeable, so `{"max_decimals": "2"}`, `{"mac": "64"}` and `{"split": 1}` are valid.
  The value still has to be right: `{"uuid": 4}` and `{"uuid": "4"}` are both schema errors
  (`"4"` is not `"v4"`), and so are `{"mac": 32}` and `{"mac": "32"}`;
- a fixed and a relative bound with `min` later than `max` (`{"iso_date": {"min": "2026-12-01",
  "max": "today"}}`): whether a value can pass depends on the day, so they are not checked;
  `min` later than `max` in `iso_time` is a range over midnight;
- `iso_date` with a first argument that is not an options object (`{"iso_date": "x"}`,
  `{"iso_date": "today"}`, `{"iso_date": true}`) is a schema error here, although LIVR 2.0
  ignored it;
- `{"iso_date": null}`: one `null` argument, which LIVR 2.0 ignored, so it stays the plain
  `iso_date` (`positive/08-iso_date`). For the other new rules a `null` argument is a schema error
  (`{"boolean": null}`, `{"uuid": null}`);
- `[]` as the rules of a LIVR 2.0 rule (a field with `[]`, `list_of`, `or`): only the new rules
  that take rules (`when`, `values`, `keys`) reject it. Use `"any"` for a branch without rules.
