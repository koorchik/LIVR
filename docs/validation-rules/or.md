---
title: or
group: metarules
syntax: "{ or: ['email', 'positive_integer'] }"
example:
  rules: |-
    {
        id: { or: ['email', 'positive_integer'] }
    }
  input: |-
    {
        id: 'abc'
    }
---

# or <Badge type="warning" text="experimental" />

Takes several sets of rules and applies them one after another until one of them succeeds.

Error codes: when every set of rules fails, it is unclear which error to return. Currently the error of the last set is returned. This behavior can change in the future, as the rule is experimental.

<RuleSandbox />

This rule simplifies alias creation, see [Rules aliasing](/rules-aliasing.html). It is a good idea to define a custom error code for such an alias.

Combined with other rules:

```js
{ id: [{ or: ['email', 'positive_integer'] }, 'to_lc'] }
```

A set of rules inside `or`:

```js
{ id: { or: [['email', 'to_lc'], 'positive_integer'] } }
```

Emulating `list_of_different_objects`:

```js
{
    products: { list_of: { or: [
        { nested_object: {
            product_type: ['required', { eq: 'material' }],
            material_id: ['required', 'positive_integer'],
            quantity: ['required', { min_number: 1 }],
            warehouse_id: 'positive_integer'
        }},
        { nested_object: {
            product_type: ['required', { eq: 'service' }],
            name: ['required', { max_length: 20 }]
        }}
    ]}}
}
```

is the same as

```js
{
    products: ['required', { list_of_different_objects: [
        'product_type', {
            material: {
                product_type: 'required',
                material_id: ['required', 'positive_integer'],
                quantity: ['required', { min_number: 1 }],
                warehouse_id: 'positive_integer'
            },
            service: {
                product_type: 'required',
                name: ['required', { max_length: 20 }]
            }
        }
    ]}]
}
```

Internally there is a difference: `or` tries one set of rules after another, while `list_of_different_objects` selects exactly one set of rules.
