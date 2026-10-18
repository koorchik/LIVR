# Changelog

## v2.0

- Switched to semver. The new release version is 2.0.
- Unified approach to types handling.
- "Base rules" renamed to "Common rules".
- "Filter rules" renamed to "Modifiers". They do not validate anything, they just modify data.
- "Helper rules" renamed to "Metarules", as these rules are for describing other rules.
- Added common rule [`any_object`](/validation-rules/any_object.html).
- Added string rule [`string`](/validation-rules/string.html).
- Added string rule [`eq`](/validation-rules/eq.html).
- Added metarule [`variable_object`](/validation-rules/variable_object.html).
- Added metarule [`or`](/validation-rules/or.html).
- Added modifier [`default`](/validation-rules/default.html).
- Added more edge cases to the test suite.
- Marked the [`like`](/validation-rules/like.html) rule as experimental.

## v0.4

- Added special rules [`url`](/validation-rules/url.html) and [`iso_date`](/validation-rules/iso_date.html).
- Added filter rules [`remove`](/validation-rules/remove.html) and [`leave_only`](/validation-rules/leave_only.html).
- Added support for the `i` flag to the [`like`](/validation-rules/like.html) rule.
- Introduced a new syntax for the `one_of` and `list_of` rules, see [below](#syntax-changes-for-one-of-and-list-of-rules).
- [Rules aliasing](/rules-aliasing.html), with custom errors.

## v0.3

- Added filter rule [`trim`](/validation-rules/trim.html).
- Added filter rule [`to_lc`](/validation-rules/to_lc.html).
- Added filter rule [`to_uc`](/validation-rules/to_uc.html).

## v0.2

- Added the [`not_empty_list`](/validation-rules/not_empty_list.html) rule with test cases.

## Syntax changes for `one_of` and `list_of` rules {#syntax-changes-for-one-of-and-list-of-rules}

The old syntax `{ one_of: [['val1', 'val2']] }` was hard to remember for many people. The idea was that the list of allowed values is passed as a single array argument: `{ one_of: [['val1', 'val2']] }` becomes `one_of(['val1', 'val2'])`. But that is not obvious for users.

So a new syntax was introduced: `{ one_of: ['val1', 'val2'] }` becomes `one_of('val1', 'val2')`. The problem is that you do not know how many arguments will be passed to `one_of`, and both syntaxes must be supported for backward compatibility (the test suite covers both). It was decided that the `one_of` and `list_of` rules handle both syntaxes by themselves.

## Documentation TODO

- Describe the internals with a detailed step-by-step example.
- Write a developers guide.
