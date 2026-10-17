# Core concepts

## LIVR specification

The goal was a validator that does not depend on the programming language, something like Mustache or Handlebars, but for data validation. So we started by writing a specification.

**The specification:**

1. Standardizes the format for describing validation rules.
2. Describes the minimal set of validation rules that every implementation must support.
3. Standardizes error codes.
4. Serves as the basic documentation for all implementations.
5. Includes a [test suite](/how-to-contribute/test-suite.html) that checks an implementation for compliance with the specification.

The specification is this website: start with [validation rules](/validation-rules.html), [how it works](/validation-rules/how-it-works.html) and [rules aliasing](/rules-aliasing.html).

The main idea is that validation rules look like a data schema: the rules have the same shape as the data, with rules in place of values. See the [examples](/introduction/examples.html).

## Why not JSON Schema? {#why-not-json-schema}

This is a frequently asked question. JSON Schema is a great format for *describing* data. It has a rich ecosystem, and OpenAPI is built on it. LIVR is designed for a narrower task: *validating and cleaning* input data in application code. Here is the registration form from the [examples](/introduction/examples.html) in both formats.

::: code-group

```js [LIVR]
{
    name: 'required',
    email: ['required', 'email'],
    gender: { one_of: ['male', 'female'] },
    phone: { max_length: 10 },
    password: ['required', { min_length: 10 }],
    password2: { equal_to_field: 'password' }
}
```

```json [JSON Schema (2020-12)]
{
    "type": "object",
    "properties": {
        "name":      { "type": "string", "minLength": 1 },
        "email":     { "type": "string", "format": "email" },
        "gender":    { "enum": ["male", "female"] },
        "phone":     { "type": "string", "maxLength": 10 },
        "password":  { "type": "string", "minLength": 10 },
        "password2": { "type": "string" }
    },
    "required": ["name", "email", "password"],
    "additionalProperties": false
}
```

:::

The differences that matter for input validation:

| | LIVR | JSON Schema |
|---|---|---|
| Rules of a field | All in one place, next to the field | Split between `properties` and the `required` list |
| Required fields | `required` also rejects empty strings | `required` only checks that the key exists, so you also need `minLength: 1` |
| Comparing fields | `equal_to_field` | No standard keyword (some validators offer a non-standard `$data` extension) |
| `email` format | Always checked | `format` is only an annotation by default; validators are not required to check it |
| Unknown fields | Removed from the output | Either allowed, or the whole object is rejected (`additionalProperties: false`) |
| Errors | Error codes shaped like the data: `{ email: 'WRONG_EMAIL' }` | Error locations are standardized, but messages and codes differ between validators |
| Data cleanup | Modifiers: `trim`, `to_lc`, `default`, … | Not part of the standard |
| Values from forms and query strings | `positive_integer` accepts `"25"` and returns `25` | `"type": "integer"` rejects the string `"25"` |

Some things that need a dedicated keyword in JSON Schema are just one more rule in LIVR. For example, the number of list items is checked by the `list_length` rule from [livr-extra-rules](https://github.com/koorchik/js-livr-extra-rules).
