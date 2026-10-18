---
title: min_length
group: string
syntax: "{ min_length: 2 }"
example:
  rules: |-
    {
        first_name: { min_length: 2 }
    }
  input: |-
    {
        first_name: 'A'
    }
---

# min_length

Checks that the string is at least the given number of characters long.

Error codes: `TOO_SHORT`, `FORMAT_ERROR`

<RuleSandbox />
