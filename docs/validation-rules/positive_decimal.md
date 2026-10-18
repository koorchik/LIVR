---
title: positive_decimal
group: numeric
syntax: "'positive_decimal'"
example:
  rules: |-
    {
        price: 'positive_decimal'
    }
  input: |-
    {
        price: -5
    }
---

# positive_decimal

Checks that the value is a number greater than zero.

Error codes: `NOT_POSITIVE_DECIMAL`, `FORMAT_ERROR`

<RuleSandbox />
