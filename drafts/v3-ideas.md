# LIVR 3: draft ideas

> Working notes for the next major version of the specification. This file is not a part of the
> specification and is not published on livr-spec.org (the site is built from `docs/` only).
> Everything here is a proposal: nothing is decided unless it is marked as decided.
>
> Started: 2026-10-18.

## Contents

1. [Goals](#1-goals)
2. [Principles for standard rules](#2-principles-for-standard-rules)
3. [Spec structure: Core and modules](#3-spec-structure-core-and-modules)
4. [Notation](#4-notation)
5. [What LIVR 2 cannot do today](#5-what-livr-2-cannot-do-today)
6. [Review of js-livr-extra-rules](#6-review-of-js-livr-extra-rules)
7. [New rules](#7-new-rules)
8. [New metarules and structural features](#8-new-metarules-and-structural-features)
9. [Errors](#9-errors)
10. [Other breaking changes](#10-other-breaking-changes)
11. [Rejected ideas](#11-rejected-ideas)
12. [Open questions](#12-open-questions)
13. [Suggested next steps](#13-suggested-next-steps)
- [Appendix A. Sources](#appendix-a-sources)

## 1. Goals

- A much larger standard rule set, so that common real-world schemas do not need custom rules.
- Every rule stays portable: it is described in JSON and behaves the same in all implementations
  (JS, Perl, PHP, Python, Go, Java, Ruby, Lua, Erlang, Raku, Swift...).
- Close the structural gaps: recursion, dictionaries, tuples, conditions, unknown fields, root
  values (see [section 5](#5-what-livr-2-cannot-do-today)).
- Errors with parameters, so that messages like "Must be at least {min} characters" are possible.
- Backward compatibility may be broken where it makes the spec simpler or more portable. Every
  breaking change must be listed in [section 10](#10-other-breaking-changes) and in the changelog.

What stays the same:

- Rules are data: a rule name and JSON arguments.
- Errors are codes, not messages; the error tree mirrors the data.
- Empty values (missing, `null`, `""`) are skipped by all rules except presence rules.
- Values from forms and query strings are coerced: `"25"` passes `positive_integer` and the output
  is `25`.
- Unknown fields are removed by default.
- Validation and modification happen in one pass; the output is the cleaned data.

## 2. Principles for standard rules

A rule gets into the specification if:

1. **It is data.** Name plus JSON arguments. No functions, classes or language types.
2. **It is deterministic.** The result does not depend on the language, OS, locale, time zone,
   network or installed packages. The only planned exception is `now`/`today` in date bounds, and
   implementations must let tests fix the clock.
3. **It has a precise definition.** An RFC, ISO standard, published algorithm or an exact grammar
   in the spec, so that a JSON test suite can pin the behavior, including edge cases.
4. **Its data is small.** Up to a few hundred entries that can live in the spec repository as JSON
   (for example ISO 3166-1 country codes). No per-country tables for phones, postal codes or tax
   IDs.
5. **It is common.** It exists in at least 2–3 popular validators, or it is asked for in LIVR
   issues.

A rule that fails 2–4 can still live in a community package or be an alias, but not in the spec.

## 3. Spec structure: Core and modules

With 12+ implementations, a single monolithic rule set will not be implemented fully. Proposal:

| Part | Content | Required |
|---|---|---|
| Core | LIVR 2 rules, new presence/condition rules, lists, objects, dates, `boolean`, `uuid`, error details | Yes, for "LIVR 3 compatible" |
| `formats` | `ip`, `cidr`, `hostname`, `mac`, `e164`, `base64`, `hex`, `hash`, `hex_color`, `semver`, `json`, `ulid`, `iso_duration` | Optional |
| `checksums` | `luhn`, `credit_card`, `iban`, `isbn`, `gtin` | Optional |
| `codes` | `country_code`, `currency_code`, `language_code` (with data files) | Optional |
| `text` | `starts_with`, `ends_with`, `contains`, `alpha`, `alphanumeric`, `max_bytes`, `normalize` | Optional |

- Each module has its own directory in `test_suite/` and its own column on the conformance page.
- An implementation declares which modules it supports. A module is all or nothing.
- The `text` module is separate because it needs Unicode tables (`\p{L}`, normalization) that some
  languages do not have out of the box (Lua; PHP without `intl`; Go without `x/text`).

## 4. Notation

Tiers: **Core**, or the name of a module from [section 3](#3-spec-structure-core-and-modules).

Sources (where a similar rule exists):

| Mark | Source | Mark | Source |
|---|---|---|---|
| X | js-livr-extra-rules | A | Ajv / JSON Schema (+ ajv-formats, ajv-keywords) |
| Z | Zod | L | Laravel validation |
| V | Valibot | G | go-playground/validator |
| J | Joi | VJ | validator.js |
| F | fastest-validator | | |

Versions that were reviewed are listed in [Appendix A](#appendix-a-sources).

## 5. What LIVR 2 cannot do today

Verified with js-validator-livr 2.11 on 2026-10-18. Every case is a candidate for a `test_suite`
case once the feature exists.

### 5.1 Recursive structures (#64)

Trees (categories, comments, menus, AND/OR filters) cannot be described: a recursive alias
overflows the stack while the validator is built.

```json
{ "tree": "node" }
```

Alias:

```json
{ "name": "node", "rules": { "nested_object": { "name": "string", "children": { "list_of": "node" } } } }
```

Result: `RangeError: Maximum call stack size exceeded`.

### 5.2 `or` silently loses data in untagged unions

```json
{ "p": { "or": [
  { "nested_object": { "a": "integer" } },
  { "nested_object": { "a": "integer", "b": "integer" } }
] } }
```

Input `{"p": {"a": 1, "b": 2}}` gives the output `{"p": {"a": 1}}`: the first branch matches and
strips `b`. There is no way to make a branch strict.

### 5.3 `or` reports only the last branch

`{"id": {"or": ["email", "positive_integer"]}}` with `{"id": "abc"}` gives
`{"id": "NOT_POSITIVE_INTEGER"}`. The error of the `email` branch is lost.

### 5.4 Envelope: the selector is outside the object

```json
{
  "type": { "one_of": ["card", "bank"] },
  "data": { "variable_object": ["type", {
    "card": { "number": "required" },
    "bank": { "iban": "required" }
  }] }
}
```

Input `{"type": "card", "data": {"number": "4111"}}` gives `{"data": "FORMAT_ERROR"}`:
`variable_object` reads the selector only inside `data`.

### 5.5 Duplicates in lists

`{"items": {"list_of_objects": {"id": ["required", "positive_integer"]}}}` accepts
`{"items": [{"id": 1}, {"id": 1}]}`. There is no uniqueness rule, and no length rules for lists
except `not_empty_list`.

### 5.6 Arbitrary JSON values

- `{"meta": []}` with `{"meta": {"a": 1}}` gives the output `{}`: the field disappears.
- `{"meta": "any_object"}` with `{"meta": 5}` gives `FORMAT_ERROR`.

There is no rule for "any JSON value, keep it as is".

### 5.7 `null` vs missing (PATCH semantics)

- `{"name": "string", "note": "string", "age": "integer"}` with
  `{"name": null, "note": "", "age": null}` passes and outputs the values as they are. This is
  correct for LIVR 2, but there is no way to forbid `null` without making the field required.
- `{"a": "not_empty"}` with `{"a": null}` passes.
- There is no "the key must be present, but `null` is allowed" rule (Laravel `present`).

The output already separates missing keys (absent in the output) from `null` (kept as `null`), so
only the rules are missing.

### 5.8 Root value is not an object (js-validator-livr#50)

`validate([1, 2])` gives the error `"FORMAT_ERROR"`. A list or a scalar at the root cannot be
validated. JS also returns `undefined` instead of `false` here (`lib/Validator.js:47` in
js-validator-livr), which is a JS bug, not a spec question.

### 5.9 String length depends on the implementation

`{"s": {"max_length": 1}}` with `{"s": "😀"}` gives `TOO_LONG` in JS (`"😀".length === 2`, UTF-16
code units). go-livr counts runes (`utf8.RuneCountInString`) and accepts it. Other languages
probably differ too (to verify with a conformance case):

| Language | Default length | Unit |
|---|---|---|
| JS, Java | `.length`, `String.length()` | UTF-16 code units |
| Go (go-livr), Python, Ruby, Perl (decoded strings) | | code points |
| PHP | `strlen` / `mb_strlen` | bytes / code points |
| Lua | `#s` / `utf8.len` | bytes / code points |
| Swift, Raku | `String.count`, `.chars` | grapheme clusters |

The spec does not say which unit is correct (see [10.1](#101-string-length-in-code-points)).

### 5.10 Booleans

`{"b": {"one_of": [true, false]}}` accepts `"true"`/`"false"` and outputs real booleans (values
are compared as strings and the output is the value from the rule). But `1`, `0`, `"1"`, `"0"` give
`NOT_ALLOWED_VALUE`, and the error code is not specific. There is no `boolean` rule (#22).

### 5.11 Unknown fields

`{"a": "string"}` with `{"a": "x", "b": "y"}` gives `{"a": "x"}`. Unknown fields can be neither
rejected (#17) nor kept (#70).

### 5.12 Other things that need custom rules today

- Conditional presence: "VAT number is required for companies", "email or phone" (#58).
- Dictionaries with arbitrary keys: `{"uk": "...", "en": "..."}`, `{"<sku>": <qty>}` (#56).
- Positional lists (tuples): `[lng, lat]`, `[from, to]`.
- "Exactly one default address", "at least one admin" in a list.
- Cross-level references: `item.currency == order.currency`, `primary_email ∈ emails`.
- Scalar-or-list inputs from query strings: `?id=5` vs `?id=5&id=6`.
- Date and time: datetime with offset (#19), time (#16), date bounds (#8), durations.
- Cross-field bounds: `end_date >= start_date`, `max_price >= min_price`.
- Error parameters for messages (#30, #31, js-validator-livr PR #7).

## 6. Review of js-livr-extra-rules

| Rule | Proposal | Changes needed |
|---|---|---|
| `boolean` | Core | The code accepts `"true"`/`"false"`, but the README says all strings except `"1"`/`"0"` give `NOT_BOOLEAN`. The spec must fix the exact set of accepted values (Q1) |
| `list_length` | Core | Keep `n` and `[min, max]`, add `min_items` / `max_items` for one-sided bounds |
| `list_items_unique` | Core, as `unique_items` | Add a key for lists of objects: `{"unique_items": "id"}` |
| `required_if` | Core | Bugs: a falsy target value (`0`, `false`, `""`) throws at build time; values are compared with `==`; the field path is resolved only inside the current object, so a parent field cannot be used; the error message says `require_if`. Add `required_with` and `required_without` |
| `iso_date` (with `min`/`max`/`format`) | Core, split | Split into `iso_datetime`, `iso_time`, `min_date`, `max_date`. The current output comes from JS `toISOString()`, and `yesterday`/`tomorrow` use the time zone of the server |
| `uuid` | Core | The `v1` and `v2` regexes check neither the version nor the variant, so `v1` accepts any UUID; `v3` does not check the variant. No v6–v8, nil, max (RFC 9562). The default is v4; it should be "any version" |
| `ipv4` | `formats`, as `ip` | `ip`, `{"ip": 4}`, `{"ip": 6}`; `cidr` as a separate rule |
| `base64` | `formats` | Add the URL-safe alphabet; error code `WRONG_BASE64` instead of `MALFORMED_BASE64` |
| `md5` | `formats`, as `hash` | `{"hash": "md5"}`, also `sha1`, `sha256`, `sha384`, `sha512` |
| `credit_card` | `checksums` | Extract `luhn` as its own rule (#63). The length check (14–16) rejects valid 12–13 and 17–19 digit numbers (ISO/IEC 7812 allows up to 19) |
| `mongo_id` | Standard alias | A 24-character hex string |
| `is` | Reject | The same as `["required", {"eq": value}]` |
| `instance_of`, `has_methods` | Reject | JS only. `has_methods` also puts a parameter into the error code (`NOT_HAVING_METHOD [bark]`) |

## 7. New rules

Each table lists the rule, tier, error code and sources. Details that the spec text must define are
listed under each table.

### 7.1 Types and numbers

| Rule | Tier | Error | Sources | Notes |
|---|---|---|---|---|
| `boolean` | Core | `NOT_BOOLEAN` | X Z V J F L G VJ | Output is a real boolean |
| `not_one_of` | Core | `NOT_ALLOWED_VALUE` | J L G V | Same comparison as `one_of` (as strings) |
| `multiple_of` | Core | `NOT_MULTIPLE_OF` | Z V J A L | `{"multiple_of": 0.01}` |
| `max_decimal_places` | Core | `TOO_MANY_DECIMALS` | J L VJ | `{"max_decimal_places": 2}`, for money |

Details:

- `boolean` accepted values (proposal): `true`, `false`, `1`, `0`, `"1"`, `"0"`, `"true"`,
  `"false"`. Open: `"on"`/`"off"` (the default value of an HTML checkbox is `on`), `"yes"`/`"no"`,
  case-insensitivity (Q1). Perl has no native boolean; the Perl implementation must output
  `JSON::PP::true`/`false` or the equivalent, which needs a conformance check.
- `multiple_of` uses decimal arithmetic on the decimal string forms, not floating point:
  `0.3` is a multiple of `0.1`. Non-numbers give `NOT_NUMBER`, like `min_number`.
- `max_decimal_places` counts digits after the decimal point in the string form of the value. For
  JSON numbers, the shortest round-trip representation is used. Open: do trailing zeros count
  (`"1.230"` has 3 or 2 places)?
- Safe integer range for `integer` and friends, see [10.6](#106-safe-integer-range).

### 7.2 Strings

| Rule | Tier | Error | Sources | Notes |
|---|---|---|---|---|
| `starts_with`, `ends_with`, `contains` | text | `WRONG_FORMAT` | Z V L G F | Argument is a string or a list of alternatives. Case-sensitive |
| `digits` | Core | `WRONG_FORMAT` | V L G | ASCII `0-9` only. Unlike `positive_integer`, keeps leading zeros and outputs a string (postal codes, OTP codes) |
| `alpha`, `alphanumeric` | text | `WRONG_FORMAT` | L G J F VJ | Unicode letters (`\p{L}` plus `\p{M}`, so that decomposed Cyrillic `й` passes). `{"alpha": "ascii"}` restricts to ASCII |
| `max_bytes` | text | `TOO_LONG` | V J VJ | Length in UTF-8 bytes: database column limits, HTTP headers |

- `lowercase` / `uppercase` checks are not needed: LIVR has the `to_lc` / `to_uc` modifiers.
- With I-Regexp `\p{..}` support, `alpha` could also be a standard alias over `like` (Q8).

### 7.3 Dates and times

| Rule | Tier | Error | Sources | Notes |
|---|---|---|---|---|
| `iso_datetime` | Core | `WRONG_DATETIME` | Z V J A VJ, #19 | RFC 3339 `date-time`, offset required. Output is the input string unchanged |
| `iso_time` | Core | `WRONG_TIME` | Z V A VJ, #16 | `HH:MM`, `HH:MM:SS`, `HH:MM:SS.fff`, no offset (what `<input type=time>` sends) |
| `min_date`, `max_date` | Core | `TOO_EARLY`, `TOO_LATE` | X J Z L A VJ, #8 | Bound is a date, a datetime, `"today"`, `"now"` or `{"field": ...}` |
| `iso_duration` | formats | `WRONG_DURATION` | Z J A | ISO 8601 duration as in RFC 3339 Appendix A: `P1DT2H`, `PT30M`, `P2W` |

Details the spec must define:

- `iso_date` (LIVR 2) stays: `YYYY-MM-DD`, a valid calendar date.
- `iso_datetime` exact grammar: `T` separator (case?), seconds required or optional, fraction
  digits limit, leap second `23:59:60` accepted or not. Open: a `local` variant without offset for
  `<input type=datetime-local>` (Q6).
- Comparison in `min_date`/`max_date`:
  - date vs date: calendar dates;
  - datetime vs datetime: instants;
  - datetime value vs date bound: the calendar date of the value in its own offset, never the
    server time zone;
  - date value vs datetime bound: the calendar date of the bound in its own offset.
- A value that is not a date or datetime gives `WRONG_DATE`.
- `"today"` is the current date in UTC, `"now"` is the current instant (Q5). Implementations must
  allow a fixed clock. The test suite gets an optional `options.json` with
  `{"now": "2026-10-18T12:00:00Z"}` for such cases.
- Error params contain the resolved bound: `{"min": "2026-10-18"}` for `"today"`.
- Maybe also `date_between: [min, max]`, like `number_between`.

### 7.4 Presence and conditions

| Rule | Tier | Error | Sources | Example |
|---|---|---|---|---|
| `required_if` | Core | `REQUIRED` | X L G | `{"required_if": {"type": "company"}}`, `{"required_if": {"type": ["company", "ngo"]}}` |
| `required_with` | Core | `REQUIRED` | L G J A | `{"required_with": "password"}` or a list: required if any of the fields is not empty |
| `required_without` | Core | `REQUIRED` | L G J | `email: {"required_without": "phone"}`, `phone: {"required_without": "email"}` = "email or phone" |
| `absent` | Core | `FIELD_NOT_ALLOWED` | L J F G, #54 | The value must be empty (missing, `null` or `""`) |
| `present` | Core | `REQUIRED` | L | The key must exist; `null` and `""` are allowed |
| `not_null` | Core | `CANNOT_BE_NULL` | Z V (nullable) | The key may be missing, but not `null`. Alternative: `not_empty` rejects `null` (Q7) |
| `when` | Core (metarule) | errors of the branch | J A L | See [8.3](#83-when) |

Details:

- Field names in these rules use the reference syntax from [8.2](#82-field-references).
- `required_if` with several fields means AND; a list of values means "any of". Values are compared
  as strings, like `eq` and `one_of`.
- Error params: `{"field": "type"}` for the conditional `REQUIRED`.
- `absent`: does an empty value stay in the output (`null` stays `null`) or is it removed? Proposal:
  removed.
- Not proposed as separate rules, because `when` covers them: `required_unless`,
  `required_with_all`, `required_without_all`, `prohibited_if`, `prohibits`, `conflict_with` (#25).

### 7.5 Lists

| Rule | Tier | Error | Sources | Example |
|---|---|---|---|---|
| `list_length` | Core | `TOO_FEW_ITEMS`, `TOO_MANY_ITEMS` | X Z V J A F L G | `{"list_length": 3}`, `{"list_length": [1, 5]}` |
| `min_items`, `max_items` | Core | `TOO_FEW_ITEMS`, `TOO_MANY_ITEMS` | same | `{"max_items": 10}` |
| `unique_items` | Core | `NOT_UNIQUE_ITEMS` | X Z J A F L G | `"unique_items"`, `{"unique_items": "id"}`, `{"unique_items": ["country", "zip"]}` |
| `list_contains` | Core (metarule) | `TOO_FEW_MATCHING_ITEMS`, `TOO_MANY_MATCHING_ITEMS` | A J | See [8.7](#87-list_contains) |
| `tuple` | Core (metarule) | per position | Z V J A F | See [8.6](#86-tuple) |

Details:

- Non-lists give `FORMAT_ERROR`.
- `unique_items` compares primitive items as strings (`1` and `"1"` are equal, consistent with
  `eq`/`one_of`). With a key, items are compared by the key values; items with an empty key value
  are ignored. Objects without a key give `FORMAT_ERROR` (extra-rules has a separate
  `INCOMPARABLE_ITEMS` code; one code is enough).
- `unique_items` error: one code for the whole field, with `{"index": 3, "duplicate_of": 1}` in the
  error details. Alternative: a list of errors with `NOT_UNIQUE` at the duplicate positions, so that
  a UI can highlight the row (Joi puts the error at the duplicate position). Open (Q11).
- Alternative design: make `min_length`/`max_length` polymorphic (strings and lists), like Laravel
  `size`. Rejected for now: it changes `FORMAT_ERROR` behavior and mixes `TOO_SHORT` with
  `TOO_FEW_ITEMS`.

### 7.6 Objects

| Rule | Tier | Error | Sources | Notes |
|---|---|---|---|---|
| `dict_of` | Core (metarule) | `WRONG_KEY` + errors of values | Z V J A F G, #56 | See [8.4](#84-dict_of) |
| `nested_object` options | Core | `FIELD_NOT_ALLOWED` | Z V J A F, #17, #70 | `unknown: strip/error/keep`, `rest`. See [8.5](#85-unknown-fields-policy) |
| `any` | Core | none | Z A F | Any JSON value, output unchanged. See [8.9](#89-any) |

Maybe later: `min_fields` / `max_fields` for objects (Ajv `minProperties`, Joi `object.min`).

### 7.7 Formats (`formats` module)

| Rule | Error | Sources | Definition |
|---|---|---|---|
| `uuid` (Core) | `WRONG_UUID` | X Z J F L G VJ | RFC 9562: versions 1–8 with the RFC variant, plus nil and max. `{"uuid": 7}`, `{"uuid": [4, 7]}`. Case-insensitive |
| `ip` | `WRONG_IP` | X Z V J A L G VJ | `ip`, `{"ip": 4}`, `{"ip": 6}`. IPv4 dotted decimal without leading zeros (`010.0.0.1` is ambiguous and caused CVEs). IPv6 text forms of RFC 4291, including embedded IPv4, without zone IDs |
| `cidr` | `WRONG_CIDR` | Z V A G VJ | `cidr`, `{"cidr": 4}`, `{"cidr": 6}` |
| `hostname` | `WRONG_HOSTNAME` | Z V J A G VJ | RFC 1123: labels 1–63 characters of letters, digits and `-`, not starting or ending with `-`, total ≤ 253. No TLD list. IDN only as punycode |
| `mac` | `WRONG_MAC` | Z V F L G VJ | 48-bit, six hex pairs separated consistently by `:` or `-` |
| `e164` | `WRONG_PHONE` | Z G | `^\+[1-9][0-9]{6,14}$` (Zod). go-validator uses `^\+?[1-9]\d{7,14}$`: same name, different behavior, which is why the spec must pin the grammar |
| `base64` | `WRONG_BASE64` | X Z V J F G VJ | `base64`: RFC 4648 section 4, padding required. `{"base64": "url"}`: section 5, padding optional. No whitespace |
| `hex` | `WRONG_FORMAT` | Z V G VJ | `[0-9a-fA-F]+` |
| `hash` | `WRONG_HASH` | X Z V G VJ | `{"hash": "sha256"}`: hex string of the exact length (md5 32, sha1 40, sha256 64, sha384 96, sha512 128) |
| `hex_color` | `WRONG_COLOR` | V L G VJ | `#` plus 3, 4, 6 or 8 hex digits |
| `semver` | `WRONG_SEMVER` | G VJ | The official regex from semver.org 2.0.0, no `v` prefix |
| `json` | `WRONG_JSON` | V L G VJ | A string that parses as RFC 8259 JSON (any top-level value) |
| `parse_json` | `WRONG_JSON` | V | Like `json`, but the output is the parsed value, so the next rules can check it: `["parse_json", {"nested_object": {...}}]` (a JSON field in multipart forms) |
| `ulid` | `WRONG_ULID` | Z V L G VJ | 26 characters of Crockford base32, the first one is `0`–`7` |
| `iso_duration` | `WRONG_DURATION` | Z J A | See [7.3](#73-dates-and-times) |

Changes to LIVR 2 format rules:

- **`email`**: define it as the WHATWG HTML "valid e-mail address" grammar, plus at least one dot in
  the domain, plus at most 254 characters. Then the server and `<input type=email>` accept the same
  addresses. The same grammar exists in Zod (`html5Email`) and Valibot (`rfcEmail`). Breaking:
  quoted local parts and IP-literal domains, which the JS regex accepts today, are rejected.
  See js-validator-livr#28.
- **`url`**: allow a list of schemes, `{"url": ["http", "https", "ftp"]}`, defaults to `http` and
  `https`. Pin the grammar in the spec and add `https://www.google.` (js-validator-livr#56) to the
  negative cases. Do not reference the WHATWG URL parser (Zod, Valibot): other languages do not
  have it.

### 7.8 Checksums (`checksums` module)

| Rule | Error | Sources | Definition |
|---|---|---|---|
| `luhn` | `WRONG_CHECKSUM` | F VJ, #63 | ASCII digits, at least 2, Luhn mod 10 |
| `credit_card` | `WRONG_CREDIT_CARD_NUMBER` | X Z V F L VJ | 12–19 ASCII digits plus Luhn. No card network detection: BIN ranges change |
| `iban` | `WRONG_IBAN` | Z V VJ | 2 letters, 2 digits, 11–30 alphanumerics (15–34 total), uppercase, ISO 13616 mod-97 = 1. No per-country length table (maybe an option later, the table has about 90 entries) |
| `isbn` | `WRONG_ISBN` | V G VJ | ISBN-10 (check character may be `X`) and ISBN-13 (`978`/`979`), no hyphens. `{"isbn": 10}`, `{"isbn": 13}` |
| `gtin` | `WRONG_GTIN` | V G VJ | GTIN-8, -12 (UPC), -13 (EAN), -14 with the GS1 mod-10 check digit |

Values are not normalized by these rules. Use modifiers before them:
`[{"remove": " -"}, "to_uc", "iban"]`.

### 7.9 Codes (`codes` module)

| Rule | Error | Sources | Data |
|---|---|---|---|
| `country_code` | `NOT_ALLOWED_VALUE` | Z G VJ | ISO 3166-1, 249 entries. `"country_code"` (alpha-2), `{"country_code": "alpha3"}`, `{"country_code": "numeric"}` |
| `currency_code` | `NOT_ALLOWED_VALUE` | Z G VJ | ISO 4217 active codes, about 180 entries |
| `language_code` | `NOT_ALLOWED_VALUE` | G VJ | ISO 639-1, 184 entries |

- Codes are uppercase (countries, currencies) or lowercase (languages), exactly as in the
  standard. Use `to_uc`/`to_lc` before for case-insensitive input.
- The lists live in the spec repository as versioned JSON files (`data/iso3166-1.json`...). An
  implementation must use the lists of the spec release it claims; list updates go through spec
  releases. Otherwise implementations drift after the first list change. Zod already embeds
  ISO 4217.
- Open: a specific error code (`WRONG_COUNTRY_CODE`) instead of `NOT_ALLOWED_VALUE`.
- Maybe later: `language_tag` (BCP 47 / RFC 5646 syntax only, no registry check).

### 7.10 Modifiers

| Modifier | Tier | Sources | Notes |
|---|---|---|---|
| `to_list` | Core | J F A | `"5"` → `["5"]`, a list stays a list. For query strings: `?id=5` vs `?id=5&id=6` |
| `normalize` | text | Z J V | Unicode normalization: `"normalize"` (NFC) or `{"normalize": "NFKC"}` |
| `collapse_spaces` | Core? | none (idea) | Replaces runs of whitespace with one space and trims. The whitespace set must be listed explicitly: `\s` differs between regex engines |
| `split` | Core? | none (idea) | `{"split": ","}`: `"a,b,c"` → `["a", "b", "c"]` |

### 7.11 Standard aliases

These need no new code. The spec can ship them as a JSON file with its own tests ("LIVR galaxy"
from #57). They need a portable `like` ([10.2](#102-like-and-portable-regular-expressions)) and
`digits`/`luhn` where used.

```json
[
  { "name": "port", "rules": ["integer", { "number_between": [1, 65535] }] },
  { "name": "latitude", "rules": ["decimal", { "number_between": [-90, 90] }] },
  { "name": "longitude", "rules": ["decimal", { "number_between": [-180, 180] }] },
  { "name": "non_negative_integer", "rules": ["integer", { "min_number": 0 }] },
  { "name": "percent", "rules": ["decimal", { "number_between": [0, 100] }] },
  { "name": "object_id", "rules": { "like": "[0-9a-fA-F]{24}" } },
  { "name": "slug", "rules": { "like": "[a-z0-9]+(-[a-z0-9]+)*" } },
  { "name": "nanoid", "rules": { "like": "[A-Za-z0-9_-]{21}" } },
  { "name": "imei", "rules": ["digits", { "length_equal": 15 }, "luhn"] }
]
```

The `like` patterns are written in I-Regexp, which always matches the whole string (see
[10.2](#102-like-and-portable-regular-expressions)). Open: `port` 0–65535 or 1–65535; should every
alias have its own error code (`"error": "WRONG_PORT"`)?

Parameterized aliases (#57) would make this much more useful, for example `money(max)`. Syntax not
designed yet (Q9).

## 8. New metarules and structural features

Summary:

| Structure | LIVR 2 | Proposal |
|---|---|---|
| Trees | Stack overflow ([5.1](#51-recursive-structures-64)) | Recursive aliases ([8.1](#81-recursive-aliases)) |
| Cross-level references | Rules see only their own level | Field reference syntax ([8.2](#82-field-references)) |
| Conditional rules, envelopes | Custom rules ([5.4](#54-envelope-the-selector-is-outside-the-object)) | `when` ([8.3](#83-when)) |
| Dictionaries | `any_object` without checks | `dict_of` ([8.4](#84-dict_of)) |
| Strict objects, known fields plus rest | Unknown fields are removed ([5.11](#511-unknown-fields)) | `unknown` and `rest` options ([8.5](#85-unknown-fields-policy)) |
| Tuples | Impossible | `tuple` ([8.6](#86-tuple)) |
| "Exactly one default item" | Impossible | `list_contains` ([8.7](#87-list_contains)) |
| Shared fields of variants | Repeated in every variant | `variable_object` with `common` ([8.8](#88-variable_object-with-shared-fields)) |
| Any JSON value | Dropped ([5.6](#56-arbitrary-json-values)) | `any` ([8.9](#89-any)) |
| Root list or scalar | `FORMAT_ERROR` ([5.8](#58-root-value-is-not-an-object-js-validator-livr50)) | Root rules ([8.10](#810-root-rules)) |
| Untagged unions | Data loss ([5.2](#52-or-silently-loses-data-in-untagged-unions)) | Strict branches, defined `or` ([8.11](#811-or-defined-semantics)) |
| Scalar or list | `or` | `to_list` ([7.10](#710-modifiers)) |
| Unique key in a list of objects | Duplicates pass ([5.5](#55-duplicates-in-lists)) | `unique_items` with a key ([7.5](#75-lists)) |
| PATCH (`null` vs missing) | `null` passes everything except `required` ([5.7](#57-null-vs-missing-patch-semantics)) | `present`, `not_null` ([7.4](#74-presence-and-conditions)) |

### 8.1 Recursive aliases

```json
{
  "name": "category",
  "rules": { "nested_object": {
    "title": ["required", "string"],
    "children": { "list_of": "category" }
  } }
}
```

- Alias bodies are resolved lazily, on first use. An alias may reference itself or an alias that
  is registered later.
- Implementations must not expand aliases eagerly at build time (that is what overflows now).
- Depth limit: an implementation option with a documented default (for example 100), so that
  untrusted input cannot exhaust the stack. Open: is exceeding it a validation error
  (`TOO_DEEP`) or an exception?
- Similar: Joi `link`, Zod `lazy`, JSON Schema `$ref`.

### 8.2 Field references

Several rules refer to other fields: `equal_to_field`, `required_if`, `required_with`,
`required_without`, `when`, `min_date`, `max_date`, and bounds given as `{"field": ...}`. One syntax
for all of them:

| Reference | Meaning |
|---|---|
| `"name"` | Field of the same object (as `equal_to_field` today) |
| `"a/b"` | Nested field, relative to the current object |
| `"/a/b"` | Absolute path from the root of the input (RFC 6901 JSON Pointer) |
| `"../a"` | Field of the parent (open, see below) |

- `~0` and `~1` escape `~` and `/`, as in JSON Pointer. Breaking: a field name that contains `/`
  must be escaped in references.
- A bound may be a reference wherever a bound value is expected, like Ajv `$data`:
  `{"max_number": {"field": "balance"}}`, `{"min_date": {"field": "start_date"}}`,
  `{"one_of": {"field": "/emails"}}` (Laravel `in_array`, `Joi.in`).
- If the referenced value is empty or has a wrong type, the rule passes: the referenced field
  reports its own error.
- References see the input values after `auto_trim` but before the rules of the referenced field.
  Open: should they see the output of the referenced field instead (for example after `to_lc`)?
- Parent references: `"/currency"` covers "item currency equals order currency" when the order is
  the root. For lists in lists (`orders[i].items[j]` vs `orders[i]`) a relative step up is needed.
  Options: `..` segments (does a list count as a level?), or relative JSON pointers like Ajv
  (`"1/currency"`). Joi has sibling, ancestor (`...`) and root (`/`) references.
- Implementation impact: rules that take references need the root input and the current path. This
  changes the internal rule API in every implementation (an extra context argument), but not the
  JSON schemas.

### 8.3 `when`

Condition form:

```json
{
  "vat_number": { "when": {
    "field": "type",
    "is": { "eq": "company" },
    "then": ["required", { "like": "[A-Z]{2}[0-9]{8,12}" }],
    "else": "absent"
  } }
}
```

Switch form, which also solves the envelope ([5.4](#54-envelope-the-selector-is-outside-the-object)):

```json
{
  "type": ["required", { "one_of": ["card", "bank"] }],
  "data": ["required", { "when": {
    "field": "type",
    "cases": {
      "card": { "nested_object": { "number": ["required", "credit_card"] } },
      "bank": { "nested_object": { "iban": ["required", "iban"] } }
    }
  } }]
}
```

Semantics:

- The condition is true only if the referenced field is **not empty** and passes the `is` rules.
  Without this, `{"is": {"eq": "x"}}` would be true for an empty field, because rules skip empty
  values. Joi avoids the same trap by adding `required` to `is` automatically.
- Without `is`, the condition is "the referenced field is not empty".
- `cases` keys are compared with the referenced value as strings, like `variable_object`.
- `then`, `else` and the cases are ordinary rule lists. A missing branch means no rules. Open:
  should a missing branch keep the value (like `any`) or drop it (like a field with no rules)?
- `when` covers: `required_unless`, `prohibited_if`, `conflict_with` (#25), "all or nothing",
  "exactly one of" (with `absent`).
- Errors of the chosen branch are reported as usual, on the field itself. No object-level errors
  are needed.

### 8.4 `dict_of`

```json
{
  "translations": { "dict_of": {
    "keys": { "one_of": ["uk", "en", "de"] },
    "values": ["required", "string", { "max_length": 200 }]
  } },
  "stock": { "dict_of": { "values": ["required", "positive_integer"] } }
}
```

- Short form: `{"dict_of": "string"}` means rules for values only.
- Value errors are reported under their keys: `{"stock": {"sku-1": "NOT_POSITIVE_INTEGER"}}`.
- An invalid key gives `WRONG_KEY` under that key. Its original error code (for example `TOO_LONG`)
  goes to the error details as `params.key_error`.
- Open: may key rules modify keys (`to_lc`)? Then two keys can collide. Proposal: key rules only
  check, their output is ignored.
- Non-objects give `FORMAT_ERROR`. An empty object passes (use `not_empty` semantics for objects?
  Open).
- Similar: Zod and Valibot `record`, Joi `object.pattern`, Ajv `propertyNames` +
  `additionalProperties`, fastest-validator `record`, go-validator `dive,keys`.

### 8.5 Unknown fields policy

```json
{ "user": { "nested_object": [{ "id": "required" }, { "unknown": "error" }] } }
{ "event": { "nested_object": [{ "type": "required" }, { "rest": "string" }] } }
```

- `"unknown": "strip"` (default, LIVR 2 behavior), `"error"` (each unknown key gets
  `FIELD_NOT_ALLOWED`), `"keep"` (copied to the output unchanged).
- `"rest": rules`: unknown keys are kept and validated with these rules (Valibot `objectWithRest`,
  Zod `catchall`, Ajv `additionalProperties` with a schema).
- `FIELD_NOT_ALLOWED` per key is more precise than one `unrecognized_keys` error with a key list
  (Zod) and fits the LIVR error tree. Valibot `strictObject` also reports one issue per key.
- The root object uses the same options through root rules ([8.10](#810-root-rules)) or a validator
  option. This closes #17 and #70.
- The same options for `variable_object`, `list_of_objects`, `list_of_different_objects`.

### 8.6 `tuple`

```json
{ "location": { "tuple": [["required", "decimal"], ["required", "decimal"]] } }
```

- One rule list per position. Errors are a list, like `list_of`: `[null, "NOT_DECIMAL"]`.
- A shorter list is validated as if the missing positions were empty, so `required` catches them.
- A longer list gives `TOO_MANY_ITEMS` for the whole field. Open: a `rest` option for extra items.
- Similar: Zod and Valibot `tuple`, Joi `array.ordered`, Ajv `prefixItems`, fastest-validator
  `tuple`.

### 8.7 `list_contains`

```json
{
  "addresses": [
    "not_empty_list",
    { "list_of_objects": { "city": "required", "is_default": "boolean" } },
    { "list_contains": {
      "rules": { "nested_object": { "is_default": ["required", { "eq": true }] } },
      "min": 1,
      "max": 1
    } }
  ]
}
```

- Counts the items that pass `rules`. `min` defaults to 1, `max` to no limit.
- Only checks, never changes the output (the inner `nested_object` does not strip fields).
- Errors: `TOO_FEW_MATCHING_ITEMS` / `TOO_MANY_MATCHING_ITEMS` with `{"min"}` / `{"max"}`.
  Names are open.
- Similar: Ajv `contains` with `minContains`/`maxContains`, Joi `array.has`.

### 8.8 `variable_object` with shared fields

In LIVR 2 shared fields must be repeated in every variant (like `product_type` in the spec
example). Proposal: an object form.

```json
{ "payment": { "variable_object": {
  "selector": "type",
  "common": { "amount": ["required", "positive_decimal"] },
  "variants": {
    "card": { "number": ["required", "credit_card"] },
    "bank": { "iban": ["required", "iban"] }
  }
} } }
```

Alternative: a generic `all_of` that merges object outputs (Joi `match: "all"`, Ajv `allOf`, Zod
`intersection`). It is harder to define, because every `nested_object` strips the fields of the
others.

### 8.9 `any`

`"metadata": "any"` accepts any JSON value, including objects and lists, and copies it to the
output unchanged. Useful on its own, in `when` branches and as `dict_of` values. Similar: Zod
`json`, `true` as a JSON Schema, fastest-validator `any`.

### 8.10 Root rules

Validation of a value that is not an object (js-validator-livr#50): a list of objects in a bulk
API, a scalar, or the root object with `unknown: "error"`.

- API: a separate constructor or an option, for example
  `Validator.forRule({"list_of_objects": {...}})`. The errors are what the rule returns: a string or
  a list.
- Test suite: separate directories (`root_positive`, `root_negative`) where `rules.json` is a single
  rule, not an object of fields.
- Alternative: a reserved key like `{"$root": ...}` (fastest-validator `$$root`). Rejected for now,
  because LIVR field names can be anything.

### 8.11 `or`: defined semantics

- Remove the "experimental" status.
- The spec states that branches are tried in order and the first passing branch wins, including its
  output.
- Strict branches (`unknown: "error"`) make untagged unions safe:
  `{"or": [{"nested_object": [{"a": "integer"}, {"unknown": "error"}]}, ...]}`.
- Errors: the tree keeps the errors of the last branch (LIVR 2). The error details get the errors of
  all branches, for example `params.branches` (Zod `invalid_union.errors`). Alternative from Zod: if
  only one branch passed the type check, report the errors of that branch. Open.

### 8.12 Out of scope: expressions

"The sum of percentages is 100", "total equals the sum of item prices", "end - start <= 30 days".
These need an expression language (Joi `x`, JSON Logic). It is a big spec on its own and risky for
schemas from untrusted sources. Such checks stay custom rules.

## 9. Errors

### 9.1 How other validators report errors

| Validator | Shape | Codes | Params | Path |
|---|---|---|---|---|
| Zod | Flat list; `treeifyError` builds a tree | About 11 generic (`too_small` with `origin`) | `minimum`, `maximum`, `inclusive`, `format`, `pattern`, `values`, `keys`, `divisor` | List of keys |
| Valibot | Flat list | Action name (`min_length`) | `requirement`; `expected` and `received` as strings | List of path items |
| Joi | `details` list | About 100 (`string.min`) | `context`: `limit`, `value`, `label`, `key` | List of keys |
| fastest-validator | List | `stringMin` | `expected`, `actual` | String `a.b[0]` |
| Ajv | List | Keyword | `params` (`limit`, `missingProperty`, `allowedValues`...) | JSON Pointer (`instancePath`) |
| Laravel | Object: path → list of messages | Rule name | Message placeholders | Dot path `users.0.email` |
| go-playground/validator | List of `FieldError` | Tag | `Param()` | `Namespace()` |
| LIVR 2 | Tree that mirrors the data | 18 domain codes | None | The tree itself |

### 9.2 What to take

1. **Params.** Every validator above has them, LIVR does not (#30, #31, js-validator-livr PR #7).
   Even the i18n example in js-validator-livr `docs/DESIGN.md` (`"Must be at least {min}
   characters"`) cannot be implemented today: there is no `min` to take.
2. **Path as a JSON Pointer** (Ajv `instancePath`, RFC 6901). It does not depend on the language.
   The example in RFC 9457 (Problem Details for HTTP APIs) uses a `pointer` member in `errors`.
3. **Both views**, like Zod: a tree for forms, a flat list for APIs and logs.
4. **No input values in errors.** Joi (`context.value`) and fastest-validator (`actual`) put them
   there, and passwords end up in logs.
5. **Errors of every `or` branch** (Zod `invalid_union.errors`) and the **duplicate index** (Joi
   `dupePos`, Ajv `{i, j}`).

### 9.3 Proposal: error details

The tree stays as it is. A new, flat list of error details is added:

```js
validator.getErrors()
// { password: 'TOO_SHORT', tags: [null, 'TOO_LONG'] }

validator.getErrorDetails()
// [
//   { path: '/password', code: 'TOO_SHORT', rule: 'min_length', params: { min: 10 } },
//   { path: '/tags/1',   code: 'TOO_LONG',  rule: 'max_length', params: { max: 20 } }
// ]
```

- `path`: JSON Pointer into the input. The root is `""`.
- `code`: the same code as in the tree.
- `rule`: the rule name as written in the schema, in snake_case. For an alias with `error`, the
  alias name.
- `params`: an object, possibly empty, with the standard names from [9.4](#94-standard-params).
- Order is unspecified: Perl hashes and some other maps do not keep the key order. The test suite
  compares the details as a set.
- An alias with `error` replaces the code; `params` is empty. Open: keep the original error as
  `params.cause`.
- How a rule returns params is an implementation detail. In JS it should be a dedicated type (for
  example an `ErrorDetail` class), not a plain `{code, params}` object: a nested object error may
  contain a field named `code`. The spec defines only the result.
- Method names follow each language's conventions; the spec defines the data.

Rejected alternative: `{code, params}` objects as tree leaves. It breaks every consumer of the tree,
and such a leaf cannot be told apart from the errors of a nested object with fields `code` and
`params`.

### 9.4 Standard params

The same name for the same meaning, so that one translation template works for strings, numbers,
lists and dates:

| Code | Rules | Params |
|---|---|---|
| `REQUIRED` | `required`, `present` | none |
| `REQUIRED` | `required_if`, `required_with`, `required_without` | `field` |
| `CANNOT_BE_EMPTY` | `not_empty`, `not_empty_list` | none |
| `FORMAT_ERROR` | many | maybe `expected`: `"string"`, `"object"`, `"list"` (open) |
| `NOT_ALLOWED_VALUE` | `eq`, `one_of`, codes module | `allowed` (a list; for `eq` a list of one) |
| `NOT_ALLOWED_VALUE` | `not_one_of` | `forbidden` |
| `TOO_SHORT`, `TOO_LONG` | length rules, `max_bytes` | `min`, `max` |
| `TOO_LOW`, `TOO_HIGH` | number rules | `min`, `max` |
| `TOO_EARLY`, `TOO_LATE` | `min_date`, `max_date` | `min`, `max` (resolved bound) |
| `TOO_FEW_ITEMS`, `TOO_MANY_ITEMS` | list length rules, `tuple` | `min`, `max` |
| `TOO_FEW_MATCHING_ITEMS`, `TOO_MANY_MATCHING_ITEMS` | `list_contains` | `min`, `max` |
| `NOT_UNIQUE_ITEMS` | `unique_items` | `index`, `duplicate_of` |
| `NOT_MULTIPLE_OF` | `multiple_of` | `divisor` |
| `TOO_MANY_DECIMALS` | `max_decimal_places` | `max` |
| `FIELDS_NOT_EQUAL` | `equal_to_field` | `field` |
| `WRONG_FORMAT` | `like` | `pattern` |
| `WRONG_FORMAT` | `starts_with`, `ends_with`, `contains` | `prefix`, `suffix`, `substring` |
| `FIELD_NOT_ALLOWED` | `absent`, `unknown: "error"` | none |
| `WRONG_KEY` | `dict_of` | `key_error` |
| `WRONG_<FORMAT>` | format rules | none, or the option (`version` for `uuid`) |

Maybe later: exclusive bounds (`greater_than`, `less_than`; Zod `gt`/`lt`, JSON Schema
`exclusiveMinimum`). Then the bound params need an `inclusive` flag, like in Zod.

### 9.5 Error code naming

- A wrong type: `NOT_<TYPE>` (`NOT_INTEGER`, `NOT_BOOLEAN`).
- A wrong format: `WRONG_<FORMAT>` (`WRONG_EMAIL`, `WRONG_UUID`).
- A bound: `TOO_*` (`TOO_LONG`, `TOO_EARLY`, `TOO_MANY_ITEMS`).
- No parameters inside codes (not `NOT_HAVING_METHOD [bark]`).
- Existing LIVR 2 codes are not renamed: that would break every translation file for cosmetics.
- Codes from js-livr-extra-rules that move into the spec are renamed:

| extra-rules | LIVR 3 |
|---|---|
| `NOT_UUID` | `WRONG_UUID` |
| `NOT_IP` | `WRONG_IP` |
| `MALFORMED_BASE64` | `WRONG_BASE64` |
| `NOT_MD5` | `WRONG_HASH` |
| `NOT_ID` (`mongo_id`) | alias, `WRONG_FORMAT` or its own code |
| `DATE_TOO_LOW`, `DATE_TOO_HIGH` | `TOO_EARLY`, `TOO_LATE` |
| `INCOMPARABLE_ITEMS` | `FORMAT_ERROR` |

### 9.6 Test suite

- Negative cases get an optional `error_details.json`. Implementations without error details skip
  it.
- The details are compared as a set (sorted by `path`, then `code`).
- A new category for schema errors (see [10.4](#104-schema-errors-at-build-time)): a schema and the
  expectation that building the validator fails.

## 10. Other breaking changes

### 10.1 String length in code points

`min_length`, `max_length`, `length_between`, `length_equal` count Unicode code points.

- Breaks JS and Java (UTF-16 code units) for characters outside the BMP (emoji, some CJK), and
  Swift and Raku if they count grapheme clusters (to verify, [5.9](#59-string-length-depends-on-the-implementation)).
- Matches Ajv (`ucs2length`), go-validator, validator.js `isLength`, Laravel, Python, Go.
- Graphemes are rejected: they need ICU or `Intl.Segmenter`, and the result depends on the
  Unicode version.
- Add test cases with `😀` (one code point, two UTF-16 units) and `é` written as `e` plus a
  combining accent (two code points, one grapheme).

### 10.2 `like` and portable regular expressions

LIVR 2 marks `like` as experimental: regex dialects differ (conformance notes show problems in Raku
and Swift). Candidate: I-Regexp (RFC 9485), designed exactly for interoperable regexes and used by
JSONPath (RFC 9535). But I-Regexp is much stricter than what LIVR schemas use today:

- No anchors `^` and `$`. An I-Regexp always matches the **whole** string (JSONPath `match()`);
  substring search is a separate function (JSONPath `search()`).
- No multi-character escapes: `\d`, `\w`, `\s` must be written as `[0-9]` and so on.
- No flags (LIVR `like` supports `i` today).
- No groups for capture, lookarounds, backreferences or lazy quantifiers.
- `\p{..}` Unicode categories are supported. `.` follows XSD rules (does not match `\n`, `\r`).

Options:

1. **I-Regexp, whole-string match.** Pure standard. Breaks every pattern with `^`/`$` or `\d`, and
   unanchored patterns change meaning from "contains" to "equals". A migration rule could accept a
   leading `^` and a trailing `$` as no-ops.
2. **I-Regexp, search semantics, plus `^` and `$`.** Closer to LIVR 2, but it is no longer a
   standard dialect, and every implementation must validate this custom grammar.
3. **Keep LIVR 2 `like`** and add a portable rule next to it (`matches`?) with I-Regexp semantics.
   No breakage, but two regex rules.

The `i` flag can stay a LIVR argument (`{"like": ["...", "i"]}`): implementations map it to their
engines. Decision needed (Q8).

### 10.3 One field reference syntax

See [8.2](#82-field-references). Breaks `equal_to_field` for field names that contain `/` or start
with `..`.

### 10.4 Schema errors at build time

An unknown rule, wrong arguments or an unknown alias must fail when the validator is built, in all
implementations (#36). JS already throws `Rule [no_such_rule] not registered`. The test suite gets
a category of invalid schemas.

### 10.5 Remove the old syntax

`{"one_of": [["a", "b"]]}` and `{"list_of": [["rules"]]}` (from LIVR 0.3) are removed.

### 10.6 Safe integer range

`integer`, `positive_integer` accept only ±(2^53−1) (I-JSON, RFC 7493). Outside that range they
give `NOT_INTEGER`: languages without big integers cannot represent such values exactly. Open: a
string output for big integers instead?

### 10.7 `not_empty` rejects `null`

Optional (Q7): today `not_empty` passes `null` ([5.7](#57-null-vs-missing-patch-semantics)). If it
rejects `null`, `not_null` is not needed.

### 10.8 `email` grammar

See [7.7](#77-formats-formats-module): quoted local parts and IP-literal domains are rejected.

### 10.9 What is not changed

- No strict typing (#22, #62). Perl and partially PHP cannot tell `"1"` from `1`, so strict type
  rules are not portable. Real booleans come with the `boolean` rule.
- Existing error codes keep their names.
- Unknown fields are still removed by default.

## 11. Rejected ideas

| Idea | Why |
|---|---|
| `instance_of`, `has_methods`, Date, Map, Set, File, Blob, bigint, functions | Language types, not JSON |
| DNS/MX checks for email, `active_url`, database `unique`/`exists`, password breach checks, file system | Depend on the environment and network |
| Phone numbers by country, postal codes, tax IDs, VAT, passports, license plates | Large per-country tables that change. validator.js `isTaxID` alone is 44 KB. Community packages or alias libraries |
| Graphemes, word counts, `emoji` | Need ICU, `Intl.Segmenter` or full Unicode tables; depend on the Unicode version |
| TLD lists in `email`/`hostname`, card network detection | Data changes all the time. Joi embeds 1437 IANA TLDs |
| `date_format` with patterns | PHP, Go, Java and moment.js have different pattern languages |
| `catch` / `fallback` (Zod, Valibot) | Silently replaces invalid data, against the LIVR idea |
| Password strength, `cron`, currency amounts with symbols | Policies, dialects and locales, not formats |
| `timezone` (IANA names) | Needs the tz database; Go and Python get it from a separate package on some platforms. Maybe later as an optional module |
| WHATWG URL parsing for `url` | Not available outside browsers and JS runtimes |
| Strict types | Not portable to Perl and PHP (see [10.9](#109-what-is-not-changed)) |
| Expressions across fields | See [8.12](#812-out-of-scope-expressions) |

## 12. Open questions

| # | Question | Current proposal |
|---|---|---|
| Q1 | `boolean`: which strings? `"on"`/`"off"`, `"yes"`/`"no"`, case-insensitive? | `true`/`false`, `1`/`0`, `"1"`/`"0"`, `"true"`/`"false"` |
| Q2 | Split the spec into Core and modules? | Yes |
| Q3 | Error details as a separate list, or `{code, params}` leaves in the tree? | Separate list |
| Q4 | Names: `dict_of` or `map_of`; `list_length` + `min_items`/`max_items`; `TOO_EARLY`/`TOO_LATE` or `DATE_TOO_LOW`/`DATE_TOO_HIGH` | `dict_of`, both list forms, `TOO_EARLY`/`TOO_LATE` |
| Q5 | `now` / `today` in date bounds: the only non-deterministic part | Yes, UTC, injectable clock |
| Q6 | `datetime-local` (no offset, maybe no seconds) as an `iso_datetime` option? | Probably `{"iso_datetime": "local"}` |
| Q7 | `not_empty` rejects `null`, or a separate `not_null`? | Undecided |
| Q8 | `like`: which option from [10.2](#102-like-and-portable-regular-expressions)? | Undecided |
| Q9 | Parameterized aliases (#57): syntax | Not designed |
| Q10 | Field references: do they see input values or validated output? Parent references syntax | Input values; parent syntax undecided |
| Q11 | `unique_items` error: one code for the field or errors at duplicate positions? | One code plus `index` in details |
| Q12 | Recursion depth limit: error code or exception? | Undecided |
| Q13 | Specific codes for the codes module (`WRONG_COUNTRY_CODE`) or `NOT_ALLOWED_VALUE`? | `NOT_ALLOWED_VALUE` |
| Q14 | `or` errors in the tree: last branch, or Zod-like "the only branch that passed the type check"? | Last branch in the tree, all branches in details |

## 13. Suggested next steps

1. Decide Q2, Q3, Q8: they shape everything else.
2. Add test_suite cases that expose current differences between implementations (string length,
   `email`, `url`, `iso_date` edge cases) and run conformance. This shows what "breaking" really
   breaks.
3. Write the spec text for Core in this order: error details, field references, presence and
   condition rules, list rules, `boolean`, dates, objects and metarules.
4. For every rule, add positive and negative test_suite cases, plus `error_details.json`.
5. Prototype Core in js-validator-livr on a feature branch, then in one more language with a
   different string model (Go or Perl), to check portability before the spec is fixed.
6. Modules after Core: `formats`, `checksums`, `codes` (with data files), `text`.
7. Migration guide: a table of every breaking change with a before/after example.

## Appendix A. Sources

### Validators reviewed

| Validator | Version | Where |
|---|---|---|
| js-livr-extra-rules | current master | Source code |
| Zod | 4.6.7 | livr-benchmark dependencies |
| Valibot | 1.5.0 | livr-benchmark dependencies |
| Joi | 18.3.0 | livr-benchmark dependencies |
| fastest-validator | 1.19.1 | livr-benchmark dependencies |
| Ajv, ajv-formats | 8.20.0, 3.0.1 | livr-benchmark dependencies |
| Laravel validation | 13.x | Documentation |
| go-playground/validator | 10.30 | Documentation |
| validator.js | 13.15 | Documentation |
| go-livr | current master | `text.go` (string length) |

### Standards

- [RFC 3339](https://www.rfc-editor.org/rfc/rfc3339): date and time on the Internet.
- [RFC 4291](https://www.rfc-editor.org/rfc/rfc4291): IPv6 addressing.
- [RFC 4648](https://www.rfc-editor.org/rfc/rfc4648): Base64 and Base64url.
- [RFC 1123](https://www.rfc-editor.org/rfc/rfc1123): host names.
- [RFC 6901](https://www.rfc-editor.org/rfc/rfc6901): JSON Pointer.
- [RFC 7493](https://www.rfc-editor.org/rfc/rfc7493): I-JSON (safe integers).
- [RFC 8259](https://www.rfc-editor.org/rfc/rfc8259): JSON.
- [RFC 9457](https://www.rfc-editor.org/rfc/rfc9457): Problem Details for HTTP APIs.
- [RFC 9485](https://www.rfc-editor.org/rfc/rfc9485): I-Regexp.
- [RFC 9535](https://www.rfc-editor.org/rfc/rfc9535): JSONPath (`match()` and `search()`).
- [RFC 9562](https://www.rfc-editor.org/rfc/rfc9562): UUIDs, versions 1–8, nil and max.
- [WHATWG HTML, valid e-mail address](https://html.spec.whatwg.org/multipage/input.html#valid-e-mail-address).
- [Semantic Versioning 2.0.0](https://semver.org/).
- ISO 3166-1 (countries), ISO 4217 (currencies), ISO 639-1 (languages), ISO 13616 (IBAN),
  ISO/IEC 7812 (card numbers), ITU-T E.164 (phone numbers), GS1 check digits (GTIN).

### LIVR issues

| Issue | Topic | Section |
|---|---|---|
| [#8](https://github.com/koorchik/LIVR/issues/8) | `min_date` / `max_date` | [7.3](#73-dates-and-times) |
| [#14](https://github.com/koorchik/LIVR/issues/14) | JSON Schema features | [8](#8-new-metarules-and-structural-features) |
| [#16](https://github.com/koorchik/LIVR/issues/16) | `iso_time` | [7.3](#73-dates-and-times) |
| [#17](https://github.com/koorchik/LIVR/issues/17) | Strict mode | [8.5](#85-unknown-fields-policy) |
| [#19](https://github.com/koorchik/LIVR/issues/19) | Datetime | [7.3](#73-dates-and-times) |
| [#22](https://github.com/koorchik/LIVR/issues/22) | Strict types, booleans | [7.1](#71-types-and-numbers), [10.9](#109-what-is-not-changed) |
| [#25](https://github.com/koorchik/LIVR/issues/25) | `conflict_with` | [8.3](#83-when) |
| [#30](https://github.com/koorchik/LIVR/issues/30), [#31](https://github.com/koorchik/LIVR/issues/31), [#34](https://github.com/koorchik/LIVR/issues/34) | Error details and params | [9](#9-errors) |
| [#36](https://github.com/koorchik/LIVR/issues/36) | Unregistered rules | [10.4](#104-schema-errors-at-build-time) |
| [#54](https://github.com/koorchik/LIVR/issues/54) | An "empty" rule | [7.4](#74-presence-and-conditions) |
| [#56](https://github.com/koorchik/LIVR/issues/56) | Validating object keys | [8.4](#84-dict_of) |
| [#57](https://github.com/koorchik/LIVR/issues/57) | Future of LIVR: parameterized aliases, rule libraries, regex portability | [7.11](#711-standard-aliases), [10.2](#102-like-and-portable-regular-expressions) |
| [#58](https://github.com/koorchik/LIVR/issues/58) | Conditional validation | [8.3](#83-when) |
| [#62](https://github.com/koorchik/LIVR/issues/62) | Strict types | [10.9](#109-what-is-not-changed) |
| [#63](https://github.com/koorchik/LIVR/issues/63) | `modulo10` (Luhn) | [7.8](#78-checksums-checksums-module) |
| [#64](https://github.com/koorchik/LIVR/issues/64) | Recursive structures | [8.1](#81-recursive-aliases) |
| [#70](https://github.com/koorchik/LIVR/issues/70) | Keep unknown fields | [8.5](#85-unknown-fields-policy) |

js-validator-livr:
[#28](https://github.com/koorchik/js-validator-livr/issues/28) (email vs RFC 822),
[#50](https://github.com/koorchik/js-validator-livr/issues/50) (root lists),
[#56](https://github.com/koorchik/js-validator-livr/issues/56) (`https://www.google.` passes `url`),
[PR #7](https://github.com/koorchik/js-validator-livr/pull/7) (detailed errors).
