---
title: positive_integer
group: numeric
syntax: "'positive_integer'"
example:
  rules: |-
    {
        quantity: 'positive_integer'
    }
  input: |-
    {
        quantity: 0
    }
---

# positive_integer

Checks that the value is an integer greater than zero.

Error codes: `NOT_POSITIVE_INTEGER`, `FORMAT_ERROR`

<RuleSandbox />
