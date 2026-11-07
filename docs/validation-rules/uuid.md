---
title: uuid
group: format
since: '2.5'
syntax: "'uuid', { uuid: 'v4' }"
example:
  rules: |-
    {
        id: 'uuid',
        token: { uuid: ['v4', 'v7'] }
    }
  input: |-
    {
        id: '00000000-0000-0000-0000-000000000000',
        token: '6ba7b810-9dad-11d1-80b4-00c04fd430c8'
    }
---

# uuid

Checks that the value is a UUID (RFC 9562), of any version or of the given versions.

Error codes: `WRONG_UUID`, `FORMAT_ERROR`

<RuleSandbox />

The format is `HEX{8}-HEX{4}-HEX{4}-HEX{4}-HEX{12}`. The version digit is the first digit of the third group, the variant digit is the first digit of the fourth group.

- Without arguments, `'uuid'`: the version digit is `1`–`8` and the variant digit is `8`, `9`, `a` or `b`. The nil UUID (`00000000-0000-0000-0000-000000000000`) and the max UUID (`ffffffff-ffff-ffff-ffff-ffffffffffff`) also pass.
- With versions, `{ uuid: 'v4' }` or `{ uuid: ['v4', 'v7'] }`: the version digit is one of the given ones and the variant is `8`, `9`, `a` or `b`. Nil and max do not pass.

The versions are the strings `'v1'` … `'v8'`, like `'v4'` and `'v6'` of [`ip`](/validation-rules/ip.html) and [`cidr`](/validation-rules/cidr.html). Hex digits are case-insensitive, and the case of the input is kept in the output.
