---
title: like
group: string
syntax: "{ like: '^\\\\d+$' }"
example:
  rules: |-
    {
        zip: { like: '^\\d{5}$' }
    }
  input: |-
    {
        zip: '1234'
    }
---

# like

Checks that the value matches a regular expression.

Error codes: `WRONG_FORMAT`, `FORMAT_ERROR`

<RuleSandbox />

Pass flags as the second element of a list:

```js
{ first_name: { like: ['^\\w+?$', 'i'] } }
```

Only the `i` flag is currently required by the specification.

::: warning Experimental
Regular expression syntax differs between languages. Use the most common syntax. This rule is experimental, as it needs stricter semantics.
:::
