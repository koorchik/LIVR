---
title: decimal
group: numeric
syntax: "'decimal'"
example:
  rules: |-
    {
        price: 'decimal'
    }
  input: |-
    {
        price: '12.50'
    }
---

# decimal

Checks that the value is a number, an integer or a decimal. Strings that look like numbers are accepted and returned as numbers.

Error codes: `NOT_DECIMAL`, `FORMAT_ERROR`

<RuleSandbox />
