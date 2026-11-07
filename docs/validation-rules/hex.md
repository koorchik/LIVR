---
title: hex
group: format
since: '2.5'
syntax: "'hex'"
example:
  rules: |-
    {
        data: 'hex'
    }
  input: |-
    {
        data: '0xFF'
    }
---

# hex

Checks that the value is a string of hex digits `0-9a-fA-F`, without the `0x` prefix.

Error codes: `WRONG_HEX`, `FORMAT_ERROR`

<RuleSandbox />

The case of the input is kept in the output.
