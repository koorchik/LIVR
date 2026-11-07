# Changelog

<a id="v2-5-draft"></a>

## v2.5 {#v2-5}

Released on 2026-11-07. The specification is in [`drafts/v2.5.md`](https://github.com/koorchik/LIVR/blob/master/drafts/v2.5.md), and the [conformance table](/introduction/implementations.html#test-suite-results) shows which implementations pass the 2.5 test suite.

LIVR 2.5 only adds rules. Every LIVR 2.0 schema gives the same result in a 2.5 implementation, except for the fixes below: they change only schemas that never worked as written.

- Existing rules keep their behavior, error codes and test cases. One existing rule, [`iso_date`](/validation-rules/iso_date.html#options-form), gets a new argument form; its 2.0 forms are unchanged.
- The syntax of schemas and the validator API do not change. Tests fix the current time for the date bounds (`today`, `yesterday`, `tomorrow`) of [`iso_date`](/validation-rules/iso_date.html#the-current-date) and [`iso_datetime`](/validation-rules/iso_datetime.html#current-date) with the usual tools of the language.
- Fix: rules that read other fields ([`equal_to_field`](/validation-rules/equal_to_field.html#containing-object) and custom rules) saw a made-up object inside an alias, an `or` branch and an item of `list_of` in LIVR 2.0 (`{ value: x }`, `{ field: x }`, `{ field: item }` in the JavaScript implementation), so a comparison with a sibling field never worked there. 2.5 defines it through the [containing object](/validation-rules/how-it-works.html#field-references): in an alias or an `or` branch the rules see the siblings of the field, in an item of `list_of` they see no fields. A schema that relied on the made-up object gives a different result.
- Fix: [`iso_date`](/validation-rules/iso_date.html#options-form) ignored any argument in 2.0, so `{ iso_date: 'today' }` or `{ iso_date: 'datetime' }` silently checked nothing of what they say. In 2.5 an argument that is not an options object is a schema error, and a boolean value gives `WRONG_DATE` in every implementation (some gave `FORMAT_ERROR`).
- Fix: [`iso_date`](/validation-rules/iso_date.html) uses the proleptic Gregorian calendar, as almost every implementation already did: `1582-10-10` is valid and `1500-02-29` is not (Ruby used the Julian calendar before October 1582).
- Fix: an unknown rule is a [schema error](/validation-rules/how-it-works.html#arguments) in every implementation. Swift ignored it in 2.0 and olifer gave a field error, so a typo in a rule name checked nothing.
- A clarification of [`like`](/validation-rules/like.html): `^` at the start and `$` at the end of a pattern match only at the start and the end of the value, so `{ like: '^[0-9]{5}$' }` rejects `"12345\n"`.
- A "LIVR 2.5 compatible" implementation supports all the new rules. There are no optional modules.
- The new rules follow the [conventions of the 2.5 rules](/validation-rules/how-it-works.html#conventions-2-5): empty values, the string form of values, comparison, numbers, field references, arguments, grammars and booleans in the output.
- The new error codes are listed in [Error codes](/validation-rules/error-codes.html#codes-2-5).

### New rules

- [Common rules](/validation-rules/common-rules.html): [`boolean`](/validation-rules/boolean.html), [`required_if`](/validation-rules/required_if.html), [`any`](/validation-rules/any.html).
- [String rules](/validation-rules/string-rules.html): [`not_one_of`](/validation-rules/not_one_of.html), [`digits`](/validation-rules/digits.html), [`starts_with`](/validation-rules/starts_with.html), [`ends_with`](/validation-rules/ends_with.html), [`contains`](/validation-rules/contains.html).
- [Numeric rules](/validation-rules/numeric-rules.html): [`max_decimals`](/validation-rules/max_decimals.html).
- [Special rules](/validation-rules/special-rules.html): [`iso_datetime`](/validation-rules/iso_datetime.html), [`iso_time`](/validation-rules/iso_time.html).
- [Metarules](/validation-rules/metarules.html): [`when`](/validation-rules/when.html), [`values`](/validation-rules/values.html), [`keys`](/validation-rules/keys.html).
- [List rules](/validation-rules/list-rules.html), a new group: [`list_length`](/validation-rules/list_length.html), [`unique`](/validation-rules/unique.html).
- [Format rules](/validation-rules/format-rules.html), a new group: [`uuid`](/validation-rules/uuid.html), [`ip`](/validation-rules/ip.html), [`cidr`](/validation-rules/cidr.html), [`hostname`](/validation-rules/hostname.html), [`base64`](/validation-rules/base64.html), [`hex`](/validation-rules/hex.html), [`digest`](/validation-rules/digest.html), [`mongo_id`](/validation-rules/mongo_id.html), [`hex_color`](/validation-rules/hex_color.html), [`mac`](/validation-rules/mac.html), [`e164`](/validation-rules/e164.html), [`semver`](/validation-rules/semver.html), [`jwt`](/validation-rules/jwt.html).
- [Checksum rules](/validation-rules/checksum-rules.html), a new group: [`luhn`](/validation-rules/luhn.html), [`credit_card`](/validation-rules/credit_card.html), [`iban`](/validation-rules/iban.html).
- [Modifiers](/validation-rules/modifiers.html): [`split`](/validation-rules/split.html).

### Extended `iso_date`

[`iso_date`](/validation-rules/iso_date.html#options-form) takes an options object with `min` and `max`. A bound is a date or one of `'today'`, `'yesterday'` and `'tomorrow'`, always in UTC; bounds give `DATE_TOO_EARLY` and `DATE_TOO_LATE`. The 2.0 forms `'iso_date'` and `{ iso_date: [] }` do not change; any other argument that is not an options object is a schema error. Dates with a time have their own rule, [`iso_datetime`](/validation-rules/iso_datetime.html), which returns the instant in UTC as `YYYY-MM-DDTHH:MM:SS.sssZ`.

### Reserved rule names

These rule names are now reserved: `boolean`, `not_one_of`, `max_decimals`, `digits`, `starts_with`, `ends_with`, `contains`, `iso_datetime`, `iso_time`, `required_if`, `when`, `keys`, `values`, `any`, `list_length`, `unique`, `split`, `uuid`, `ip`, `cidr`, `hostname`, `base64`, `hex`, `digest`, `mongo_id`, `hex_color`, `mac`, `e164`, `semver`, `jwt`, `luhn`, `credit_card`, `iban`.

A rule that the user registers with one of these names replaces the standard rule. So schemas that use `boolean`, `uuid` or `required_if` from [js-livr-extra-rules](https://github.com/koorchik/js-livr-extra-rules) keep working while the package is registered.

### Migration from js-livr-extra-rules

| extra-rules | LIVR 2.5 | What changes for the user |
|---|---|---|
| `boolean` | [`boolean`](/validation-rules/boolean.html) | `"true"` and `"false"` also pass |
| `credit_card` | [`credit_card`](/validation-rules/credit_card.html) | 12–19 digits instead of 14–16 |
| `list_length` | [`list_length`](/validation-rules/list_length.html) | Nothing; the `min` and `max` options are added |
| `list_items_unique` | [`unique`](/validation-rules/unique.html) | New name. `INCOMPARABLE_ITEMS` becomes `FORMAT_ERROR`. Keys for lists of objects |
| `required_if` | [`required_if`](/validation-rules/required_if.html) | Values are compared as strings (`==` before); a falsy value (`0`, `false`) no longer throws; a list of values means "any of" |
| `iso_date` with `min`, `max` | [`iso_date`](/validation-rules/iso_date.html#options-form) with `min`, `max` | `DATE_TOO_LOW` and `DATE_TOO_HIGH` become `DATE_TOO_EARLY` and `DATE_TOO_LATE`; `current` becomes `today` (`current` is a schema error); `today`, `yesterday` and `tomorrow` are in UTC, not in the server time zone; datetimes are rejected instead of truncated to a date |
| `iso_date` with `format: 'datetime'` | [`iso_datetime`](/validation-rules/iso_datetime.html) | New rule; a date without a time is rejected; bounds give `DATETIME_TOO_EARLY` and `DATETIME_TOO_LATE`; `current` becomes `today` |
| `uuid` (`NOT_UUID`), `{ uuid: 'v4' }` | [`uuid`](/validation-rules/uuid.html) (`WRONG_UUID`), `{ uuid: 'v4' }` | The default is any version (v4 before); the version and the variant are checked |
| `ipv4` (`NOT_IP`) | [`{ ip: 'v4' }`](/validation-rules/ip.html) (`WRONG_IP`) | New name and code |
| `base64` (`MALFORMED_BASE64`) | [`base64`](/validation-rules/base64.html) (`WRONG_BASE64`) | New code; `'relaxed'` is not in 2.5: keep the package registered or write an [alias](/rules-aliasing.html) with `like` |
| `md5` (`NOT_MD5`) | [`{ digest: 'md5' }`](/validation-rules/digest.html) (`WRONG_DIGEST`) | New name and code |
| `mongo_id` (`NOT_ID`) | [`mongo_id`](/validation-rules/mongo_id.html) (`WRONG_MONGO_ID`) | New code |
| `is` | `['required', { eq: ... }]` | Not in the specification |
| `instance_of`, `has_methods` | — | JavaScript only, they stay in the package |

While js-livr-extra-rules is registered, its rules replace the standard ones and nothing changes.

### Test suite

The 2.5 cases are a separate test suite in `test_suite_2.5/`, next to `test_suite/` and with the same layout (`positive`, `negative`, `aliases_positive`, `aliases_negative`) and files. It is a separate directory, because implementations copy `test_suite/` into their repositories and some of their runners read every directory in it.

- A case may have an `options.json`, `{ "now": "2026-10-18T12:00:00Z" }`, the current time for `today`, `yesterday` and `tomorrow`. The harness fixes the clock the way the tests of its implementation do; a harness that cannot fix it skips such cases.
- `schema_errors/` holds schemas that must not build: `rules.json`, and `aliases.json` when the error is in an alias. A case passes when building the validator (with the aliases registered) fails, however the implementation reports it.
- Checks that need to tell `{}` from `[]` (`values`, `keys`, `list_length` and `unique` on an empty object or list) are in their own cases, `positive/` and `negative/` `NN-object_or_list`. PHP and Lua decode both to the same value, so the conformance page does not count these cases for them, as in 2.0.
- A number in `output.json` is written the way it comes in the input (`10.0` gives `10.0`, `"5.000"` gives `5.000`), and objects in the cases have no keys `"0"`, `"1"`, …, because PHP and Lua cannot tell such an object from a list.
- The conformance page shows a separate 2.5 result for every implementation.

### Not in 2.5

- Changes of existing rules and of the engine: error params, string length in code points, the number grammar, the `email` and `url` grammars, I-Regexp for `like`, parent and root references, root rules, unknown field options for `nested_object`, meta keys (`$error`), recursive aliases.
- `not_null`, `default_if_missing` and `present`: the meaning of `null` for partial updates is decided in 3.0.
- `alpha`, `alphanumeric` and `normalize`: they need Unicode tables that some languages do not have.
- `not_like`: it depends on the `like` dialect that 3.0 replaces.
- `absent`: it is the same as `{ eq: '' }` (empty values pass, anything else fails), only the error code would differ. Use an [alias](/rules-aliasing.html) with `error` for a specific code.
- `multiple_of`: money is covered by [`max_decimals`](/validation-rules/max_decimals.html); packs and time slots are rare, and exact decimal arithmetic is a lot of work in every language.
- `tuple`: postponed to 3.0, where its argument form (positions as arguments or `{ items: [...] }`) is decided. For a list of fixed length, use `list_of` with [`list_length`](/validation-rules/list_length.html).
- `parse_json`: postponed. A safe parser needs a nesting limit that every language can enforce without crashing, and that limit is decided in 3.0.
- Rare rules or rules that other rules cover (`split`, `when`): `list_contains`, `iso_duration`, `isbn`, `gtin`, `ulid`, `max_byte_length`, `collapse_spaces`, `to_list`, `required_with`, `required_without`. For `ulid`, see the [alias recipe](/rules-aliasing.html#recipe-ulid).
- `country_code`, `currency_code` and `language_code`: use `one_of` with a list from a library.

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
