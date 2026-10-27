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

`^` and `$` match only at the start and the end of the value, as in JavaScript without the `m` flag. `{ like: '^\\d{5}$' }` rejects `"12345\n"` and `"12345\n<script>"`. In languages where `$` also matches before a trailing newline (Perl, PHP, Python, Ruby and others), implementations use `\z` or a similar option.

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
