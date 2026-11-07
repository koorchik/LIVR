---
title: max_decimals
group: numeric
since: '2.5'
syntax: "{ max_decimals: 2 }"
example:
  rules: |-
    {
        amount: { max_decimals: 2 }
    }
  input: |-
    {
        amount: '10.505'
    }
---

# max_decimals

Checks that the number has at most the given number of digits after the decimal point, and returns it as a number.

Error codes: `TOO_MANY_DECIMALS`, `NOT_NUMBER`, `FORMAT_ERROR`

<RuleSandbox />

The argument is a non-negative integer. The value is a JSON number or a string in the grammar of [`decimal`](/validation-rules/decimal.html), see [Numbers](/validation-rules/how-it-works.html#numbers). A string too large for a finite double (a `1` with 400 zeros) gives `NOT_NUMBER`, because the output is a number and JSON has no infinity.

- Trailing zeros after the decimal point do not count, so a string and a JSON number with the same value give the same result: `"1.230"` and `1.230` have 2 digits, `"5.000"` has none.
- A JSON number is counted in its [string form](/validation-rules/how-it-works.html#string-form). A string is counted as it is written, without the trailing zeros, so `"0.10000000000000000001"` has 20 digits even though a double cannot hold it exactly.
