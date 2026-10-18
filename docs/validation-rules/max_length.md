---
title: max_length
group: string
syntax: "{ max_length: 10 }"
example:
  rules: |-
    {
        first_name: { max_length: 10 }
    }
  input: |-
    {
        first_name: 'Maximilian-Alexander'
    }
---

# max_length

Checks that the string is not longer than the given number of characters.

Error codes: `TOO_LONG`, `FORMAT_ERROR`

<RuleSandbox />
