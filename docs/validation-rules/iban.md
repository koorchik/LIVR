---
title: iban
group: checksum
since: '2.5'
syntax: "'iban'"
example:
  rules: |-
    {
        iban: [{ remove: ' -' }, 'to_uc', 'iban']
    }
  input: |-
    {
        iban: 'gb82 west 1234 5698 7654 31'
    }
---

# iban

Checks that the value is an IBAN (ISO 13616) with valid check digits.

Error codes: `WRONG_IBAN`, `FORMAT_ERROR`

<RuleSandbox />

- The value is 2 uppercase letters `A-Z`, 2 digits, then 11–30 characters from `A-Z0-9`: 15–34 characters in total.
- The check: move the first four characters to the end and replace every letter by two digits (`A` = 10 … `Z` = 35). The number modulo 97 is 1.
- There is no table of lengths per country.

`GB82WEST12345698765432` passes. The value is checked as it is, so remove spaces and convert it to uppercase before:

```js
{ iban: [{ remove: ' -' }, 'to_uc', 'iban'] }
```
