---
title: length_equal
group: string
syntax: "{ length_equal: 2 }"
example:
  rules: |-
    {
        country_code: { length_equal: 2 }
    }
  input: |-
    {
        country_code: 'UKR'
    }
---

# length_equal

Checks that the string is exactly the given number of characters long.

Error codes: `TOO_LONG`, `TOO_SHORT`, `FORMAT_ERROR`

<RuleSandbox />
