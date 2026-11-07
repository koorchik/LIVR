---
title: digest
group: format
since: '2.5'
syntax: "{ digest: 'sha256' }"
example:
  rules: |-
    {
        checksum: { digest: ['sha256', 'sha512'] }
    }
  input: |-
    {
        checksum: 'd41d8cd98f00b204e9800998ecf8427e'
    }
---

# digest

Checks that the value is a hex digest of one of the given hash algorithms.

Error codes: `WRONG_DIGEST`, `FORMAT_ERROR`

<RuleSandbox />

The arguments are one or more algorithms. The value is hex digits `0-9a-fA-F` of the length of one of them:

| Algorithm | Length |
|---|---|
| `md5` | 32 |
| `sha1` | 40 |
| `sha256` | 64 |
| `sha384` | 96 |
| `sha512` | 128 |

```js
{ etag:     { digest: 'md5' } }
{ checksum: { digest: ['sha256', 'sha512'] } }
```

Only the length and the characters are checked. The case of the input is kept in the output.

The rule is not called `hash`: in Perl and in the LIVR test suite, a hash is an object.
