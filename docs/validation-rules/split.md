---
title: split
group: modifiers
since: '2.5'
syntax: "{ split: ',' }"
example:
  rules: |-
    {
        ids: [{ split: ',' }, { list_of: 'positive_integer' }]
    }
  input: |-
    {
        ids: '1,2,3'
    }
---

# split

Splits a string into a list at every separator. The separator is a non-empty string, not a regular expression.

<RuleSandbox />

```js
{ ids: [{ split: ',' }, { list_of: 'positive_integer' }] }
```

It is a modifier, so it never fails:

- A string is split at every separator: `"1,2,3"` gives `["1", "2", "3"]`, `"5"` gives `["5"]`. Empty parts are kept: `"a,,b"` gives `["a", "", "b"]`.
- A list stays as it is, so `?id=5&id=6` and `?ids=5,6` both give a list.
- A number or a boolean is split in its [string form](/validation-rules/how-it-works.html#string-form), like a string: `5` gives `["5"]`, `1.5` with `"."` gives `["1", "5"]`, `true` gives `["true"]`.
- An empty value and an object stay as they are; the next rule reports them.

This also covers inputs from query strings that can be a scalar or a list.
