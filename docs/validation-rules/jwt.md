---
title: jwt
group: format
since: '2.5'
syntax: "'jwt'"
example:
  rules: |-
    {
        token: 'jwt'
    }
  input: |-
    {
        token: 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIn0.c2ln'
    }
---

# jwt

Checks that the value has the structure of a JSON Web Token: `header.payload.signature` in base64url, the JWS compact serialization (RFC 7515, section 7.1). The token is not decoded or verified.

Error codes: `WRONG_JWT`, `FORMAT_ERROR`

<RuleSandbox />

The value is three segments separated by `.`:

- The header and the payload are non-empty base64url (`A-Za-z0-9-_`) without padding.
- The signature is base64url without padding, or empty (an unsecured JWT, `alg: "none"`).
- No segment has a length of 1 modulo 4: no bytes give such a base64url length.

The rule is an early filter: a client that sends something else gets `WRONG_JWT` instead of a decoding error later. The header, `alg` and the signature are not checked, so the application still decodes and verifies the token. JWE tokens (five segments) do not pass. Remove a `Bearer ` prefix before the rule.

```js
{ token: ['required', 'jwt'] }
```
