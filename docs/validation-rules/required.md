---
title: required
group: common
syntax: "'required'"
example:
  rules: |-
    {
        first_name: 'required',
        last_name: 'required'
    }
  input: |-
    {
        first_name: 'Viktor',
        last_name: ''
    }
---

# required

Checks that the value is present: not missing, not `null` and not an empty string. Note that `0` and `false` are valid values.

Error code: `REQUIRED`

<RuleSandbox />

All other rules except [`not_empty`](/validation-rules/not_empty.html) and [`not_empty_list`](/validation-rules/not_empty_list.html) skip empty values, so combine them with `required` for mandatory fields:

```js
{ first_name: ['required', { min_length: 2 }] }
```
