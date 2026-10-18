---
title: not_empty
group: common
syntax: "'not_empty'"
example:
  rules: |-
    {
        first_name: 'not_empty',
        middle_name: 'not_empty'
    }
  input: |-
    {
        first_name: ''
    }
---

# not_empty

Checks that the value is not an empty string, if the field is passed at all. Unlike `required`, a missing field is valid.

Error code: `CANNOT_BE_EMPTY`

<RuleSandbox />
