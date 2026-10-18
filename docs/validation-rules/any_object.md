---
title: any_object
group: common
syntax: "'any_object'"
example:
  rules: |-
    {
        settings: 'any_object'
    }
  input: |-
    {
        settings: 'dark mode'
    }
---

# any_object

Checks that the value is a plain object (a hash, a dictionary). The content of the object is not validated, use [`nested_object`](/validation-rules/nested_object.html) for that.

Error code: `FORMAT_ERROR` if the value is not a plain object.

<RuleSandbox />
