---
title: remove
group: modifiers
syntax: "{ remove: '-() ' }"
example:
  rules: |-
    {
        phone: { remove: '-() ' }
    }
  input: |-
    {
        phone: '+38 (044) 123-45-67'
    }
---

# remove

Removes the given characters from the string.

<RuleSandbox />
