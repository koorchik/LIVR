---
title: list_of
group: metarules
syntax: "{ list_of: 'positive_integer' }"
example:
  rules: |-
    {
        product_ids: { list_of: 'positive_integer' }
    }
  input: |-
    {
        product_ids: [3455, 'abc', 0, 3456]
    }
---

# list_of

Describes validation rules for a list. The rules are applied to every element.

Error codes: a list with the error of every element (`null` for valid elements), or `FORMAT_ERROR` if the value is not a list.

<RuleSandbox />

The rules were wrapped in an extra list before v0.4. Both syntaxes are supported:

```js
// new syntax (introduced in v0.4)
{ product_ids: { list_of: 'positive_integer' } }
{ product_ids: { list_of: ['required', 'positive_integer'] } }

// old syntax
{ product_ids: { list_of: [['positive_integer']] } }
{ product_ids: { list_of: [['required', 'positive_integer']] } }
```
