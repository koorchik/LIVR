---
title: any
group: common
since: '2.5'
syntax: "'any'"
example:
  rules: |-
    {
        metadata: 'any'
    }
  input: |-
    {
        metadata: { source: 'import', tags: ['a', 'b'] }
    }
---

# any

Accepts any JSON value, including objects and lists, and returns it unchanged.

Error codes: none

<RuleSandbox />

Unlike [`any_object`](/validation-rules/any_object.html), it accepts every type. Unlike a field without rules, the value is kept in the output.

Use [`string`](/validation-rules/string.html) for strings: `any` is for JSON blobs.

::: warning
Removing unknown fields is a security property of LIVR, and `any` turns it off for its value.
:::
