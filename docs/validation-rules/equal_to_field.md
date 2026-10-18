---
title: equal_to_field
group: special
syntax: "{ equal_to_field: 'password' }"
example:
  rules: |-
    {
        password: 'required',
        password2: { equal_to_field: 'password' }
    }
  input: |-
    {
        password: 'secret123',
        password2: 'secret124'
    }
---

# equal_to_field

Checks that the value is equal to the value of another field, for example a password confirmation.

Error codes: `FIELDS_NOT_EQUAL`, `FORMAT_ERROR`

<RuleSandbox />
