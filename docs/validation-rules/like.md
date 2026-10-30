---
title: like
group: string
syntax: "{ like: '^[0-9]+$' }"
example:
  rules: |-
    {
        zip: { like: '^[0-9]{5}$' }
    }
  input: |-
    {
        zip: '1234'
    }
---

# like

Checks that the value matches a regular expression.

`^` at the start and `$` at the end of the pattern match only at the start and the end of the value, the way [RFC 9485](https://www.rfc-editor.org/rfc/rfc9485) (I-Regexp) maps a pattern to regex engines. `{ like: '^[0-9]{5}$' }` rejects `"12345\n"` and `"12345\n<script>"`. In languages where `$` also matches before a trailing newline (Perl, PHP, Python, Ruby and others), implementations use `\z` or a similar option.

Error codes: `WRONG_FORMAT`, `FORMAT_ERROR`

<RuleSandbox />

Pass flags as the second element of a list:

```js
{ first_name: { like: ['^[a-z]+$', 'i'] } }
```

Only the `i` flag is currently required by the specification.

::: warning Experimental
Regular expression syntax differs between languages. Use the subset that every regex engine supports: the syntax of I-Regexp plus `^` at the start and `$` at the end of the pattern. Write `[0-9]` instead of `\d`, and don't use lookarounds, backreferences or lazy quantifiers. This rule is experimental, as it needs stricter semantics.
:::
