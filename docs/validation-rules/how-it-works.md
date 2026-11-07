# How it works

Rules are a structure that maps field names to validation rules:

```text
{ FIELD_NAME: VALIDATION_RULE, ... }
```

- `FIELD_NAME` is the name of the field to validate.
- `VALIDATION_RULE` is the name of a rule, a rule with arguments `{ RULE_NAME: ARGUMENTS }`, or a list of such rules. Rules in a list are applied one after another.

To pass several arguments, use a list. A single argument that is not a list can be passed as is.

## From rules to function calls

Each rule is the name of a function that builds a validator. Arguments from the rules are passed to that function:

| Rule | Becomes |
|---|---|
| `'required'` or `{ required: [] }` | `required()` |
| `{ max_length: 5 }` or `{ max_length: [5] }` | `max_length(5)` |
| `{ length_between: [1, 10] }` | `length_between(1, 10)` |
| `{ one_of: ['Kyiv', 'Lviv'] }` (supported since v0.4) | `one_of('Kyiv', 'Lviv')` |
| `{ one_of: [['Kyiv', 'Lviv']] }` (old syntax) | `one_of(['Kyiv', 'Lviv'])` |
| `{ my_own_rule: [1, [2, 3], 'bla'] }` | `my_own_rule(1, [2, 3], 'bla')` |

The built validator receives a value and returns an error code, for example `'REQUIRED'`, if validation fails, or nothing if it succeeds. Validators may also change the value they return, and that is how modifiers and type coercion work.

That's all: a tiny core that is easy to extend with new rules.

## What the validator returns

- If all fields are valid, the validator returns the output data: only the fields that have rules, with values changed by the rules (see [Types coercing](/validation-rules/types-coercing.html)).
- If some fields are invalid, it returns an error for every invalid field. Errors have the same shape as the data, so nested objects and lists get nested errors.

```livr
// rules
{
    name: 'required',
    address: { nested_object: {
        city: 'required',
        zip: 'positive_integer'
    }},
    tags: { list_of: { max_length: 5 } }
}
// input
{
    address: { city: 'Kyiv', zip: '-1' },
    tags: ['short', 'too long']
}
```

In lists, the errors of valid items are `null`, so the position of every error is preserved.

## Conventions of the 2.5 rules <Badge type="warning" text="LIVR 2.5 draft" /> {#conventions-2-5}

The rules of the [draft LIVR 2.5](/changes.html#v2-5-draft) follow these conventions, unless the rule page says otherwise. They match how the LIVR 2.0 rules behave, but are written down explicitly, because 2.0 leaves some of them implicit.

### Empty values

An empty value is a missing field, `null` or `""`. All new rules skip empty values: the rule passes and the value stays as it is. The exceptions are [`required_if`](/validation-rules/required_if.html) (a presence rule), [`when`](/validation-rules/when.html) (passes the value to its branch) and [`any`](/validation-rules/any.html).

### String form

A primitive value is a string, a number or a boolean. A rule that expects a primitive value returns `FORMAT_ERROR` for an object or a list.

Rules that check text (string and format rules, checksums) check the string form of a primitive value, and their output is that string form, like [`like`](/validation-rules/like.html) in 2.0:

- a string is used as it is;
- a boolean is `"true"` or `"false"`, but [format rules](/validation-rules/format-rules.html) and [checksum rules](/validation-rules/checksum-rules.html) never accept a boolean: it gives the error code of the rule, so `true` is not a hostname and not Base64, although `"true"` is both;
- an integral number (no fractional part) is an integer without a decimal point or an exponent: `1` and `1.0` give `"1"`, `-3.00` gives `"-3"`, `100` gives `"100"`;
- any other number is the shortest decimal that reads back as the same double, without an exponent: `0.5`, `-12.25`, `0.1`.

This is what RFC 8785 and ECMAScript `String(number)` give. Most languages need a small formatter for it: Python `str(1.0)` is `"1.0"`, Java gives `"1.0"` and `"1.0E7"`, Go `%g` gives `"1e+06"`.

| Number | String form |
|---|---|
| `1.0` | `"1"` |
| `-0.0` | `"0"` |
| `100` | `"100"` |
| `1e3` | `"1000"` |
| `0.1` | `"0.1"` |
| `-12.25` | `"-12.25"` |
| `123456789012345` | `"123456789012345"` |

For integers beyond ±(2^53−1), and for |n| ≥ 10^21 or |n| < 10^-6, the string form is implementation-defined (I-JSON, RFC 7493, does not promise such numbers), and the test suite has no such numbers. Send big integers, card numbers and the like as strings.

### Comparison

Rules that compare values ([`not_one_of`](/validation-rules/not_one_of.html), [`unique`](/validation-rules/unique.html), [`required_if`](/validation-rules/required_if.html), [`when`](/validation-rules/when.html)) compare the string forms. So `1` equals `"1"`, `true` equals `"true"`, and `1.0` equals `"1"`, but `"1.0"` does not equal `1` (as in 2.0 `one_of`). For `one_of` and `eq` this is a recommendation in 2.5 and becomes a requirement in 3.0, except for booleans, which they compare as strings already in 2.5: `{ eq: true }` accepts `true` and `"true"` (`['boolean', { eq: true }]` in a `when` condition needs it). An implementation that accepted another form of a boolean in 2.0 (`"1"` in Perl and PHP, `"True"` in Python) keeps accepting it too.

Strings are compared as they are, code point by code point, without Unicode normalization.

### Numbers

Rules that take a number ([`max_decimals`](/validation-rules/max_decimals.html)) accept a JSON number or a string in the grammar of the `decimal` rule, `-?[0-9]+(\.[0-9]+)?`. An object or a list gives `FORMAT_ERROR`, any other value (a boolean, another string) gives `NOT_NUMBER`. So does a string that is too large for a finite double (a `1` with 400 zeros): the output is a number, and JSON has no infinity. A JSON number is judged by its value: `1e-3` has 3 digits after the decimal point.

### Field references

[`required_if`](/validation-rules/required_if.html) and [`when`](/validation-rules/when.html) refer to other fields with a reference:

- `'name'`: the field `name` of the containing object (below);
- `'a/b/c'`: a path down from that object. On a list, a segment is an index only in the form `0` or `[1-9][0-9]*` (`'items/0/id'`; `'items/01'` is missing). On an object, every segment is an ordinary key;
- `~1` stands for `/` and `~0` for `~` inside a segment, as in JSON Pointer (RFC 6901), so a field named `a/b` is `'a~1b'`.

The containing object is the nearest object that is validated field by field: the root, or an object of [`nested_object`](/validation-rules/nested_object.html), [`list_of_objects`](/validation-rules/list_of_objects.html), [`variable_object`](/validation-rules/variable_object.html) or [`list_of_different_objects`](/validation-rules/list_of_different_objects.html).

- Aliases, [`or`](/validation-rules/or.html) branches and the rules of [`when`](/validation-rules/when.html) (the condition and the branches) are transparent: their rules see the containing object of the field that uses them. An alias `{ name: 'vat', rules: { required_if: { type: 'company' } } }` used as `vat_number: 'vat'` reads `type` next to `vat_number`. The condition of `when` checks the referenced value, but its rules see the same object as the field: in `{ vat: { when: ['address/country', { equal_to_field: 'seller_country' }, 'required'] } }`, `seller_country` is the sibling of `vat`, not of `country`.
- Items of [`list_of`](/validation-rules/list_of.html), values of [`values`](/validation-rules/values.html) and keys of [`keys`](/validation-rules/keys.html) have no containing object of their own: a reference inside their rules is a missing value. Use `list_of_objects` (or `nested_object` inside `list_of`) to refer to the fields of an item.

A reference sees the input value of the field, before the rules of that field, so `trim` or `to_lc` on the referenced field does not change what the reference sees. With the auto-trim option of the validator the input is trimmed before validation, so references see the trimmed values. Fields without rules are visible too. If a segment is missing, or the value on the way is not an object (or a list for an index segment), the referenced value is missing.

A reference that is not a string, is empty, starts or ends with `/`, has an empty segment (`'a//b'`), or has an invalid escape (`~2`, a trailing `~`) is a [schema error](#arguments). A leading `/` is reserved for root references in 3.0; references to parents or to the root are not in 2.5.

### Arguments

As in 2.0, a list is spread into arguments: `{ length_between: [1, 3] }` is `length_between(1, 3)`. The new rules take:

- no arguments: `'uuid'`, `{ uuid: [] }`;
- a scalar: `{ split: ',' }`;
- several arguments: `{ not_one_of: ['a', 'b'] }` is `not_one_of('a', 'b')`;
- an options object: `{ iso_date: { min: 'today' } }`, `{ list_length: { max: 10 } }`.

Arguments are taken in order, like the parameters of a function:

- the arguments that a rule takes are checked: a wrong one is a schema error;
- a new rule that takes no arguments gives a schema error for any argument (`{ boolean: 1 }`, `{ jwt: 'HS256' }`). An argument that looks like a restriction must not be ignored silently, and the rule can get arguments in a later version;
- arguments after the ones a rule takes (`{ split: [',', ';'] }`, `{ max_decimals: [2, 3] }`) depend on the implementation: it may ignore them or give a schema error. Don't pass them. The same holds for the LIVR 2.0 rules.

A number and a string are interchangeable in the arguments of the 2.5 rules. Where a rule takes a number, a string in the grammar of `decimal` is that number (`{ max_decimals: '2' }`, `{ mac: '64' }`; `' 2'`, `'1e1'` and `'0x40'` are not numbers). Where it takes a string, a number is its [string form](#string-form), so `{ split: 1 }` splits at `"1"`. The value still has to be right: `{ mac: 32 }` and `{ uuid: 4 }` (`"4"` is not `"v4"`) are schema errors. Booleans, `null`, objects and lists are neither numbers nor strings. A [field reference](#field-references) must be a string: `{ when: [1, …] }` is a schema error. Argument values are case-sensitive: `{ digest: 'MD5' }` is a schema error. The 2.0 rules keep their own argument handling. `{ rule: null }` is one `null` argument. No 2.5 rule takes `null`, so `{ boolean: null }` and `{ uuid: null }` are schema errors. The 2.0 rules and custom rules get `null` as one argument, as before, so `{ default: null }` sets `null`, and `{ iso_date: null }` is the plain `iso_date`.

An empty rule list `[]` where a new rule takes rules (the condition, the branches and the cases of [`when`](/validation-rules/when.html), the rules of [`values`](/validation-rules/values.html) and [`keys`](/validation-rules/keys.html)) is a schema error: it is almost always a mistake. Use [`'any'`](/validation-rules/any.html) for "no rules". This does not change LIVR 2.0: `[]` as the rules of a field, of `list_of` or of `or` keeps its 2.0 behavior.

The old "single list argument" form of `one_of` and `list_of` (`[['a', 'b']]`) does not apply to the new rules, except `values` and `keys`: they take their rules like `list_of`.

An argument that does not match the signature of the rule (a wrong type, a wrong value, an unknown option, a missing required argument) is a **schema error**: building the validator fails. So is an unknown rule name. How the failure is reported (an exception, an error value) is up to the implementation.

### Errors

One error per field, as in 2.0. Metarules return the error tree of their inner rules.

The codes tell the structure from the value:

- `FORMAT_ERROR`: a wrong structure, an object or a list where a primitive value is expected (or the other way round);
- `WRONG_<FORMAT>` and `NOT_<TYPE>`: a primitive value that is not what the rule expects, a typo of the user. A boolean is a primitive value, so `true` for a date is `WRONG_DATE`;
- bound codes (`TOO_*`, `<FORMAT>_TOO_EARLY`, `<FORMAT>_TOO_LATE`): the value itself is right, but it is out of bounds.

So a rule checks the format before the bounds, and a bound code always means a valid value.

### Grammars

Every grammar on the rule pages matches the **whole** string: nothing may come before or after it, and a trailing newline is not ignored (in Perl, Python and PHP `$` matches before a final `\n`; Ruby's `^` and `$` match at every line). Character classes are ASCII: a digit is `0`–`9`, a hex digit is `[0-9a-fA-F]`, a letter is `A`–`Z` or `a`–`z`. `\d`, `\w` and `\s` are not used, because they match Unicode characters in some regex engines.

### Booleans in the output

[`boolean`](/validation-rules/boolean.html) outputs a real boolean: the value that the JSON encoder of the language writes as `true` or `false`. In Perl that is `JSON::PP::true` / `JSON::PP::false` (or `builtin::true` / `false` on 5.36+), not `1` and `0`. Implementations whose input booleans are objects (Perl's `JSON::PP::Boolean`) must treat them as primitive values with the string form `"true"` / `"false"`.
