---
title: default
group: modifiers
syntax: "{ default: 18 }"
example:
  rules: |-
    {
        age: { default: 18 },
        country: { default: 'UA' }
    }
  input: |-
    {
        country: 'PL'
    }
---

# default

Sets the value if it is empty: missing, `null` or an empty string. Other values, including `0`, are kept.

<RuleSandbox />
