---
title: values
group: metarules
since: '2.5'
syntax: "{ values: 'positive_integer' }"
example:
  rules: |-
    {
        stock: { values: ['required', 'positive_integer'] }
    }
  input: |-
    {
        stock: { 'sku-1': 0, 'sku-2': 15 }
    }
---

# values

Validates every value of an object with the same rules, as [`list_of`](/validation-rules/list_of.html) validates every item of a list. The keys can be any.

Error codes: an object with the errors of the failing keys only, or `FORMAT_ERROR` if the value is not an object.

<RuleSandbox />

```js
{ stock: { values: ['required', 'positive_integer'] } }
```

The arguments are the same as in `list_of`: `{ values: ['required', 'string'] }` and `{ values: [['required', 'string']] }` are the same. An empty list `[]` is a [schema error](/validation-rules/how-it-works.html#arguments).

- A list or a primitive value gives `FORMAT_ERROR`.
- The errors are an object with the failing keys only: `{ stock: { 'sku-1': 'NOT_POSITIVE_INTEGER' } }`.
- The output is an object with the same keys and the output values.
- An empty object `{}` passes.

To check the keys as well, combine it with [`keys`](/validation-rules/keys.html).
