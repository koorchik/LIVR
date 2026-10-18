---
title: to_uc
group: modifiers
syntax: "'to_uc'"
example:
  rules: |-
    {
        currency_code: ['to_uc', { length_equal: 3 }]
    }
  input: |-
    {
        currency_code: 'uah'
    }
---

# to_uc

Converts the string to upper case.

<RuleSandbox />
