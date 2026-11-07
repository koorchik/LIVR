---
title: not_one_of
group: string
since: '2.5'
syntax: "{ not_one_of: ['admin', 'root'] }"
example:
  rules: |-
    {
        username: { not_one_of: ['admin', 'root'] }
    }
  input: |-
    {
        username: 'admin'
    }
---

# not_one_of

Checks that the value is not equal to any of the given values. Values are compared as strings, and the output is the value unchanged.

Error codes: `NOT_ALLOWED_VALUE`, `FORMAT_ERROR`

<RuleSandbox />

The arguments are one or more forbidden primitive values. A single value can be passed as is:

```js
{ username: { not_one_of: ['admin', 'root'] } }
{ status:   { not_one_of: 'deleted' } }
```

`1` equals `"1"` and `true` equals `"true"`, but `"1.0"` does not equal `1`. See [Comparison](/validation-rules/how-it-works.html#comparison).
