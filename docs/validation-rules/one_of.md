---
title: one_of
group: string
syntax: "{ one_of: ['a', 'b'] }"
example:
  rules: |-
    {
        gender: { one_of: ['male', 'female'] }
    }
  input: |-
    {
        gender: 'unknown'
    }
---

# one_of

Checks that the value is one of the allowed values. Values are compared as strings, and the output is the value from the rule.

Error codes: `NOT_ALLOWED_VALUE`, `FORMAT_ERROR`

<RuleSandbox />

The values were wrapped in an extra list before v0.4. Both syntaxes are supported:

```js
{ first_name: { one_of: ['Anton', 'Igor'] } }   // new syntax (introduced in v0.4)
{ first_name: { one_of: [['Anton', 'Igor']] } } // old syntax
```
