---
title: string
group: string
syntax: "'string'"
example:
  rules: |-
    {
        payload: ['required', 'string']
    }
  input: |-
    {
        payload: 25
    }
---

# string

Checks that the value is a primitive type and converts it to a string, for example `25` becomes `"25"`. Prefer stricter rules where possible.

Error code: `FORMAT_ERROR`

<RuleSandbox />

You can treat this rule as a modifier.
