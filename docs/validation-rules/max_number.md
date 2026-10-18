---
title: max_number
group: numeric
syntax: "{ max_number: 95 }"
example:
  rules: |-
    {
        age: { max_number: 95 }
    }
  input: |-
    {
        age: 120
    }
---

# max_number

Checks that the number is not greater than the given value.

Error codes: `TOO_HIGH`, `NOT_NUMBER`, `FORMAT_ERROR`

<RuleSandbox />
