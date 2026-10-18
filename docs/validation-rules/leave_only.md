---
title: leave_only
group: modifiers
syntax: "{ leave_only: '0123456789' }"
example:
  rules: |-
    {
        phone: { leave_only: '0123456789' }
    }
  input: |-
    {
        phone: '+38 (044) 123-45-67'
    }
---

# leave_only

Removes all characters except the given ones.

<RuleSandbox />
