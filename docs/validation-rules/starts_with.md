---
title: starts_with
group: string
since: '2.5'
syntax: "{ starts_with: 'https://' }"
example:
  rules: |-
    {
        website: { starts_with: ['https://', 'http://'] }
    }
  input: |-
    {
        website: 'ftp://example.com'
    }
---

# starts_with

Checks that the value starts with one of the given strings.

Error codes: `WRONG_FORMAT`, `FORMAT_ERROR`

<RuleSandbox />

The arguments are one or more non-empty strings. The comparison is exact and case-sensitive; there is no normalization. The [string form](/validation-rules/how-it-works.html#string-form) of the value is checked and returned.

```js
{ website: { starts_with: ['https://', 'http://'] } }
```

See also [`ends_with`](/validation-rules/ends_with.html) and [`contains`](/validation-rules/contains.html).
