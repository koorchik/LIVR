# Changelog

## v2.0

- Switched to semver. The new release version is 2.0.
- Unified approach to types handling.
- "Base rules" renamed to "Common rules".
- "Filter rules" renamed to "Modifiers". They do not validate anything, they just modify data.
- "Helper rules" renamed to "Metarules", as these rules are for describing other rules.
- Added common rule [`any_object`](/validation-rules/common-rules.html#any-object).
- Added string rule [`string`](/validation-rules/string-rules.html#string).
- Added string rule [`eq`](/validation-rules/string-rules.html#eq).
- Added metarule [`variable_object`](/validation-rules/metarules.html#variable-object).
- Added metarule [`or`](/validation-rules/metarules.html#or).
- Added modifier [`default`](/validation-rules/modifiers.html#default).
- Added more edge cases to the test suite.
- Marked the [`like`](/validation-rules/string-rules.html#like) rule as experimental.

## v0.4

- Added special rules [`url`](/validation-rules/special-rules.html#url) and [`iso_date`](/validation-rules/special-rules.html#iso-date).
- Added filter rules [`remove`](/validation-rules/modifiers.html#remove) and [`leave_only`](/validation-rules/modifiers.html#leave-only).
- Added support for the `i` flag to the [`like`](/validation-rules/string-rules.html#like) rule.
- Introduced a new syntax for the `one_of` and `list_of` rules, see [below](#syntax-changes-for-one-of-and-list-of-rules).
- [Rules aliasing](/rules-aliasing.html), with custom errors.

## v0.3

- Added filter rule [`trim`](/validation-rules/modifiers.html#trim).
- Added filter rule [`to_lc`](/validation-rules/modifiers.html#to-lc).
- Added filter rule [`to_uc`](/validation-rules/modifiers.html#to-uc).

## v0.2

- Added the [`not_empty_list`](/validation-rules/common-rules.html#not-empty-list) rule with test cases.

## Syntax changes for `one_of` and `list_of` rules {#syntax-changes-for-one-of-and-list-of-rules}

The old syntax `{ one_of: [['val1', 'val2']] }` was hard to remember for many people. The idea was that the list of allowed values is passed as a single array argument: `{ one_of: [['val1', 'val2']] }` becomes `one_of(['val1', 'val2'])`. But that is not obvious for users.

So a new syntax was introduced: `{ one_of: ['val1', 'val2'] }` becomes `one_of('val1', 'val2')`. The problem is that you do not know how many arguments will be passed to `one_of`, and both syntaxes must be supported for backward compatibility (the test suite covers both). It was decided that the `one_of` and `list_of` rules handle both syntaxes by themselves.

## Documentation TODO

- Describe the internals with a detailed step-by-step example.
- Write a developers guide.
