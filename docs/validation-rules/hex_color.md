---
title: hex_color
group: format
since: '2.5'
syntax: "'hex_color'"
example:
  rules: |-
    {
        color: 'hex_color'
    }
  input: |-
    {
        color: 'ff8800'
    }
---

# hex_color

Checks that the value is a hex color: `#` and 3, 4, 6 or 8 hex digits, for example `#f80` or `#FF8800`.

Error codes: `WRONG_HEX_COLOR`, `FORMAT_ERROR`

<RuleSandbox />

Hex digits are case-insensitive, and the case of the input is kept in the output.
