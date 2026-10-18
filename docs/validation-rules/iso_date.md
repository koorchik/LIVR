---
title: iso_date
group: special
syntax: "'iso_date'"
example:
  rules: |-
    {
        birth_date: 'iso_date'
    }
  input: |-
    {
        birth_date: '2014-02-30'
    }
---

# iso_date

Checks that the value is an ISO 8601 date without time, for example `"2014-08-14"`.

Error codes: `WRONG_DATE`, `FORMAT_ERROR`

<RuleSandbox />
