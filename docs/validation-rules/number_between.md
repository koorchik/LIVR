---
title: number_between
group: numeric
syntax: "{ number_between: [18, 95] }"
example:
  rules: |-
    {
        age: { number_between: [18, 95] }
    }
  input: |-
    {
        age: '17'
    }
---

# number_between

Checks that the number is between the two values, inclusive.

Error codes: `TOO_HIGH`, `TOO_LOW`, `NOT_NUMBER`, `FORMAT_ERROR`

<RuleSandbox />
