---
title: min_number
group: numeric
syntax: "{ min_number: 18 }"
example:
  rules: |-
    {
        age: { min_number: 18 }
    }
  input: |-
    {
        age: 16
    }
---

# min_number

Checks that the number is not less than the given value.

Error codes: `TOO_LOW`, `NOT_NUMBER`, `FORMAT_ERROR`

<RuleSandbox />
