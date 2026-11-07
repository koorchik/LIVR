---
title: base64
group: format
since: '2.5'
syntax: "'base64'"
example:
  rules: |-
    {
        file: 'base64',
        token: { base64: 'url' }
    }
  input: |-
    {
        file: 'aGVsbG8=',
        token: 'aGVsbG8+'
    }
---

# base64

Checks that the value is a Base64 string (RFC 4648).

Error codes: `WRONG_BASE64`, `FORMAT_ERROR`

<RuleSandbox />

- `'base64'`: the standard alphabet `A-Za-z0-9+/`, the length is a multiple of 4, and the padding `=` or `==` may appear only at the end.
- `{ base64: 'url' }`: the URL-safe alphabet `A-Za-z0-9-_`, and the padding is optional. Either there is no `=` and the length modulo 4 is 2, 3 or 0, or the padding is complete and the length is a multiple of 4. Partial padding fails: `'SA='` gives `WRONG_BASE64`, while `'SA'` and `'SA=='` pass.

No whitespace or line breaks are allowed. The unused bits of the last character are not checked.

There is no option for the standard alphabet without padding (`'relaxed'` in js-livr-extra-rules). An options object may add it later.
