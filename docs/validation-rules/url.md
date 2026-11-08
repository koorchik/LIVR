---
title: url
group: special
syntax: "'url'"
example:
  rules: |-
    {
        homepage: 'url'
    }
  input: |-
    {
        homepage: 'ftp://example.com'
    }
---

# url

Checks that the value is a URL. Only the `http` and `https` protocols are allowed, and the protocol is required.

Error codes: `WRONG_URL`, `FORMAT_ERROR`

<RuleSandbox />

## Host and port <Badge type="info" text="LIVR 2.5" /> {#host-and-port}

::: info LIVR 2.5
These checks were fixed in [LIVR 2.5](/changes.html#v2-5). Implementations of LIVR 2.0 may accept a dot after the host, longer labels and bigger ports, and reject one-digit ports.
:::

- No dot after the host: `https://www.google.`, `https://example.com./path` and `https://example.com.:8080` give `WRONG_URL`. DNS allows a dot at the end of a name, but in a URL it is almost always a typo, and [`hostname`](/validation-rules/hostname.html) rejects it too. A dot in the path or the query is fine: `https://example.com/file.` passes.
- A label of the host (the part between dots) has at most 63 characters, the top-level domain too.
- A port has 1–5 digits and is at most 65535: `https://example.com:8` and `https://example.com:65535` pass, `https://example.com:65536` gives `WRONG_URL`.

The rest of the grammar differs between implementations and is decided in LIVR 3.0: Unicode and punycode hosts, IPv6 addresses, user info and hosts without a dot, such as `localhost`.
