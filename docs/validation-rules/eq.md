---
title: eq
group: string
syntax: "{ eq: 'Anton' }"
example:
  rules: |-
    {
        first_name: { eq: 'Anton' }
    }
  input: |-
    {
        first_name: 'Igor'
    }
---

# eq

Checks that the value is equal to the given one. Values are compared as strings, and the output is the value from the rule.

Error codes: `NOT_ALLOWED_VALUE`, `FORMAT_ERROR`

<RuleSandbox />

See [Types coercing](/validation-rules/types-coercing.html) for how values are compared.
