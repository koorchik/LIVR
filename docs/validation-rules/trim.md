---
title: trim
group: modifiers
syntax: "'trim'"
example:
  rules: |-
    {
        email: ['trim', 'email']
    }
  input: |-
    {
        email: '  john@mail.com '
    }
---

# trim

Removes leading and trailing whitespace.

<RuleSandbox />
