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

Checks that the value is equal to the value of another field, for example a password confirmation. Values are compared as strings: `"10"` and `10` are equal, while `"10"` and `"1e1"` are not. A missing field is not equal to any value.

Error codes: `FIELDS_NOT_EQUAL`, `FORMAT_ERROR`

<RuleSandbox />
