---
title: boolean
group: common
since: '2.5'
syntax: "'boolean'"
example:
  rules: |-
    {
        subscribe: 'boolean'
    }
  input: |-
    {
        subscribe: 'yes'
    }
---

# boolean

Checks that the value is a boolean, `1`, `0`, or one of the strings `"1"`, `"0"`, `"true"` and `"false"`, and returns a real boolean.

Error codes: `NOT_BOOLEAN`, `FORMAT_ERROR`

<RuleSandbox />

| Input | Output |
|---|---|
| `true`, `1`, `"1"`, `"true"` | `true` |
| `false`, `0`, `"0"`, `"false"` | `false` |

Any other primitive value gives `NOT_BOOLEAN`. Strings are case-sensitive: `"True"` gives `NOT_BOOLEAN`.
