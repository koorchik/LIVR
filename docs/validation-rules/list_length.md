---
title: list_length
group: list
since: '2.5'
syntax: "{ list_length: [1, 10] }"
example:
  rules: |-
    {
        tags: { list_length: [1, 3] }
    }
  input: |-
    {
        tags: ['a', 'b', 'c', 'd']
    }
---

# list_length

Checks the number of items in a list.

Error codes: `TOO_FEW_ITEMS`, `TOO_MANY_ITEMS`, `FORMAT_ERROR`

<RuleSandbox />

The arguments are a non-negative integer (the exact length), two non-negative integers `min, max`, or an object with `min`, `max` or both:

```js
{ tags:   { list_length: [1, 10] } }
{ pair:   { list_length: 2 } }
{ items:  { list_length: { max: 100 } } }
{ photos: { list_length: { min: 1 } } }
```

The first argument and the count select the form: an object first is the options form, otherwise two or more arguments are `min, max`, and one is the exact length. So `{ list_length: [3, 'x'] }` is a schema error, not an exact length of 3.

- The value must be a list, otherwise `FORMAT_ERROR`.
- Too few items give `TOO_FEW_ITEMS`, too many give `TOO_MANY_ITEMS`.
- An empty list `[]` is a value, not an empty value: `{ list_length: { min: 1 } }` rejects it.
- The output is the value unchanged.
