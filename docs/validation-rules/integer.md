---
title: integer
group: numeric
syntax: "'integer'"
example:
  rules: |-
    {
        floor: 'integer'
    }
  input: |-
    {
        floor: '2.5'
    }
---

# integer

Checks that the value is an integer. Strings that look like integers are accepted and returned as numbers.

Error codes: `NOT_INTEGER`, `FORMAT_ERROR`

<RuleSandbox />
