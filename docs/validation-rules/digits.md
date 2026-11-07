---
title: digits
group: string
since: '2.5'
syntax: "'digits'"
example:
  rules: |-
    {
        zip: 'digits',
        otp: ['digits', { length_equal: 6 }]
    }
  input: |-
    {
        zip: '01001',
        otp: '12a456'
    }
---

# digits

Checks that the value consists of ASCII digits `0-9` only. Unlike `positive_integer`, leading zeros are kept and the output is a string.

Error codes: `NOT_DIGITS`, `FORMAT_ERROR`

<RuleSandbox />

The [string form](/validation-rules/how-it-works.html#string-form) of the value must be one or more digits: `"007"` gives `"007"`, `7` gives `"7"`.

```js
{ zip: 'digits', otp: ['digits', { length_equal: 6 }] }
```
