---
title: ip
group: format
since: '2.5'
syntax: "'ip', { ip: 'v4' }"
example:
  rules: |-
    {
        server: 'ip',
        gateway: { ip: 'v4' }
    }
  input: |-
    {
        server: '2001:db8::1',
        gateway: '010.0.0.1'
    }
---

# ip

Checks that the value is an IPv4 or an IPv6 address.

Error codes: `WRONG_IP`, `FORMAT_ERROR`

<RuleSandbox />

`{ ip: 'v4' }` accepts IPv4 only, `{ ip: 'v6' }` IPv6 only, `'ip'` both.

- IPv4: four decimal numbers `0`–`255` separated by `.`, without leading zeros. `010.0.0.1` is rejected: some systems read it as octal.
- IPv6: the text forms of RFC 4291, section 2.2: eight groups of 1–4 hex digits separated by `:`. One `::` may replace one or more groups of zeros. The last two groups may be an IPv4 address in the form above (`::ffff:192.0.2.1`). No zone ID (`%eth0`), no brackets, no prefix length.

For an address with a prefix length, use [`cidr`](/validation-rules/cidr.html).
