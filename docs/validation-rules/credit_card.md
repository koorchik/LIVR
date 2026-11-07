---
title: credit_card
group: checksum
since: '2.5'
syntax: "'credit_card'"
example:
  rules: |-
    {
        card: 'credit_card'
    }
  input: |-
    {
        card: '4111 1111 1111 1111'
    }
---

# credit_card

Checks that the value is a payment card number: 12–19 ASCII digits (ISO/IEC 7812) with a valid Luhn checksum.

Error codes: `WRONG_CREDIT_CARD_NUMBER`, `FORMAT_ERROR`

<RuleSandbox />

The card network is not detected. The value is checked as it is, so remove spaces and dashes before:

```js
{ card: ['required', { remove: ' -' }, 'credit_card'] }
```
