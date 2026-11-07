---
title: luhn
group: checksum
since: '2.5'
syntax: "'luhn'"
example:
  rules: |-
    {
        code: 'luhn'
    }
  input: |-
    {
        code: '79927398710'
    }
---

# luhn

Checks that the value is at least 2 ASCII digits and that its Luhn mod 10 checksum is 0.

Error codes: `WRONG_CHECKSUM`, `FORMAT_ERROR`

<RuleSandbox />

`79927398713` passes, `79927398710` does not. The value is checked as it is: spaces and dashes are not removed, see [Checksum rules](/validation-rules/checksum-rules.html).

For payment card numbers, use [`credit_card`](/validation-rules/credit_card.html).
