---
title: contains
group: string
since: '2.5'
syntax: "{ contains: '@' }"
example:
  rules: |-
    {
        comment: { contains: '@' }
    }
  input: |-
    {
        comment: 'no mention here'
    }
---

# contains

Checks that the value contains at least one of the given strings.

Error codes: `WRONG_FORMAT`, `FORMAT_ERROR`

<RuleSandbox />

The arguments are one or more non-empty strings. The comparison is exact and case-sensitive; there is no normalization. The [string form](/validation-rules/how-it-works.html#string-form) of the value is checked and returned.

```js
{ comment: { contains: '@' } }
```

See also [`starts_with`](/validation-rules/starts_with.html) and [`ends_with`](/validation-rules/ends_with.html).
