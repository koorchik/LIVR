---
title: length_between
group: string
syntax: "{ length_between: [2, 10] }"
example:
  rules: |-
    {
        first_name: { length_between: [2, 10] }
    }
  input: |-
    {
        first_name: 'A'
    }
---

# length_between

Checks that the length of the string is between the two values, inclusive.

Error codes: `TOO_LONG`, `TOO_SHORT`, `FORMAT_ERROR`

<RuleSandbox />
