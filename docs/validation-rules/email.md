---
title: email
group: special
syntax: "'email'"
example:
  rules: |-
    {
        login: 'email'
    }
  input: |-
    {
        login: 'john.smith@'
    }
---

# email

Checks that the value is an email address.

Error codes: `WRONG_EMAIL`, `FORMAT_ERROR`

<RuleSandbox />
