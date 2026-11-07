---
title: required_if
group: common
since: '2.5'
syntax: "{ required_if: { type: 'company' } }"
example:
  rules: |-
    {
        type: ['required', { one_of: ['person', 'company', 'ngo'] }],
        vat: { required_if: { type: ['company', 'ngo'] } }
    }
  input: |-
    {
        type: 'company'
    }
---

# required_if

Makes the field required when other fields have the given values.

Error code: `REQUIRED`

<RuleSandbox />

```js
{
    type:    ['required', { one_of: ['person', 'company', 'ngo'] }],
    company: { required_if: { type: 'company' } },
    vat:     { required_if: { type: ['company', 'ngo'] } },
    zip:     { required_if: { 'address/country': 'UA' } }
}
```

The argument is an object with at least one entry. Each key is a [reference](/validation-rules/how-it-works.html#field-references) to another field, each value is a primitive value other than `null`, or a non-empty list of such values.

- An entry matches when the referenced value is a primitive value, is not empty, and equals the given value or one of the listed values. Values are [compared as strings](/validation-rules/how-it-works.html#comparison).
- When all entries match, the field is required: an empty value gives `REQUIRED`. Otherwise the rule passes.
- The output is the value unchanged.

The referenced value is the input, before the rules of that field. So `{ subscribe: true }` matches `true` and `"true"`, but not `"1"` or `"on"` that a form sends for a checkbox, and `{ type: 'company' }` does not match `"Company"` even if `type` has [`to_lc`](/validation-rules/to_lc.html). For checkboxes use [`when`](/validation-rules/when.html) with `boolean` in the condition:

```js
{ email: ['email', { when: ['subscribe', ['boolean', { eq: true }], 'required'] }] }
```

`''` as a value, alone or in a list, is a [schema error](/validation-rules/how-it-works.html#arguments), because an empty referenced value never matches. So is an empty list `[]`: it never matches either.
