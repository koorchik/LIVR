---
title: ends_with
group: string
since: '2.5'
syntax: "{ ends_with: '.pdf' }"
example:
  rules: |-
    {
        file: { ends_with: '.pdf' }
    }
  input: |-
    {
        file: 'report.PDF'
    }
---

# ends_with

Checks that the value ends with one of the given strings.

Error codes: `WRONG_FORMAT`, `FORMAT_ERROR`

<RuleSandbox />

The arguments are one or more non-empty strings. The comparison is exact and case-sensitive; there is no normalization. The [string form](/validation-rules/how-it-works.html#string-form) of the value is checked and returned.

```js
{ file: { ends_with: '.pdf' } }
{ file: { ends_with: ['.jpg', '.jpeg', '.png'] } }
```

See also [`starts_with`](/validation-rules/starts_with.html) and [`contains`](/validation-rules/contains.html).
