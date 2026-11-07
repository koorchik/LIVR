---
title: cidr
group: format
since: '2.5'
syntax: "'cidr', { cidr: 'v4' }"
example:
  rules: |-
    {
        network: { cidr: 'v4' }
    }
  input: |-
    {
        network: '192.0.2.0/33'
    }
---

# cidr

Checks that the value is an IP address with a prefix length, for example `192.0.2.0/24`.

Error codes: `WRONG_CIDR`, `FORMAT_ERROR`

<RuleSandbox />

The value is an [`ip`](/validation-rules/ip.html) address, `/` and a prefix length: `0`–`32` for IPv4, `0`–`128` for IPv6, decimal without leading zeros. Host bits may be set: `10.0.0.1/8` passes.

`{ cidr: 'v4' }` accepts IPv4 only, `{ cidr: 'v6' }` IPv6 only, `'cidr'` both, as in [`ip`](/validation-rules/ip.html).
