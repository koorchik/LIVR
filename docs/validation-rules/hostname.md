---
title: hostname
group: format
since: '2.5'
syntax: "'hostname'"
example:
  rules: |-
    {
        host: 'hostname'
    }
  input: |-
    {
        host: 'my_server.example.com'
    }
---

# hostname

Checks that the value is a hostname (RFC 1123), for example `api.example.com` or `localhost`.

Error codes: `WRONG_HOSTNAME`, `FORMAT_ERROR`

<RuleSandbox />

- Labels of 1–63 characters from `A-Za-z0-9-`, not starting or ending with `-`, separated by `.`.
- At most 253 characters in total, no trailing dot.
- A single label (`localhost`) passes. Labels of digits only pass too, except the last one: `192.0.2.1` and `123` give `WRONG_HOSTNAME` (RFC 1123, section 2.1). So a hostname is never an IPv4 address; use `{ or: ['hostname', 'ip'] }` to accept both.
- There is no list of top-level domains. Internationalized names pass only as punycode.
