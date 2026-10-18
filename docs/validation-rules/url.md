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
