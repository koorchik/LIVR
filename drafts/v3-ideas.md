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
- [Appendix B. Probe results](#appendix-b-probe-results)

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

The spec should also state the data model, which LIVR 2 leaves implicit ([LIVR#66]: "it seems that
this project is only intended to validate JSON? The documentation does not make it clear"):

- The input is a JSON value, in the I-JSON profile (RFC 7493): UTF-8, no duplicate member names,
  numbers within the double range. [LIVR#18]: Erlang proplists allowed duplicate keys, and LIVR
  cannot see them.
- The order of object members is not significant; the order of list items is.
- Some languages cannot tell `{}` from `[]` (PHP, Lua, Erlang proplists), and PHP turns an object
  with keys `"0"`…`"n-1"` into a list. Today PHP and Lua keep private copies of the test suite
  ([LIVR#52], notes.json). Instead, a case that depends on it gets a marker in the suite (for example
  `"needs": ["empty_object_vs_list"]`) and the conformance page shows it as "not applicable".
- Invalid UTF-8 in byte-string languages (Erlang, PHP, Lua, Go, Perl without decoding) gives
  `FORMAT_ERROR` ([liver#3]: `<<"Grégo">>` without `/utf8`).

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
- Name clashes. Users already register custom rules with the new standard names (`boolean`,
  `uuid`, `required_if` from js-livr-extra-rules). The spec should say which one wins. liver
  composes rule sets with "first entry wins on name clash" and keeps non-spec rules out of the
  LIVR set ("This rule is not part of the original specification, so it cannot be added as is",
  [liver PR #7]). Proposal: a rule registered by the user replaces the standard one, and the
  migration guide lists all new reserved names.

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
code units). go-livr counts runes (`utf8.RuneCountInString`) and accepts it. Measured with the
conformance runners on 2026-10-19 (`{"max_length": 1}`, method in [Appendix B](#appendix-b-probe-results)):

| Value | Code points | JS, Java | Perl, PHP, Python, Ruby, Go, Lua, both Erlangs | Raku |
|---|---|---|---|---|
| `"й"` (precomposed) | 1 | passes | passes | passes |
| `"😀"` | 1 | `TOO_LONG` | passes | passes |
| `"é"` as `e` + U+0301 | 2 | `TOO_LONG` | `TOO_LONG` | passes |
| `"й"` as `и` + U+0306 | 2 | `TOO_LONG` | `TOO_LONG` | passes |
| `"👍🏽"`, `"🇺🇦"` | 2 | `TOO_LONG` | `TOO_LONG` | passes |

So there are three units in use today: UTF-16 code units (JS, Java), code points (most), and
grapheme clusters (Raku). Swift uses `String.count`, so it counts graphemes too (from the source,
not run). php-validator-livr uses `mb_strlen($value, "UTF-8")`, so code points. The spec does not
say which unit is correct (see [10.1](#101-string-length-in-code-points)).

### 5.10 Booleans

`{"b": {"one_of": [true, false]}}` accepts `"true"`/`"false"` and outputs real booleans (values
are compared as strings and the output is the value from the rule). But `1`, `0`, `"1"`, `"0"` give
`NOT_ALLOWED_VALUE`, and the error code is not specific. There is no `boolean` rule ([#22]).

### 5.11 Unknown fields

`{"a": "string"}` with `{"a": "x", "b": "y"}` gives `{"a": "x"}`. Unknown fields can be neither
rejected ([#17]) nor kept ([#70]).

### 5.12 Other things that need custom rules today

- Conditional presence: "VAT number is required for companies", "email or phone" ([#58]).
- Dictionaries with arbitrary keys: `{"uk": "...", "en": "..."}`, `{"<sku>": <qty>}` ([#56]).
- Positional lists (tuples): `[lng, lat]`, `[from, to]`.
- "Exactly one default address", "at least one admin" in a list.
- Cross-level references: `item.currency == order.currency`, `primary_email ∈ emails`.
- Scalar-or-list inputs from query strings: `?id=5` vs `?id=5&id=6`.
- Date and time: datetime with offset ([#19]), time ([#16]), date bounds ([#8]), durations.
- Cross-field bounds: `end_date >= start_date`, `max_price >= min_price`.
- Error parameters for messages ([#30], [#31], [js-validator-livr PR #7]).

### 5.13 Email: Cyrillic and other IDN domains

Measured on 2026-10-19 with the conformance runners on all implementations except Swift, and on
Chrome 155. The full tables are in [Appendix B](#appendix-b-probe-results).

- `test@пошта.укр` and `test@münchen.de` are rejected by **all 11** implementations.
- The same address in punycode, `test@xn--80a1acn3a.xn--j1amh`, is rejected by 6 of 11: JS, Raku,
  Erlang (liver), Java, Ruby and Go. JS, Raku and liver allow only letters in the TLD
  (`[a-zA-Z]{2,}`); Java, Ruby and Go allow only 2–6 letters. Perl, PHP, Python, Erlang (olifer)
  and Lua accept it. So the reference implementation cannot accept an address on `.укр`, `.бг` or
  `.中国` in any form.
- This is exactly what browsers send. When a user types `test@пошта.укр` into
  `<input type="email">`, Chrome converts the domain and the field value becomes
  `test@xn--80a1acn3a.xn--j1amh`, which is valid. The form passes in the browser and fails on a
  LIVR server.
- The local part is the other way around. `тест@mail.com` is accepted by JS, Raku and liver and
  rejected by the other 8 and by Chrome (the WHATWG grammar has an ASCII local part). Such an
  address needs SMTPUTF8 (RFC 6531) on every server on the way. An IDN domain works with any server
  once it is in punycode.
- JS, Raku, liver and olifer accept an invisible U+200B (zero-width space) in the local part:
  `te​st@mail.com`. liver and olifer also accept U+00A0 (no-break space).
- TLDs longer than 6 letters fail in Java, Ruby and Go: `user@hotline.finance` (already in the test
  suite), `test@example.photography`.
- Everything else differs too: IP literals (rejected by Java, Ruby, Lua, Go), quoted local parts
  (accepted only by JS, Perl, Raku, liver), the 64/254 length limits (checked only by Perl and
  PHP), a hyphen at the start of a label (rejected by Perl, PHP, Python, Ruby, Go) or at the end
  (rejected only by Perl, PHP, Python),
  `test@localhost` and `test@mail.com.` (accepted by olifer and Lua).
- Validator::LIVR 2.1 (master, not on CPAN yet) moves Perl to the JS behavior for the local part:
  it accepts `тест@mail.com` and U+200B. It still rejects `test@пошта.укр` and still accepts the
  punycode form.
- The only negative case with Cyrillic, `email24` in `negative/16-email`, is
  `"тестувальник@пошта.укр "` with a trailing space, so it does not show whether the Cyrillic part
  is wrong.
- liver has a second, non-LIVR rule set (`liver_standard_rules`) with internationalized email: a
  local part without whitespace, `@` and control or format characters (`\p{C}`), and Unicode domain
  labels ([liver#5]). Its LIVR rule set has a TODO list of addresses to support, among them
  `用户@例子.广告`, `अजय@डाटा.भारत`, `квіточка@пошта.укр`, `θσερ@εχαμπλε.ψομ` and
  `Dörte@Sörensen.example.com`.

Popular JS validators split in the same way. Cyrillic domains are accepted by validator.js
`isEmail`, Joi (`allowUnicode` is on by default) and fastest-validator in its default mode, and by
Zod only with `z.regexes.unicodeEmail`. Zod `email()`, Valibot `email()`, ArkType, `email-validator`
and fastest-validator `precise` mode reject even the punycode TLD, like LIVR. The WHATWG-based
regexes (Zod `html5Email`, Valibot `rfcEmail`, Yup, Ajv `email`) accept punycode and reject Unicode.
The LIVR JS regex is the same as Zod `z.regexes.rfc5322Email`.

`url` has the same problem with hosts: JS accepts `https://пошта.укр/` but rejects
`https://xn--80a1acn3a.xn--j1amh/` (the TLD again). Punycode hosts fail in JS, Java, Ruby and Go;
Unicode hosts pass only in JS, Java, Ruby and Lua (and in Validator::LIVR 2.1 master). [liver#5]
asked for Cyrillic in `email` and `url` in 2020. The first patch added `а-яА-Я`, which misses `і`,
`ї`, `є`, `ґ` ([liver PR #6], not merged; the maintainer: "the basic set of rules is part of the
specification"). In
2026-10 it was fixed only in liver's own rule set, with `\p{L}\p{M}\p{N}` labels ("\p{M} is
required for Indic and other scripts with combining marks"). Neither set normalizes the host, so
the Unicode and the punycode forms of one host both pass but stay different values.

### 5.14 Rule objects with several keys

LIVR 2 writes a rule as `{ RULE_NAME: ARGUMENTS }`, but does not say that the object must have
exactly one key. Measured with `{"min_length": 2, "max_length": 3}`,
`{"max_length": 3, "error": "CUSTOM"}` and `{}`, two runs each:

| Implementation | Several rule names | An unknown second key | `{}` |
|---|---|---|---|
| JS, PHP, Ruby, Go | Only the first key is used, the rest is ignored silently | Ignored | Exception |
| Java | One key, in `HashMap` order | `Rule [error] not registered` | Exception |
| Perl 2.0 (CPAN), Raku | One key, in random hash order: results changed between the two runs | Ignored or an exception, at random | Exception |
| Perl 2.1 (master) | `Rule [max_length, min_length] should have one name` | The same error | |
| Python, Lua | Every key is a rule | Exception | The field is dropped |
| Erlang (liver, olifer) | Every key is a rule | Ignored: unknown rules are skipped ([olifer#1]) | liver passes, olifer throws |

So a typo like `{"min_length": 1, "max_lenght": 10}` is silently lost in most implementations, and
LIVR 2 has no room for extra keys in a rule object. This matters for the meta keys in
[8.13](#813-meta-keys-in-rule-objects). Every implementation accepts `{"email": []}` (a rule
without arguments in the object form).

### 5.15 Other behavior LIVR 2 leaves undefined

Found in the issue trackers and checked with js-validator-livr 2.11:

| Behavior | JS 2.11 today | Source | See |
|---|---|---|---|
| Number strings | `integer` and `positive_decimal` accept `"0x10"` (→ 16), `" 5 "`, `"5."`, `"1e3"` and `true` (→ 1); `positive_decimal` accepts `"Infinity"` and outputs `null`. `decimal` rejects all of them | [js#32], [js PR #35] | [10.10](#1010-number-grammar) |
| `default` | `{"default": 5}` turns `null` and `""` into 5, so a PATCH cannot clear a field | [LIVR#12], [js#10] | [7.4](#74-presence-and-conditions) |
| `auto_trim` | Not in the spec. In JS it is deep: it trims inside nested objects, lists, `any_object` values and passwords. `trim` and `auto_trim` also remove U+00A0 and U+FEFF | [js#24] | [10.11](#1011-trimming) |
| Empty rule list `"name": []` | The field is dropped. In 2015 it was the way to keep an optional field without checks | [LIVR#24], [js#5] | [8.9](#89-any) |
| `equal_to_field` inside `or` or an alias | `{"pw2": {"or": [{"equal_to_field": "pw"}, {"eq": "x"}]}}` with `{"pw": "a", "pw2": "a"}` gives `NOT_ALLOWED_VALUE`: the branch sees only `{"pw2": ...}` | [js#25] | [8.2](#82-field-references) |
| `variable_object` selector | `0` and `false` give `FORMAT_ERROR` even if variants `"0"` and `"false"` exist; `1`, `"0"` and `true` work | [js PR #60] | [8.3](#83-when) |
| Unknown selector value | `FORMAT_ERROR` for the whole object. [js PR #60] proposes `{"type": "NOT_ALLOWED_VALUE"}` and `REQUIRED` under the selector | [js PR #60], [LIVR#9] | [8.3](#83-when) |
| `or` with an empty value | Empty values reach the branches: `[{"or": ["not_empty_list"]}, {"list_of": "integer"}]` with `{}` gives `CANNOT_BE_EMPTY`. The 2017 advice in [LIVR#39] relied on the opposite | [LIVR#39] | [8.11](#811-or-defined-semantics) |
| `not_empty_list` with `null` | `FORMAT_ERROR`, but `CANNOT_BE_EMPTY` for a missing value or `""` | | [7.5](#75-lists) |
| Comparison "as strings" | Depends on the language: PHP `(string)false === ""`, Python `str(True) == "True"`. Old bugs: [js#6], [js#8], [js#9], [LIVR#23] (`4.00000000000001` equals `4` in PHP) | | [7.1](#71-types-and-numbers) |

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
| `credit_card` | `checksums` | Extract `luhn` as its own rule ([#63]). The length check (14–16) rejects valid 12–13 and 17–19 digit numbers (ISO/IEC 7812 allows up to 19) |
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
- The set must be closed: everything else gives `NOT_BOOLEAN`. liver's `to_boolean` turns every
  value except `0`, `""`, `"0"`, `"false"` and `null` into `true`, so `"off"` becomes `true`. In
  [liver#8] a user tried `"false"`, `"0"`, `1` and `"off"` with liver's `is_boolean` and always got
  `not_boolean` ("A boolean value must be an atom").
- **Canonical string form.** `eq`, `one_of`, `not_one_of`, `unique_items`, `equal_to_field`,
  `required_if`, `when` cases and `variable_object` selectors compare values "as strings". The
  string form of a boolean or a number depends on the language today:
  - `{"one_of": [true, false]}` with `"true"` passes in JS and gives `NOT_ALLOWED_VALUE` in Perl;
    with `"1"` it is the other way around (JSON::PP booleans stringify to `1` and `0`).
  - PHP `(string)false === ""` ([php#12]), Python `str(True) == "True"` ([python#3]).
  - `"string"` on `true` gives `"true"` in JS and `FORMAT_ERROR` in Perl.
  - [LIVR#23]: `{"one_of": [4.00000000000001]}` equals `4` in PHP, but not in JS or Python. JSON
    `-3.00` becomes `-3` in JS and Perl and `-3.0` in Python and Erlang ([LIVR#40], [olifer#8]).

  Proposal: one Core definition. Booleans are `"true"` and `"false"`; numbers use the JSON number
  serialization of RFC 8785 (JCS), which is the ECMAScript `Number.prototype.toString` algorithm,
  so `1.0` and `1` are both `"1"` and `-3.00` is `"-3"`. A string stays as it is, so `"1.0"` still
  does not equal `1` (as in LIVR 2). Every implementation needs a small number formatter, but no
  language-dependent output. The test suite gets boolean and float cases for `one_of`, `eq` and
  `string`; today it has a single boolean case (`true` → `true`).
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
| `iso_datetime` | Core | `WRONG_DATETIME` | Z V J A VJ, [#19] | RFC 3339 `date-time`, offset required. Output is the input string unchanged |
| `iso_time` | Core | `WRONG_TIME` | Z V A VJ, [#16] | `HH:MM`, `HH:MM:SS`, `HH:MM:SS.fff`, no offset (what `<input type=time>` sends) |
| `min_date`, `max_date` | Core | `TOO_EARLY`, `TOO_LATE` | X J Z L A VJ, [#8] | Bound is a date, a datetime, `"today"`, `"now"` or `{"field": ...}` |
| `iso_duration` | formats | `WRONG_DURATION` | Z J A | ISO 8601 duration as in RFC 3339 Appendix A: `P1DT2H`, `PT30M`, `P2W` |

Details the spec must define:

- `iso_date` (LIVR 2) stays: `YYYY-MM-DD`, a valid calendar date.
- `iso_datetime` exact grammar: `T` separator (case?), seconds required or optional, fraction
  digits limit, leap second `23:59:60` accepted or not. Open: a `local` variant without offset for
  `<input type=datetime-local>` (Q6). [LIVR#19] asked for `"yyyy-mm-dd hh-MM-ss"`: a space instead of
  `T` and no offset, as in SQL. RFC 3339 allows the space (section 5.6, note); decide.
- No local time zone anywhere, not only in comparisons: date-only parsing and fixed bounds too.
  Three bugs came from it: [js#11] (`"2015-10-10"` rejected because of `getTimezoneOffset`), [js PR #2]
  ("Fix for unix time zero: 1970-01-01") and [js-livr-extra-rules#14]
  (`{"iso_date": {"min": "1900-01-01"}}` throws at UTC−01:00 because of a local mean time offset in
  1899). The conformance job should run once under a non-UTC time zone.
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
| `absent` | Core | `FIELD_NOT_ALLOWED` | L J F G, [#54] | The value must be empty (missing, `null` or `""`) |
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
  `required_with_all`, `required_without_all`, `prohibited_if`, `prohibits`, `conflict_with` ([#25]).
- "Empty" is exactly: missing, `null` or `""`. Not `0`, `false` or `[]`. [js-livr-extra-rules
  PR #15] (`required_if_empty`, the same as `required_without`) checks `!valueToCheck`, so a
  referenced `0` or `false` counts as empty there.
- `required_if` on a checkbox ([LIVR#58]: "if field 4 is true, then fields 4a and 4b are required"):
  `{"required_if": {"field4": true}}` compares `"true"` with the raw input, which may be `"1"` or
  `"on"`. Only `when` with `"is": ["boolean", {"eq": true}]` works, and only if `is` rules may
  convert the value (Q10). The docs should recommend it.
- `present` and `not_null` must know whether the key exists. In the Perl and Lua rule APIs a
  missing key and `undef`/`nil` look the same ([Validator-LIVR#12] had to add an `$exist` argument).
  Options that drop `null` values ([Validator-LIVR PR #7] "Clear undef") must not be standard: in
  lists they shift indexes, `[undef, '123', undef]` gives the error at index 0.
- `default` replaces `null` and `""` too ([LIVR#12], [js#10]). With PATCH semantics a client that sends
  `null` to clear a field gets the default instead. Options: keep it (the LIVR 2 meaning of
  "empty"), or add a variant for missing keys only (`default_if_missing`?). `default` cannot take
  an options object: its argument is any JSON value (Q16).
- "Every field is required" as a schema-level switch: Swift has `validator.allRequired = true`
  ([swift PR #30]), aegir makes every path required unless `field_is_optional: true` ([aegir PR #8]),
  Joi has `presence: "required"`, Zod has `.required()`/`.partial()`. The use case is one schema for
  create and PATCH. It fits the object options of [8.5](#85-unknown-fields-policy):
  `{"presence": "required"}`.

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
- Like all rules, they skip empty values. Then `["not_empty_list", {"max_items": 10}]` and
  `{"min_items": 1}` (optional, but not empty if given) are easy, which is what [LIVR#39] asked for.
  The `or` workaround suggested there no longer works ([5.15](#515-other-behavior-livr-2-leaves-undefined)).
- `not_empty_list` with `null` gives `FORMAT_ERROR` in JS, but `CANNOT_BE_EMPTY` for a missing value
  and `""`. Pin it with a test.
- Names used before: `min_list_length` (koorchik in [Validator-LIVR#2]), `array_length_equal`
  ([js#20]), `list_length` (extra-rules). Input for Q4.
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
| `dict_of` | Core (metarule) | `WRONG_KEY` + errors of values | Z V J A F G, [#56] | See [8.4](#84-dict_of) |
| `nested_object` options | Core | `FIELD_NOT_ALLOWED` | Z V J A F, [#17], [#70] | `unknown: strip/error/keep`, `rest`. See [8.5](#85-unknown-fields-policy) |
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

- **`email`**: define the default as the WHATWG HTML "valid e-mail address" grammar, plus at least
  one dot in the domain, plus at most 254 characters (and 64 for the local part, RFC 5321). Then
  the server and `<input type=email>` accept the same addresses, including the punycode form that
  Chrome sends for IDN domains ([5.13](#513-email-cyrillic-and-other-idn-domains)). The same
  grammar exists in Zod (`html5Email`), Valibot (`rfcEmail`) and Yup. See [js-validator-livr#28].
  - Breaking: quoted local parts, IP-literal domains and Unicode local parts, which the JS regex
    accepts today, are rejected. In [LIVR#13] (2015) `email` was kept lenient because the RFC allows
    such addresses (here, one-letter TLDs): "an email can never be trusted anyway, the only way to
    check it is to send a letter to it" (translated). WHATWG reverses this
    on purpose: the server should agree with the browser.
  - Open: WHATWG allows an all-digit TLD (`test@mail.123`). Proposal: the last label must contain a
    letter, as in host names (RFC 3696, section 2).
  - Options for Unicode ([8.12](#812-rule-arguments-and-named-options)):
    `{"email": {"unicode_domain": true}}` also accepts Unicode domain labels, and
    `{"email": {"unicode_local": true}}` a Unicode local part (RFC 6531 syntax). They are separate
    because an IDN domain works with any mail server once it is converted to punycode, while a
    Unicode local part needs SMTPUTF8 on every server on the way. validator.js
    (`allow_utf8_local_part`), Joi (`allowUnicode`) and Zod (`unicodeEmail`) have the same switch.
  - The Unicode grammar must be exact: a domain label is letters, marks and digits (`\p{L}`,
    `\p{M}`, `\p{N}`) or LDH, with `-` not at the start or end, at most 63 code points. The local
    part allows any code point from U+0080 except `\p{C}` and `\p{Z}`, so U+200B, U+200E and
    U+00A0 are rejected (JS accepts U+200B today).
  - No IDNA processing: no mapping, no conversion to punycode, no script mixing checks. The output
    is the input string. IDNA needs the UTS #46 tables, and languages disagree: Python's built-in
    `idna` codec is IDNA2003 and maps `faß.de` to `fass.de`, IDNA2008 keeps `ß`. So `test@раураl.com`
    (Cyrillic `р`, `а`, `у`) passes `unicode_domain`; homographs are a policy, not a format. A
    `to_ascii_domain` modifier can live in an optional module later.
  - Test cases: every row of [Appendix B](#appendix-b-probe-results), the five addresses from the
    liver TODO list, and `email24` split into a Cyrillic case and a trailing-space case.
- **`url`**: allow a list of schemes, `{"url": ["http", "https", "ftp"]}`, defaults to `http` and
  `https`. Pin the grammar in the spec and add `https://www.google.` ([js-validator-livr#56]) to the
  negative cases. Do not reference the WHATWG URL parser (Zod, Valibot): other languages do not
  have it. The grammar must decide (all of these differ today, [Appendix B](#appendix-b-probe-results)):
  - The host is a `hostname` (punycode allowed, so `https://xn--80a1acn3a.xn--j1amh/` passes; it
    fails in JS, Java, Ruby, Go today), an IPv4 address or `[IPv6]` (accepted only by PHP and Lua
    today).
  - A host without a dot: `http://localhost:3000` (rejected only by Java) and
    `https://reciepts/12345678.pdf` ([LIVR#37]).
  - A trailing dot (`https://www.google.`) is rejected.
  - Userinfo (`https://user:pass@example.com/`) is rejected by Perl, Raku, Python and Lua.
  - No hidden length limit (JS has `length < 2083` in UTF-16 code units).
  - Unicode: the default is a URI (RFC 3986, ASCII only); `{"url": {"unicode": true}}` accepts an
    IRI (RFC 3987) with a Unicode host and path, `https://пошта.укр/шлях?q=тест`. Today JS, Java,
    Ruby and Lua accept a Unicode host, and Python and olifer a Unicode path only.

### 7.8 Checksums (`checksums` module)

| Rule | Error | Sources | Definition |
|---|---|---|---|
| `luhn` | `WRONG_CHECKSUM` | F VJ, [#63] | ASCII digits, at least 2, Luhn mod 10 |
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
from [#57]). They need a portable `like` ([10.2](#102-like-and-portable-regular-expressions)) and
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

Parameterized aliases ([#57]) would make this much more useful, for example `money(max)`. Syntax not
designed yet (Q9).

- Error codes: yes, every standard alias should have one. `docs/validation-rules/or.md` already
  says "It is a good idea to define a custom error code for such an alias", and [LIVR#34] shows why
  a `like` code is useless for users: "'First name must contain only letters, numbers, or
  underscores' is a lot more helpful". `params.pattern` ([9.4](#94-standard-params)) does not fix
  that; a code does. Inline `$error` ([8.13](#813-meta-keys-in-rule-objects)) is the lighter
  option.
- Order: in [LIVR#57] koorchik wrote "But, at first, we need to make aliases parameterized". Q9 should
  be decided before the alias library is shipped, not after.
- Custom rules people wrote that are aliases with parameters: liver `subset` ([liver PR #7]: a
  scalar or a list, every item in a set) is `["to_list", {"list_of": {"one_of": [...]}}]`; aegir
  `neq` is `not_one_of`; [LIVR#63] writes `credit_card` as an alias over `modulo10`.
- aegir also needed `not_like`, because Go's RE2 has no lookarounds. A `not_like` rule (or a
  generic `not` metarule) covers "must not contain".

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
| Rules with several switches | Positional arguments only | Options object ([8.12](#812-rule-arguments-and-named-options)) |
| A custom error code for one rule | An alias with `error` | `$error` and other meta keys ([8.13](#813-meta-keys-in-rule-objects)) |
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
- But "lazily" applies only to the expansion. The build must still resolve the whole alias graph,
  so that an unknown rule or alias fails at build time ([10.4](#104-schema-errors-at-build-time)).
  [js#30]: `new Validator("I'm not a rule")` fails only in `validate()`; koorchik: `prepare()`
  "should throw too".
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
  reports its own error. **This holds only for bounds.** It contradicts LIVR 2 for equality:
  `equal_to_field` with a missing other field gives `FIELDS_NOT_EQUAL` ("A missing field is not
  equal to any value", case `missing_other_field` in `negative/17-equal_to_field`). [LIVR#32] relies
  on it for two optional fields that must match:
  `{"password": {"equal_to_field": "password2"}, "password2": {"equal_to_field": "password"}}`.
  Presence rules need the opposite too: an empty reference makes `required_without` require the
  field. So each rule defines what an empty reference means.
- References resolve against the enclosing object, also inside `or`, aliases, `when` branches and
  list items. In JS 2.11 they don't: a rule inside `or` or `list_of` sees only `{field: value}`
  ([5.15](#515-other-behavior-livr-2-leaves-undefined), [js#25]).
- References see the input values after `auto_trim` but before the rules of the referenced field.
  Open: should they see the output of the referenced field instead (for example after `to_lc`)?
- Parent references: `"/currency"` covers "item currency equals order currency" when the order is
  the root. For lists in lists (`orders[i].items[j]` vs `orders[i]`) a relative step up is needed.
  Options: `..` segments (does a list count as a level?), or relative JSON pointers like Ajv
  (`"1/currency"`). Joi has sibling, ancestor (`...`) and root (`/`) references.
- Implementation impact: rules that take references need the root input and the current path. This
  changes the internal rule API in every implementation (an extra context argument), but not the
  JSON schemas. One context object can carry the root, the path, the clock for `now`/`today`, and
  user data: [php-validator-livr PR #29] (open) already proposes `validate($data, $context)` passed
  through every metarule. Swift's custom `greater_eq_than_field` needed a protocol so that the
  validator injects the other field's value, and only at the same level.
- Test case from [LIVR#58] and [js#29]: in `pricingInfos[]`, `period` is required only when
  `businessType` is `"RENTAL"`, and the price bounds depend on `period`. These are two independent
  selectors in one list item. Two `list_of_different_objects` in a row fail, because the first one
  strips the fields of the second ("validator will remove the rest of the fields and pass it to the
  next rule"). Two `when` rules inside `list_of_objects` work.

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
- `cases` keys and `variable_object` selectors use the canonical string form
  ([7.1](#71-types-and-numbers)). In JS 2.11 a selector `0` or `false` gives `FORMAT_ERROR` even
  when the variants `"0"` and `"false"` exist.
- A value that matches no case (Q21). `variable_object` gives `FORMAT_ERROR` for the whole object
  today, and koorchik's 2015 prototype `dynamic_object` in [LIVR#9] put `NOT_SUPPORTED` under the
  selector field. [js PR #60] proposes `NOT_ALLOWED_VALUE` under the selector and `REQUIRED` for a
  missing selector; in
  [js#18] koorchik said "FORMAT_ERROR - in most cases is related to developers error, not to users
  input error", and a selector is user input. Proposal: an optional `"default"` case; without it,
  `when` gives `NOT_ALLOWED_VALUE` with `params.allowed` = the case keys, and `variable_object`
  does the same under its selector field.
- `then`, `else` and the cases are ordinary rule lists. A missing branch means no rules. Open:
  should a missing branch keep the value (like `any`) or drop it (like a field with no rules)?
  A real case from [js#25]: `{"email": "em@a.il", "use_email": false}`, "validate email only if it
  is used".
- [LIVR#9] has a ready test for sibling fields: `type_of_data` is `"digital"` → `value` is
  `{"number_between": [1, 100]}`, `"string"` → `{"length_between": [1, 3]}`.
- `when` covers: `required_unless`, `prohibited_if`, `conflict_with` ([#25]), "all or nothing",
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
- In [LIVR#56] koorchik proposed two composable rules instead: `{"object_keys": [{"like":
  "^[0-9a-f]+$"}]}` and `{"object_values": ["required", {"max_length": 10}]}`. The user proposed
  jq-like `to_entries`/`from_entries` modifiers. The example from that issue (commit hashes as
  keys, `{"6d12ba9": "Add foo to bar"}`) is a ready test.
- The short form needs care: [LIVR#21] rejected a `nested_object` shorthand because `{"min_length":
  10}` and `{"city": "required"}` look the same. Here `{"dict_of": "string"}` is safe (a string
  or a list), but `{"dict_of": {"max_length": 10}}` would be ambiguous with the long form. So the
  short form is only a string or a list.
- PHP turns `{"0": ..., "1": ...}` into a list, so a dictionary keyed by numeric IDs needs care in
  PHP ([2](#2-principles-for-standard-rules)).
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
  option. This closes [#17] and [#70].
- The same options for `variable_object`, `list_of_objects`, `list_of_different_objects`.
- Error code: three names are already in use: `EXTRA_FIELD` ([Validator-LIVR PR #13]), `UNKNOWN_FIELD`
  ([Validator-LIVR#12]) and `unknown_field` (liver's `strict` option). `FIELD_NOT_ALLOWED` is also
  the code of `absent`; a separate `UNKNOWN_FIELD` would tell "a field you sent that is forbidden
  here" from "a field I don't know" (Q19).
- Prefer schema-level options to a validator option. [Validator-LIVR PR #13] adds a strict flag
  that works only at the root: nested validators are built with the package default. [LIVR#17]
  (DanielHreben): validator options that only one implementation has "make the validator more
  complex and harder to maintain and to update to new versions of the spec" (translated).
- Prefer `rest` with rules to `keep`. Removing unknown fields is a security property: "It is a
  security related issue" ([js#17]), "This guarantees that everything is validated" ([js#29]), and in
  [LIVR#17] keeping them was rejected "because of possible security problems" (translated). `keep` and
  `any` should say so in the docs.
- Another object option: `{"presence": "required"}` makes every field required
  ([7.4](#74-presence-and-conditions)).
- [Validator-LIVR#12] used a reserved field name `'?' => 'not_present'` with the comment "TODO: Allow
  '?' to be an ordinary field?". Reserved field names clash with data; options in the rule object
  ([8.13](#813-meta-keys-in-rule-objects)) do not.

### 8.6 `tuple`

```json
{ "location": { "tuple": [["required", "decimal"], ["required", "decimal"]] } }
```

- One rule list per position. Errors are a list, like `list_of`: `[null, "NOT_DECIMAL"]`.
- A shorter list is validated as if the missing positions were empty, so `required` catches them.
- A longer list gives `TOO_MANY_ITEMS` for the whole field. Open: a `rest` option for extra items.
- Arguments: with LIVR 2 argument spreading ([8.12](#812-rule-arguments-and-named-options)),
  `{"tuple": [["required", "decimal"]]}` is ambiguous: one position with two rules, or the old
  "single list argument" form. `tuple` needs the explicit object form:
  `{"tuple": {"items": [["required", "decimal"], ["required", "decimal"]]}}`.
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

- History: the spec had `any` in 2015 ([LIVR commit 4dccffb]); 2.0 replaced it with `string` and
  `any_object`. The objection then ([LIVR#24]): "in most cases developers want any string but not
  array or hash"; [js#5]: "fields without validation are a rare case" (translated). The docs should say: `string` for
  strings, `any` for JSON blobs.
- Unchanged means unchanged: `auto_trim` must not trim inside `any` (JS trims inside
  `any_object` today, [5.15](#515-other-behavior-livr-2-leaves-undefined)). PHP turns an empty
  `{}` into `[]` on output, which the PHP docs must mention.
- Limits: `any` on untrusted input has no depth or size limit. [LIVR#7] asked for
  `max_fileds_count`, `max_key_length`, `max_nesting_level` and `max_total_size` on `any_object`;
  koorchik answered that the total size is easier to check outside LIVR. Proposal: the depth limit
  of [8.1](#81-recursive-aliases) applies to `any` too; sizes stay out of scope.
- An empty rule list, `"name": []`, is not the same as `any`. Today JS drops such a field, and
  `{"list_of": []}` turns `[1, {"x": 1}]` into `[null, null]`. In 2015 `[]` was the way to keep an
  optional field without checks ([js#5]), and PHP threw `Rule [] not registered` ([LIVR#24]). Proposal:
  `[]` is a schema error ([10.4](#104-schema-errors-at-build-time)), and `any` is the explicit
  form (Q20).

### 8.10 Root rules

Validation of a value that is not an object ([js-validator-livr#50]): a list of objects in a bulk
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
- Empty values are passed to the branches, like to any other rule. JS changed this in 2019
  ([js-validator-livr 996c964], "Fix OR rule"), and `negative/29-or` pins it (missing → `REQUIRED`).
  The spec text must say it.
- Tests for Q14: the spec's own `or` example (it emulates `list_of_different_objects`) expects,
  for a `material` item with a bad `warehouse_id`, `{"name": "REQUIRED", "product_type":
  "NOT_ALLOWED_VALUE"}`, the errors of the `service` branch. The Swift copy of the suite expects
  a different `or` error ([LIVR#60]), so "last branch" is not uniform today.
- Untagged unions are real: the fstab schema in [LIVR#14] has `diskDevice` and `diskUUID` with the
  same `"type": "disk"`, so neither `variable_object` nor `when` can tell them apart. Only strict
  `or` branches can.
- Exporters: liver's OpenAPI export ([liver PR #9]) maps `or` to `oneOf`, but first-match `or` is
  closer to `anyOf`. A mapping table to JSON Schema would help such tools (see also the notes on
  `like`, coercion and `equal_to_field` there).

### 8.12 Rule arguments and named options

LIVR 2 spreads a JSON list into positional arguments ([LIVR#47], "How it works"):
`{"length_between": [1, 3]}` → `length_between(1, 3)`, `{"one_of": ["aa", "bb"]}` →
`one_of("aa", "bb")`. A single list argument needs double brackets,
`{"some_rule": [["aa", "bb"], 123]}`, and a scalar is passed as is (`{"one_of": "value"}`, [LIVR#6]).
Problems:

- A list value is cut silently: `{"default": [1, 2]}` outputs `1` in JS and Perl;
  `{"default": [[1, 2]]}` outputs `[1, 2]`.
- Every new rule that takes a list really takes a variable number of arguments: `{"uuid": [4, 7]}`,
  `{"url": ["http", "https", "ftp"]}`, `{"unique_items": ["country", "zip"]}`. [10.5](#105-remove-the-old-syntax)
  removes `[[...]]` for `one_of` and `list_of`, but today it is the only way to pass one list. PHP's
  `or` took its first list as the list of branches ([php PR #31]), and the test suite itself has
  `{"eq": ["Dnipro"]}`.
- Rules with several independent switches do not fit positions: `email` with two Unicode
  switches, `url` with schemes and Unicode, `iso_datetime` with offset, seconds and separator.

Proposal:

1. The spec gives the signature of every rule after spreading.
2. A rule with switches takes one options object as its only argument. Every option has a default,
   so `"email"` equals `{"email": {}}`:

   ```json
   { "email": { "unicode_domain": true } }
   { "url": { "schemes": ["http", "https", "ftp"], "unicode": true } }
   { "uuid": { "versions": [4, 7] } }
   { "iso_datetime": { "offset": "optional", "separator": ["T", " "] } }
   { "tuple": { "items": [["required", "decimal"], ["required", "decimal"]] } }
   ```

3. A scalar short form can stay for the most common option: `{"uuid": 7}`, `{"ip": 6}`. No list
   short forms, because of spreading.
4. Option names are snake_case. An unknown option or a wrong option value is a schema error at
   build time ([10.4](#104-schema-errors-at-build-time)), so `{"email": {"unicod_domain": true}}`
   is not ignored.
5. Rules whose argument is any JSON value (`eq`, `one_of`, `default`) or an object of fields
   (`nested_object`, `variable_object`) cannot take an options object in the same place. They get
   options through a separate rule (`default_if_missing`), the `[fields, options]` list form
   ([8.5](#85-unknown-fields-policy)), or meta keys ([8.13](#813-meta-keys-in-rule-objects)).

Candidates:

| Rule | Options | See |
|---|---|---|
| `email` | `unicode_domain`, `unicode_local` | [7.7](#77-formats-formats-module) |
| `url` | `schemes`, `unicode`; maybe `allow_ip`, `allow_single_label` | [7.7](#77-formats-formats-module), [LIVR#37] |
| `hostname` | `unicode` | [7.7](#77-formats-formats-module) |
| `uuid` | `versions` | [7.7](#77-formats-formats-module) |
| `ip`, `cidr` | `version` | [7.7](#77-formats-formats-module) |
| `base64` | `alphabet` (`"standard"`, `"url"`), `padding` | [7.7](#77-formats-formats-module) |
| `iso_datetime` | `offset` (`"required"`, `"optional"`, `"forbidden"`), `seconds`, `separator` | [7.3](#73-dates-and-times), [LIVR#19] |
| `like` | `flags` | [10.2](#102-like-and-portable-regular-expressions) |
| `nested_object` and other object rules | `unknown`, `rest`, `presence` | [8.5](#85-unknown-fields-policy) |

Similar: validator.js `isEmail(s, {allow_utf8_local_part, require_tld, allow_ip_domain})` and
`isURL(s, {protocols, require_tld, allow_underscores})`, Joi `email({tlds, allowUnicode,
minDomainSegments})`, Zod `z.url({protocol, hostname})` and `z.email({pattern})`,
fastest-validator `{type: "email", mode: "precise"}`.

### 8.13 Meta keys in rule objects

A rule object may hold reserved keys next to the rule name. They are not arguments: the same keys
work for every rule, standard or custom, and they change how the result of the rule is reported,
not what the rule accepts.

```json
{
  "password": ["required", { "min_length": 10, "$error": "PASSWORD_TOO_SHORT" }],
  "login": ["required", { "email": [], "$error": "WRONG_LOGIN" }],
  "nickname": {
    "like": "^[a-z0-9_]+$",
    "$error": "WRONG_NICKNAME",
    "$params": { "hint": "nickname_chars" },
    "$meta": { "description": "Lowercase letters, digits and _" }
  }
}
```

Rules:

- A rule object has exactly one rule name and any number of meta keys. Meta keys start with `$`;
  rule and alias names cannot.
- LIVR 2 gives no meaning to a second key ([5.14](#514-rule-objects-with-several-keys)), so this
  is new syntax, not a changed meaning. LIVR 2 implementations ignore the extra key or fail,
  depending on the key order, so schemas with meta keys need LIVR 3 implementations.
- An unknown `$` key is a schema error, like a second rule name. Ajv's strict mode does the same
  for unknown keywords (`strict mode: unknown keyword: "x-ui"`); JSON Schema itself ignores them.
- A rule without arguments uses an empty list: `{"email": [], "$error": "..."}`. Every
  implementation accepts `{"email": []}` today.
- Meta keys never change the rule's output. Otherwise they would be arguments.

Candidate keys:

| Key | Meaning | Similar |
|---|---|---|
| `$error` | Replaces the error code of this rule. A string replaces every code of the rule; an object maps codes, `{"TOO_SHORT": "PASSWORD_TOO_SHORT"}`, and leaves the others (`FORMAT_ERROR`) as they are. On `nested_object` or `list_of` a string replaces the whole error tree, like an alias with `error` | Alias `error`; Zod `{error}` on every check; Valibot's message argument of every action; Joi `.rule({message})` and `.messages({"string.min": ...})`; class-validator `{message}`; ajv-errors `errorMessage: {minLength: ...}`; fastest-validator `messages: {stringMin: ...}`; liver `custom_error/2` (global) |
| `$params` | Extra data merged into the error details of this rule: an i18n key, a UI hint, a legacy numeric code. Never into the error tree | class-validator `{context}` (returned as `contexts`); Zod refine `{params}`; Yup `test({params})` |
| `$meta` | Anything; ignored by validation. Descriptions, examples, hints for form generators and OpenAPI export | JTD `metadata` (RFC 8927); Zod `.meta()`; Valibot `title()`, `description()`, `metadata()`; Joi `.description()`, `.note()`, `.example()`, `.meta()`; Yup `.meta()`; JSON Schema `title`, `description`, `examples`, `$comment`; OpenAPI `x-*`; aegir keeps a human `description` with each rule |
| `$warn` (later) | A failure is reported as a warning and the value passes | Joi `.rule({warn: true})`, `.warn()` |

Details:

- With error details ([9.3](#93-proposal-error-details)): `code` is the new code, `rule` is still
  the real rule name, and `params` keep the rule's params (`{"min": 10}` is still there for the
  message) plus `$params`. Open: also `params.original_code`, the same question as for aliases.
- `$error` is an inline alias with `error`, for a rule that is used once. [LIVR#34] asks for exactly
  this: a code that says what is wrong with a `like` field.
- Not needed in LIVR:
  - `$abort`/`$bail` (Zod `abort`, Valibot `abortPipeEarly`, Laravel `bail`): LIVR already stops at
    the first failing rule of a field.
  - `$label` (Joi, Yup, fastest-validator): they build messages; LIVR returns codes, and labels
    belong to the translation layer.
  - `$when` on a single rule (Zod `when`, Joi `when`, class-validator `ValidateIf`): `when`
    ([8.3](#83-when)) covers it, and two ways to write a condition are one too many.
  - `$groups` (class-validator): separate schemas or `when`.
  - `$default`, `$optional`, `$nullable` (fastest-validator, Joi, Yup): LIVR has rules for this.
- A rule list cannot have meta keys, because it is a list. A wrapper like
  `{"$rules": [...], "$error": "..."}` would be an anonymous alias. Open (Q15).
- Alias definitions could accept `$params` and `$meta` too; their `error` stays.
- The prefix: `$` is used by JSON Schema (`$ref`, `$id`, `$comment`), Ajv (`$data`),
  fastest-validator (`$$root`, `$$strict`) and MongoDB. Alternatives: `@error`, `x-error`
  (OpenAPI style). Open (Q15).

### 8.14 Out of scope: expressions

"The sum of percentages is 100", "total equals the sum of item prices", "end - start <= 30 days".
These need an expression language (Joi `x`, JSON Logic). It is a big spec on its own and risky for
schemas from untrusted sources. Such checks stay custom rules.

### 8.15 Evaluation order and async validation

The spec has no async rules, and [js#16] kept it so: async needs the engine and a separate API. The
JS `AsyncValidator` validates fields in parallel and the rules of one field one after another. New
features must give the same result in that model:

- Standard rules stay synchronous and pure: no I/O, no clock except `now`/`today`.
- `or` branches, `when` (`is` first, then the branch) and `list_contains` run in a defined order.
- Field references see input values (the Q10 proposal). If they saw the output of the referenced
  field, fields would depend on each other, and async validation would need an order.
- No "abort early" across fields (Joi `abortEarly`): LIVR returns the errors of all fields. Inside
  a field it already stops at the first error; in [js#16] koorchik gave the reason: "there is no point
  in loading the database with more queries" (translated).
- One error per field stays ([LIVR#57]): "rules work like a pipe", because rules like `trim` and
  `to_lc` change the value for the next rule. Use cases that want all errors of a field can use a
  custom `apply_all` metarule, as suggested there.

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

1. **Params.** Every validator above has them, LIVR does not ([#30], [#31], [js-validator-livr PR #7]).
   Even the i18n example in js-validator-livr `docs/DESIGN.md` (`"Must be at least {min}
   characters"`) cannot be implemented today: there is no `min` to take.
2. **Path as a JSON Pointer** (Ajv `instancePath`, RFC 6901). It does not depend on the language.
   The example in RFC 9457 (Problem Details for HTTP APIs) uses a `pointer` member in `errors`.
3. **Both views**, like Zod: a tree for forms, a flat list for APIs and logs.
4. **No input values in errors.** Joi (`context.value`) and fastest-validator (`actual`) put them
   there, and passwords end up in logs. [java-validator-livr PR #8] (merged) turned every error leaf
   into `{"code": ..., "fieldValue": ...}`; for an alias error the value is the whole nested
   object. Java edited its copy of the test suite to match and fails conformance since
   (notes.json). With error details it can drop that. A count is different from a value: [Swift#33]
   asked for "TOO_LONG - 30", where 30 is how many characters are over the limit. An optional
   `actual` length or count in params does not leak the value (for a password it leaks only the
   length; open).
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
- Method names follow each language's conventions; the spec defines the data. In [js PR #7]
  koorchik suggested the name `getDetailedErrors()`.
- One error per field, as in LIVR 2: rules run like a pipe and stop at the first error
  ([8.15](#815-evaluation-order-and-async-validation)). So there is at most one detail per leaf
  path; the errors of `or` branches go into `params`.
- `rule` is the canonical snake_case name. JS also accepts camelCase names (`maxLength`), so "as
  written in the schema" is ambiguous.
- Prefer a result object to getters on the validator. Errors stored on the validator instance
  forced locks in Java ([java PR #6], "Reentrant usage") and Swift ([swift#34], "Add thread safety"),
  and a second stateful getter makes it worse. PHP rebuilds validators on every request, so a
  validator that is built once and shared matters there too ([php PR #32]).
- Migration: [js PR #7] (`getDeepErrors()`, open since 2015) and the workaround in
  js-validator-livr `t/tests-sync/05-rules_replacement.js` produce leaves like
  `{"code": "TOO_LONG", "rule": {"max_length": [10]}}`: the rejected shape below. Their users need a
  note in the migration guide.

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
- `WRONG_DATE` is a known weak spot. In [LIVR#35] koorchik kept it for compatibility: "is feb 30
  wrong date or wrong format? ... maybe in future versions of the spec we will introduce additional
  error codes for the date related rules (but firstly we should move to semver)". LIVR 3 is that
  version: keep `WRONG_DATE` and add params, or split it. Decide explicitly.
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
- Say whether extra members in an error detail are tolerated (Java adds `fieldValue` today).
  Proposal: the suite compares `path`, `code`, `rule` and the listed `params`; extra `params` are
  allowed.
- Capability markers for cases that some languages cannot run ({} vs [], see
  [2](#2-principles-for-standard-rules)), instead of private copies of the suite.
- One conformance run under a non-UTC time zone ([7.3](#73-dates-and-times)).

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
implementations ([#36]). JS already throws `Rule [no_such_rule] not registered`. The test suite gets
a category of invalid schemas.

- Also schema errors: a rule object with several rule names or with no key (`{}`), an empty rule
  list (`[]`, Q20), an unknown meta key or option, a `like` pattern that is not a string or does
  not compile. Today aegir silently replaces an invalid regex with `.*`, and olifer and liver skip
  unknown rule names ([olifer#1], [5.14](#514-rule-objects-with-several-keys)).
- Regexes are strings. koorchik in [Validator-LIVR#5]: "a regex must be passed as a string, for
  compatibility" (translated); Raku accepts only regex objects today (notes.json).
- The tests assert "building fails", not the mechanism. In [LIVR#36] koorchik wrote "Every
  implementation can decide but its own how report about syntax errors in validation rules", and an
  Erlang implementation may return an error tuple instead of throwing.
- [Validator-LIVR#11] is an example of a misuse that passed silently: `{like: '..', max_length: 20}`
  was checked depending on the hash order. koorchik in [LIVR#57]: "It is not the first situation of
  misuse of the syntax".

### 10.5 Remove the old syntax

`{"one_of": [["a", "b"]]}` and `{"list_of": [["rules"]]}` (from LIVR 0.3) are removed. The spec
then needs one normative argument rule, because `[[...]]` is also how a single list argument is
passed today ([8.12](#812-rule-arguments-and-named-options)).

### 10.6 Safe integer range

`integer`, `positive_integer` accept only ±(2^53−1) (I-JSON, RFC 7493). Outside that range they
give `NOT_INTEGER`: languages without big integers cannot represent such values exactly. Open: a
string output for big integers instead?

### 10.7 `not_empty` rejects `null`

Optional (Q7): today `not_empty` passes `null` ([5.7](#57-null-vs-missing-patch-semantics)). If it
rejects `null`, `not_null` is not needed.

### 10.8 `email` grammar

See [7.7](#77-formats-formats-module): quoted local parts, IP-literal domains and Unicode local
parts (accepted by JS, Raku, liver and Validator::LIVR 2.1 today) are rejected by default. Fixed:
punycode TLDs are accepted everywhere ([5.13](#513-email-cyrillic-and-other-idn-domains)). The
punycode fixes do not need LIVR 3: they can go into the LIVR 2 test suite now.

### 10.9 What is not changed

- No strict typing ([#22], [#62]). Perl and partially PHP cannot tell `"1"` from `1`, so strict type
  rules are not portable. Real booleans come with the `boolean` rule. The strongest argument for
  [#62] is koorchik's own, about configs in [LIVR#11]: "it is better to restrict the allowed type
  explicitly than to convert it" (translated). The answer to [#62] should address it.
- Existing error codes keep their names.
- Unknown fields are still removed by default.

### 10.10 Number grammar

LIVR 2 says only "strings that look like integers". JS 2.11 is not consistent with itself
([5.15](#515-other-behavior-livr-2-leaves-undefined)): `integer` and `positive_decimal` accept
`"0x10"`, `" 5 "`, `"5."`, `"1e3"` and `true`, while `decimal` rejects them. In [js#32] koorchik wrote
"Scientific notation is not supported due to multi-language nature of LIVR", and [js PR #35], merged
the same day, replaced the regex in `positive_decimal` with `+value <= 0`. Other implementations
use `is_numeric` (PHP, accepts `"1e3"`), `filter_var` (PHP, rejected `0` and `"0"` in `decimal`,
[php PR #25]) or their own regexes.

Proposal, one grammar for all numeric rules:

- Strings: an integer is `-?(0|[1-9][0-9]*)`, a decimal adds an optional `\.[0-9]+`. No `+`, no
  leading zeros (`"04"` stays rejected, [LIVR#33]; `digits` is for codes), no exponent, no
  whitespace (use `trim`), no hex, no `Infinity` or `NaN`.
- JSON numbers are judged by value, not by the language's string form: a JSON `0.0000001` is a
  number, though JS prints it as `1e-7`. A JSON number is an integer if its fractional part is
  zero, as in JSON Schema, so `1.0` passes `integer`.
- Booleans are not numbers: `true` gives `NOT_INTEGER` (JS outputs `1` today).
- Test cases: `3`, `0`, `"0"`, `"0.00"`, `-0`, `"1e3"`, `"0x10"`, `" 5 "`, `"5."`, `".5"`,
  `"+5"`, `true`, `"Infinity"`, JSON `1e-7`, JSON `1.0`. And JSON `-3.00` for `decimal`: it decodes
  to `-3` in JS and Perl and to `-3.0` in Python and Erlang ([LIVR#40], [olifer#8]), and liver's LIVR
  set rejects the number `3` in `decimal` while it accepts the string `"3"`.
- Big integers: [10.6](#106-safe-integer-range).

### 10.11 Trimming

- `trim` "removes leading and trailing whitespace", but the set differs: JS `.trim()` removes
  Unicode white space and U+FEFF, PHP `trim()` removes ASCII space, `\t`, `\n`, `\r`, `\0` and
  `\x0B`. The spec should list the code points: the Unicode `White_Space` property is 25 code
  points and fits in the spec text. Decide whether U+FEFF is included.
- `auto_trim` is not in the spec, but implementations have it and [8.2](#82-field-references)
  relies on it. In JS it is deep: it trims inside nested objects, lists and `any_object` values
  ([js#24] found it trimming by default in nested objects). Proposal: define it as a standard option
  that trims only strings that rules look at, never inside `any`.
- Modifiers pass non-strings unchanged (the spec says so for modifiers), but PHP 8 throws a
  `TypeError` in `trim`, `to_lc` and `to_uc` on `["a", ["b"]]` (fixed in [php PR #32]). A test case
  with nested lists pins it.

### 10.12 One rule name per rule object

A rule object has exactly one rule name; other keys must be meta keys
([8.13](#813-meta-keys-in-rule-objects)). Several rule names are a schema error. Today most
implementations use one key silently, some apply all keys, and Perl and Raku pick one at random
([5.14](#514-rule-objects-with-several-keys)). Validator::LIVR 2.1 already dies with
`Rule [max_length, min_length] should have one name`.

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
| Expressions across fields | See [8.14](#814-out-of-scope-expressions) |
| Several errors per field (run all rules) | Rules work like a pipe ([LIVR#57]), see [8.15](#815-evaluation-order-and-async-validation) |
| IDNA processing in `email`, `url`, `hostname` (mapping, punycode conversion, script checks) | Needs the UTS #46 tables; IDNA2003 and IDNA2008 give different results ([7.7](#77-formats-formats-module)) |
| Meta keys `$abort`, `$label`, `$when`, `$groups`, `$default` | See [8.13](#813-meta-keys-in-rule-objects) |
| Reserved field names (`'?'` in [Validator-LIVR#12], `$root`) | Field names can be anything; options go into rule objects ([8.13](#813-meta-keys-in-rule-objects)) |

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
| Q9 | Parameterized aliases ([#57]): syntax | Not designed |
| Q10 | Field references: do they see input values or validated output? Parent references syntax | Input values; parent syntax undecided |
| Q11 | `unique_items` error: one code for the field or errors at duplicate positions? | One code plus `index` in details |
| Q12 | Recursion depth limit: error code or exception? | Undecided |
| Q13 | Specific codes for the codes module (`WRONG_COUNTRY_CODE`) or `NOT_ALLOWED_VALUE`? | `NOT_ALLOWED_VALUE` |
| Q14 | `or` errors in the tree: last branch, or Zod-like "the only branch that passed the type check"? | Last branch in the tree, all branches in details |
| Q15 | Meta keys in rule objects: the prefix (`$`, `@`, `x-`), the set for 3.0, a wrapper for whole rule lists | `$`; `$error`, `$params`, `$meta`; no wrapper |
| Q16 | `default` on `null` and `""`: keep LIVR 2, or fill only missing keys (`default_if_missing`)? | Undecided |
| Q17 | `email` and Unicode: option names, the default, an all-digit TLD | ASCII by default; `unicode_domain` and `unicode_local`; the TLD must contain a letter |
| Q18 | An options object for rules with several switches; which short forms stay? | Yes; scalar short forms only |
| Q19 | Unknown fields: `FIELD_NOT_ALLOWED` or `UNKNOWN_FIELD` (`EXTRA_FIELD` and `unknown_field` are also in use)? | Undecided |
| Q20 | An empty rule list `[]`: a schema error or "no rules"? | Schema error; `any` is the explicit form |
| Q21 | `when` cases and `variable_object`: a value that matches no case | An optional `default` case, otherwise `NOT_ALLOWED_VALUE` with `allowed` |
| Q22 | The canonical string form for comparisons | Numbers as in RFC 8785 (JCS), booleans `"true"`/`"false"` |

## 13. Suggested next steps

0. Fix what does not need LIVR 3, in the LIVR 2 test suite and the implementations:
   - positive cases for punycode in `email` (`test@xn--80a1acn3a.xn--j1amh`, `test@mail.xn--j1amh`)
     and `url` (`https://xn--80a1acn3a.xn--j1amh/`), and report the TLD bugs: letters-only TLDs in
     JS, Raku and liver; 2–6 letters in Java, Ruby and Go;
   - split `email24` into a Cyrillic case and a trailing-space case;
   - `decimal` cases with integers and zero, boolean cases for `one_of` and `eq`
     ([10.10](#1010-number-grammar), [7.1](#71-types-and-numbers));
   - a rule object with several rule names is an error (Validator::LIVR 2.1 already does it).
1. Decide Q2, Q3, Q8: they shape everything else. Q15 and Q18 (meta keys and options) shape the
   syntax of most new rules, so decide them early too.
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
| validator.js, Zod, Valibot, Joi, Yup, Ajv + ajv-formats, fastest-validator, ArkType, email-validator | 13.15.35, 4.6.7, 1.5.0, 18.3.0, 1.7.1, 8.20.0 + 3.0.1, 1.19.1, 2.2.8, 2.0.4 | Run on the `email`/`url` cases of [Appendix B](#appendix-b-probe-results), 2026-10-19 |
| Zod, Valibot (+ @valibot/i18n 1.3.0), Joi, Yup, class-validator 0.15.1, ajv-errors 3.0.0, fastest-validator, ArkType, Effect 4.0.5 | | Run: per-rule messages, params, abort, warnings and metadata ([8.13](#813-meta-keys-in-rule-objects)) |
| Chrome | 155 | `<input type="email">` and `type="url"`: values set by script and typed by a user (puppeteer) |
| All LIVR implementations except Swift | The versions on the conformance page; Validator::LIVR 2.0 (CPAN) and 2.1 (master) | Conformance runners with the probe cases of [Appendix B](#appendix-b-probe-results) |
| Issue trackers | All issues and PRs, open and closed | The 14 GitHub repositories of the implementations, js-livr-extra-rules and aegir; lua-LIVR on framagit has no issues |

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
- [RFC 3492](https://www.rfc-editor.org/rfc/rfc3492): Punycode.
- [RFC 3696](https://www.rfc-editor.org/rfc/rfc3696): checking names, section 2 (TLDs are not
  all-numeric).
- [RFC 3986](https://www.rfc-editor.org/rfc/rfc3986), [RFC 3987](https://www.rfc-editor.org/rfc/rfc3987):
  URI and IRI.
- [RFC 5321](https://www.rfc-editor.org/rfc/rfc5321): SMTP, length limits of addresses.
- [RFC 5890](https://www.rfc-editor.org/rfc/rfc5890): IDNA2008.
- [RFC 6531](https://www.rfc-editor.org/rfc/rfc6531): SMTPUTF8 (internationalized email).
- [RFC 8785](https://www.rfc-editor.org/rfc/rfc8785): JSON Canonicalization Scheme (number
  serialization).
- [RFC 8927](https://www.rfc-editor.org/rfc/rfc8927): JSON Type Definition (`metadata`).
- [UTS #46](https://www.unicode.org/reports/tr46/): Unicode IDNA compatibility processing.
- [WHATWG URL](https://url.spec.whatwg.org/).
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
| [#5](https://github.com/koorchik/LIVR/issues/5) | Bound rules check the type (`number_between` rejects strings) | [7.1](#71-types-and-numbers) |
| [#23](https://github.com/koorchik/LIVR/issues/23), [#40](https://github.com/koorchik/LIVR/issues/40) | Comparison as strings, floats, `decimal` with `-3.00` | [7.1](#71-types-and-numbers), [10.10](#1010-number-grammar) |
| [#7](https://github.com/koorchik/LIVR/issues/7) | Any objects, size limits | [8.9](#89-any) |
| [#9](https://github.com/koorchik/LIVR/issues/9) | Dynamic validation, `dynamic_object` | [8.3](#83-when) |
| [#11](https://github.com/koorchik/LIVR/issues/11) | Type conversion for primitives, configs | [10.9](#109-what-is-not-changed) |
| [#12](https://github.com/koorchik/LIVR/issues/12) | `default` | [7.4](#74-presence-and-conditions) |
| [#13](https://github.com/koorchik/LIVR/issues/13) | Email: one-letter TLDs | [7.7](#77-formats-formats-module) |
| [#18](https://github.com/koorchik/LIVR/issues/18), [#52](https://github.com/koorchik/LIVR/issues/52), [#66](https://github.com/koorchik/LIVR/issues/66) | The data model: duplicate keys, `{}` vs `[]` in Lua, "only JSON?" | [2](#2-principles-for-standard-rules) |
| [#21](https://github.com/koorchik/LIVR/issues/21) | A `nested_object` shorthand (rejected) | [8.4](#84-dict_of) |
| [#24](https://github.com/koorchik/LIVR/issues/24) | Fields without rules, `string` instead of `any` | [8.9](#89-any) |
| [#32](https://github.com/koorchik/LIVR/issues/32) | `equal_to_field` for optional fields | [8.2](#82-field-references) |
| [#33](https://github.com/koorchik/LIVR/issues/33) | Integers with leading zeros | [10.10](#1010-number-grammar) |
| [#35](https://github.com/koorchik/LIVR/issues/35) | `WRONG_DATE` | [9.5](#95-error-code-naming) |
| [#37](https://github.com/koorchik/LIVR/issues/37) | `url` tests, single-label hosts | [7.7](#77-formats-formats-module) |
| [#39](https://github.com/koorchik/LIVR/issues/39) | `not_empty_list` and optional lists | [7.5](#75-lists) |
| [#6](https://github.com/koorchik/LIVR/issues/6), [#47](https://github.com/koorchik/LIVR/issues/47) | `eq`, a scalar argument, argument spreading | [8.12](#812-rule-arguments-and-named-options) |
| [#60](https://github.com/koorchik/LIVR/issues/60) | Swift: a different `or` error in its suite | [8.11](#811-or-defined-semantics) |

Implementation trackers: js-validator-livr (js), js-livr-extra-rules, Validator-LIVR (Perl),
php-validator-livr (php), python-validator-livr (python), java-validator-livr (java),
livr-swift-validator (swift), liver, olifer and aegir. References like [js#25] or [liver PR #7] in
this file link to them.

js-validator-livr:
[#28](https://github.com/koorchik/js-validator-livr/issues/28) (email vs RFC 822),
[#50](https://github.com/koorchik/js-validator-livr/issues/50) (root lists),
[#56](https://github.com/koorchik/js-validator-livr/issues/56) (`https://www.google.` passes `url`),
[PR #7](https://github.com/koorchik/js-validator-livr/pull/7) (detailed errors).

## Appendix B. Probe results

### B.1 How the probes were run

- 49 positive cases with one value each (`{"v": <rule>}` and `{"v": <value>}`), run on 2026-10-19
  with the runners from `conformance/` on a separate copy of the test suite, two runs. ✓ means the
  value passes, ✗ a validation error, E an exception while building or validating.
- Implementations: livr 2.11.0 (JS), Validator::LIVR 2.0 from CPAN (Perl), LIVR 2.2.0 (Raku),
  validator/livr dev-master (PHP), LIVR 2.0.1 (Python), liver 1.1.0, olifer 2.0.2, validator-livr
  2.0.0 (Java), ruby-livr 2.0.0, lua-livr 0.5.1, go-livr 2.0.0. Swift was not run: it needs macOS.
  Validator::LIVR 2.1 from master was checked separately ([5.13](#513-email-cyrillic-and-other-idn-domains)).
- The string length and rule object results are in [5.9](#59-string-length-depends-on-the-implementation)
  and [5.14](#514-rule-objects-with-several-keys).
- JS validators: the versions from [Appendix A](#appendix-a-sources), default options unless the
  column says otherwise.
- Chrome 155: "set by script" is `input.value = ...` and `input.validity.valid`. A value typed by
  a user is converted first: `test@пошта.укр` → `test@xn--80a1acn3a.xn--j1amh` (valid),
  `test@münchen.de` → `test@xn--mnchen-3ya.de`, `test@раураl.com` → `test@xn--l-7sba6dbr.com`.
  `тест@mail.com` and `用户@例子.广告` stay as typed and are invalid. A typed `https://пошта.укр/шлях`
  stays Unicode and is valid.

### B.2 `email` in LIVR implementations

| Case | Value | JS | Perl | Raku | PHP | Py | liver | olifer | Java | Ruby | Lua | Go |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| ascii | `test@mail.com` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| upper | `TEST@MAIL.COM` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| cyr_local | `тест@mail.com` | ✓ | ✗ | ✓ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| cyr_domain | `test@пошта.укр` | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| cyr_both | `тестувальник@пошта.укр` | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| puny_domain | `test@xn--80a1acn3a.xn--j1amh` | ✗ | ✓ | ✗ | ✓ | ✓ | ✗ | ✓ | ✗ | ✗ | ✓ | ✗ |
| puny_tld | `test@mail.xn--j1amh` | ✗ | ✓ | ✗ | ✓ | ✓ | ✗ | ✓ | ✗ | ✗ | ✓ | ✗ |
| puny_label | `test@xn--mnchen-3ya.de` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| umlaut_domain | `test@münchen.de` | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| cjk | `用户@例子.广告` | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| tld_7 | `user@hotline.finance` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | ✗ | ✓ | ✗ |
| tld_11 | `test@example.photography` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | ✗ | ✓ | ✗ |
| ip_literal | `test@[127.0.0.1]` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ |
| quoted | `"john doe"@mail.com` | ✓ | ✓ | ✓ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| local_65 | `a×65@mail.com` | ✓ | ✗ | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| label_64 | `test@a×64.com` | ✓ | ✓ | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| total_255 | `a×60@b×60.b×60.b×60.c×10.com` | ✓ | ✗ | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| hyphen_start | `test@-mail.com` | ✓ | ✗ | ✓ | ✗ | ✗ | ✓ | ✓ | ✓ | ✗ | ✓ | ✗ |
| hyphen_end | `test@mail-.com` | ✓ | ✗ | ✓ | ✗ | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| trailing_dot | `test@mail.com.` | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✓ | ✗ |
| digit_tld | `test@mail.123` | ✗ | ✓ | ✗ | ✗ | ✓ | ✗ | ✓ | ✗ | ✗ | ✓ | ✗ |
| single_label | `test@localhost` | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✓ | ✗ |
| fullwidth_at | `test＠mail.com` | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| zero_width | `te\u200bst@mail.com` | ✓ | ✗ | ✓ | ✗ | ✗ | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ |
| nbsp_local | `te\u00a0st@mail.com` | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ |
| homograph | `test@раураl.com` | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |

### B.3 `url` in LIVR implementations

| Case | Value | JS | Perl | Raku | PHP | Py | liver | olifer | Java | Ruby | Lua | Go |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| ascii | `https://example.com/path?q=1` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| cyr_host | `https://пошта.укр/` | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✓ | ✓ | ✗ |
| puny_host | `https://xn--80a1acn3a.xn--j1amh/` | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | ✗ | ✓ | ✗ |
| cyr_path | `https://example.com/шлях?q=тест` | ✓ | ✗ | ✗ | ✗ | ✓ | ✗ | ✓ | ✓ | ✓ | ✗ | ✓ |
| google_dot | `https://www.google.` | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | ✗ | ✓ | ✓ | ✓ | ✓ |
| localhost_port | `http://localhost:3000/` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | ✓ | ✓ | ✓ |
| tld_11 | `https://example.photography/` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| upper | `HTTPS://EXAMPLE.COM/` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| ipv6 | `https://[::1]/` | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ |
| userinfo | `https://user:pass@example.com/` | ✓ | ✗ | ✗ | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ | ✗ | ✓ |
| ftp | `ftp://example.com/` | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ |

### B.4 `email` in JS validators

| Case | LIVR JS | validator.js | validator.js, no UTF-8 local | Zod `email()` | Zod `html5Email` | Zod `unicodeEmail` | Valibot `email` | Valibot `rfcEmail` | Joi | Joi, no Unicode | Yup | Ajv `email` | fastest-v. | fastest-v. precise | ArkType | email-validator | Chrome, set by script |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| ascii | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| upper | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| cyr_local | ✓ | ✓ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✓ | ✓ | ✗ | ✗ | ✗ |
| cyr_domain | ✗ | ✓ | ✓ | ✗ | ✗ | ✓ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| cyr_both | ✗ | ✓ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| puny_domain | ✗ | ✓ | ✓ | ✗ | ✓ | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | ✗ | ✗ | ✓ |
| puny_tld | ✗ | ✓ | ✓ | ✗ | ✓ | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | ✗ | ✗ | ✓ |
| puny_label | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| umlaut_domain | ✗ | ✓ | ✓ | ✗ | ✗ | ✓ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| cjk | ✗ | ✓ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| tld_7 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| tld_11 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| ip_literal | ✓ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✓ | ✗ | ✗ | ✗ |
| quoted | ✓ | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ |
| local_65 | ✓ | ✗ | ✗ | ✓ | ✓ | ✗ | ✓ | ✓ | ✗ | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | ✓ |
| label_64 | ✓ | ✗ | ✗ | ✓ | ✗ | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ | ✓ | ✓ | ✓ | ✓ | ✗ | ✗ |
| total_255 | ✓ | ✗ | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | ✓ |
| hyphen_start | ✓ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✓ | ✓ | ✗ | ✗ |
| hyphen_end | ✓ | ✗ | ✗ | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✓ | ✓ | ✗ | ✗ |
| trailing_dot | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| digit_tld | ✗ | ✗ | ✗ | ✗ | ✓ | ✓ | ✗ | ✓ | ✗ | ✗ | ✓ | ✓ | ✓ | ✗ | ✗ | ✗ | ✓ |
| single_label | ✗ | ✗ | ✗ | ✗ | ✓ | ✓ | ✗ | ✓ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ |
| fullwidth_at | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| zero_width | ✓ | ✓ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✓ | ✓ | ✗ | ✗ | ✗ |
| nbsp_local | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| homograph | ✗ | ✓ | ✓ | ✗ | ✗ | ✓ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |

### B.5 `url` in JS validators

| Case | LIVR JS | validator.js | Zod `url()` | Zod `httpUrl()` | Valibot | Joi `uri()` | Yup | Ajv `uri` | fastest-v. | ArkType | `new URL()` | Chrome |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| ascii | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| cyr_host | ✓ | ✓ | ✓ | ✗ | ✓ | ✗ | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ |
| puny_host | ✗ | ✓ | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| cyr_path | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ |
| google_dot | ✓ | ✗ | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| localhost_port | ✓ | ✗ | ✓ | ✗ | ✓ | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ |
| tld_11 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| upper | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | ✓ | ✓ | ✓ |
| ipv6 | ✗ | ✓ | ✓ | ✗ | ✓ | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ |
| userinfo | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| ftp | ✗ | ✓ | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ | ✗ | ✓ | ✓ | ✓ |

<!-- Links to issues, pull requests and commits -->

[#8]: https://github.com/koorchik/LIVR/issues/8
[#16]: https://github.com/koorchik/LIVR/issues/16
[#17]: https://github.com/koorchik/LIVR/issues/17
[#19]: https://github.com/koorchik/LIVR/issues/19
[#22]: https://github.com/koorchik/LIVR/issues/22
[#25]: https://github.com/koorchik/LIVR/issues/25
[#30]: https://github.com/koorchik/LIVR/issues/30
[#31]: https://github.com/koorchik/LIVR/issues/31
[#36]: https://github.com/koorchik/LIVR/issues/36
[#54]: https://github.com/koorchik/LIVR/issues/54
[#56]: https://github.com/koorchik/LIVR/issues/56
[#57]: https://github.com/koorchik/LIVR/issues/57
[#58]: https://github.com/koorchik/LIVR/issues/58
[#62]: https://github.com/koorchik/LIVR/issues/62
[#63]: https://github.com/koorchik/LIVR/issues/63
[#70]: https://github.com/koorchik/LIVR/issues/70
[LIVR#6]: https://github.com/koorchik/LIVR/issues/6
[LIVR#7]: https://github.com/koorchik/LIVR/issues/7
[LIVR#9]: https://github.com/koorchik/LIVR/issues/9
[LIVR#11]: https://github.com/koorchik/LIVR/issues/11
[LIVR#12]: https://github.com/koorchik/LIVR/issues/12
[LIVR#13]: https://github.com/koorchik/LIVR/issues/13
[LIVR#14]: https://github.com/koorchik/LIVR/issues/14
[LIVR#17]: https://github.com/koorchik/LIVR/issues/17
[LIVR#18]: https://github.com/koorchik/LIVR/issues/18
[LIVR#19]: https://github.com/koorchik/LIVR/issues/19
[LIVR#21]: https://github.com/koorchik/LIVR/issues/21
[LIVR#23]: https://github.com/koorchik/LIVR/issues/23
[LIVR#24]: https://github.com/koorchik/LIVR/issues/24
[LIVR#32]: https://github.com/koorchik/LIVR/issues/32
[LIVR#33]: https://github.com/koorchik/LIVR/issues/33
[LIVR#34]: https://github.com/koorchik/LIVR/issues/34
[LIVR#35]: https://github.com/koorchik/LIVR/issues/35
[LIVR#36]: https://github.com/koorchik/LIVR/issues/36
[LIVR#37]: https://github.com/koorchik/LIVR/issues/37
[LIVR#39]: https://github.com/koorchik/LIVR/issues/39
[LIVR#40]: https://github.com/koorchik/LIVR/issues/40
[LIVR#47]: https://github.com/koorchik/LIVR/issues/47
[LIVR#52]: https://github.com/koorchik/LIVR/issues/52
[LIVR#56]: https://github.com/koorchik/LIVR/issues/56
[LIVR#57]: https://github.com/koorchik/LIVR/issues/57
[LIVR#58]: https://github.com/koorchik/LIVR/issues/58
[LIVR#60]: https://github.com/koorchik/LIVR/issues/60
[LIVR#63]: https://github.com/koorchik/LIVR/issues/63
[LIVR#66]: https://github.com/koorchik/LIVR/issues/66
[LIVR commit 4dccffb]: https://github.com/koorchik/LIVR/commit/4dccffb
[Swift#33]: https://github.com/olxbr/livr-swift-validator/issues/33
[Validator-LIVR#2]: https://github.com/koorchik/Validator-LIVR/issues/2
[Validator-LIVR#5]: https://github.com/koorchik/Validator-LIVR/issues/5
[Validator-LIVR#11]: https://github.com/koorchik/Validator-LIVR/issues/11
[Validator-LIVR#12]: https://github.com/koorchik/Validator-LIVR/issues/12
[Validator-LIVR PR #7]: https://github.com/koorchik/Validator-LIVR/pull/7
[Validator-LIVR PR #13]: https://github.com/koorchik/Validator-LIVR/pull/13
[aegir PR #8]: https://github.com/olxbr/aegir/pull/8
[java PR #6]: https://github.com/vlbaluk/java-validator-livr/pull/6
[java-validator-livr PR #8]: https://github.com/vlbaluk/java-validator-livr/pull/8
[js#5]: https://github.com/koorchik/js-validator-livr/issues/5
[js#6]: https://github.com/koorchik/js-validator-livr/issues/6
[js#8]: https://github.com/koorchik/js-validator-livr/issues/8
[js#9]: https://github.com/koorchik/js-validator-livr/issues/9
[js#10]: https://github.com/koorchik/js-validator-livr/issues/10
[js#11]: https://github.com/koorchik/js-validator-livr/issues/11
[js#16]: https://github.com/koorchik/js-validator-livr/issues/16
[js#17]: https://github.com/koorchik/js-validator-livr/issues/17
[js#18]: https://github.com/koorchik/js-validator-livr/issues/18
[js#20]: https://github.com/koorchik/js-validator-livr/issues/20
[js#24]: https://github.com/koorchik/js-validator-livr/issues/24
[js#25]: https://github.com/koorchik/js-validator-livr/issues/25
[js#29]: https://github.com/koorchik/js-validator-livr/issues/29
[js#30]: https://github.com/koorchik/js-validator-livr/issues/30
[js#32]: https://github.com/koorchik/js-validator-livr/issues/32
[js PR #2]: https://github.com/koorchik/js-validator-livr/pull/2
[js PR #7]: https://github.com/koorchik/js-validator-livr/pull/7
[js PR #35]: https://github.com/koorchik/js-validator-livr/pull/35
[js PR #60]: https://github.com/koorchik/js-validator-livr/pull/60
[js-livr-extra-rules#14]: https://github.com/koorchik/js-livr-extra-rules/issues/14
[js-livr-extra-rules PR #15]: https://github.com/koorchik/js-livr-extra-rules/pull/15
[js-validator-livr#28]: https://github.com/koorchik/js-validator-livr/issues/28
[js-validator-livr#50]: https://github.com/koorchik/js-validator-livr/issues/50
[js-validator-livr#56]: https://github.com/koorchik/js-validator-livr/issues/56
[js-validator-livr 996c964]: https://github.com/koorchik/js-validator-livr/commit/996c964
[js-validator-livr PR #7]: https://github.com/koorchik/js-validator-livr/pull/7
[liver#3]: https://github.com/erlangbureau/liver/issues/3
[liver#5]: https://github.com/erlangbureau/liver/issues/5
[liver#8]: https://github.com/erlangbureau/liver/issues/8
[liver PR #6]: https://github.com/erlangbureau/liver/pull/6
[liver PR #7]: https://github.com/erlangbureau/liver/pull/7
[liver PR #9]: https://github.com/erlangbureau/liver/pull/9
[olifer#1]: https://github.com/Prots/olifer/issues/1
[olifer#8]: https://github.com/Prots/olifer/issues/8
[php#12]: https://github.com/WebbyLab/php-validator-livr/issues/12
[php PR #25]: https://github.com/WebbyLab/php-validator-livr/pull/25
[php PR #31]: https://github.com/WebbyLab/php-validator-livr/pull/31
[php PR #32]: https://github.com/WebbyLab/php-validator-livr/pull/32
[php-validator-livr PR #29]: https://github.com/WebbyLab/php-validator-livr/pull/29
[python#3]: https://github.com/asholok/python-validator-livr/issues/3
[swift#34]: https://github.com/olxbr/livr-swift-validator/issues/34
[swift PR #30]: https://github.com/olxbr/livr-swift-validator/pull/30
