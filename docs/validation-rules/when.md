---
title: when
group: metarules
since: '2.5'
syntax: "{ when: ['type', { eq: 'company' }, 'required'] }"
example:
  rules: |-
    {
        type: ['required', { one_of: ['person', 'company'] }],
        vat_number: { when: ['type', { eq: 'company' },
            ['required', { like: '^[A-Z]{2}[0-9]{8,12}$' }], { eq: '' }] }
    }
  input: |-
    {
        type: 'company'
    }
---

# when

Applies rules to the field depending on the value of another field.

Error codes: the errors of the rules of the selected branch, or `NOT_ALLOWED_VALUE` in the switch form when the value of the other field is empty or not one of the cases.

<RuleSandbox />

There are two forms, both positional:

```js
{ when: [REFERENCE, CONDITION, RULES_IF_TRUE, RULES_IF_FALSE] } // RULES_IF_FALSE is optional
{ when: [REFERENCE, CASES] }
```

The number of arguments selects the form: 2 is the switch form, 3 or 4 is the condition form. Fewer than 2 arguments, or `CASES` that is not an object, is a [schema error](/validation-rules/how-it-works.html#arguments). Don't pass arguments after the 4th: what happens to them depends on the implementation.

`REFERENCE` is a [reference](/validation-rules/how-it-works.html#field-references) to another field. `CONDITION`, `RULES_IF_TRUE`, `RULES_IF_FALSE` and the values of `CASES` are rules in any form that a field accepts: a rule name, a rule object or a list of rules. An empty list `[]` is a schema error: use [`'any'`](/validation-rules/any.html) for a branch or a case without rules.

## Condition form

- The condition is true when the referenced value is **not empty** and passes the `CONDITION` rules. The `CONDITION` rules run on the referenced value like the rules of a field: in order, the output of one rule is the input of the next (so `['boolean', { eq: true }]` works for `"1"`), and their output is discarded.
- The condition itself checks that the value is not empty, so `required` and `not_empty` add nothing to it, and the condition `{ eq: 'company' }` on `type` is false when `type` is missing (the rule alone would pass an empty value). To check only that the other field is filled, write `'required'`.
- Only a missing field, `null` and `""` are empty: `false`, `0`, `"0"` and `" "` are filled. So a checkbox needs `['boolean', { eq: true }]`, and a value of spaces counts as filled unless the validator trims the input.
- When the condition is true, the field is validated with `RULES_IF_TRUE`, otherwise with `RULES_IF_FALSE`.
- Without `RULES_IF_FALSE`, a false condition means no rules: the value passes and stays in the output unchanged.

::: warning
With 3 arguments, a false condition lets any value through unchecked, even an object, like [`any`](/validation-rules/any.html). If the field may only be sent when the condition is true, prefer the 4th argument: `{ eq: '' }` forbids the field, other rules check it.

```js
{ vat_number: { when: ['type', { eq: 'company' }, ['required', 'string'], { eq: '' }] } }
```
:::

## Switch form

- If the referenced value is empty, no case can be chosen: an empty validated value passes and stays as it is (the referenced field reports its own `REQUIRED`), any other value gives `NOT_ALLOWED_VALUE`. Otherwise an unchecked value, a whole object among them, would pass.
- Otherwise, the referenced value must be a primitive value whose [string form](/validation-rules/how-it-works.html#string-form) is a key of `CASES`. The field is validated with the rules of that key.
- A referenced value that is not a key of `CASES`, or is not a primitive value, gives `NOT_ALLOWED_VALUE` on the validated field, unless the validated value is empty.
- `CASES` must have at least one key, otherwise it is a schema error.

## Branches

The branch gets the value as it is, including empty values, so [`required`](/validation-rules/required.html) works in it, and `{ eq: '' }` forbids the field: all rules skip empty values, so it accepts only an empty value (there is no `absent` rule, `{ eq: '' }` does the same). Its errors and output are the errors and output of the field.

## Other fields in the rules {#containing-object}

The `CONDITION` rules check the referenced value, and the branches check the validated value, but both see the [containing object](/validation-rules/how-it-works.html#field-references) of the validated field, like its other rules: `when` is transparent, like aliases and [`or`](/validation-rules/or.html). This matters for rules that read other fields, such as [`equal_to_field`](/validation-rules/equal_to_field.html), `required_if` or another `when`, also when the reference is a path:

```js
{
    seller_country: 'required',
    address: { nested_object: { country: 'required' } },
    vat: { when: ['address/country', { equal_to_field: 'seller_country' }, 'required'] }
}
```

Here `seller_country` is the sibling of `vat`, not of `country`: the VAT number is required when the address is in the country of the seller.

## Examples

Email or phone: if the phone is given, the email is only checked, otherwise it is required.

```js
{
    email: { when: ['phone', 'required', 'email', ['required', 'email']] },
    phone: { when: ['email', 'required', 'string', ['required', 'string']] }
}
```

A VAT number is required for companies and not allowed for anyone else.

```js
{
    vat_number: { when: ['type', { eq: 'company' },
        ['required', { like: '^[A-Z]{2}[0-9]{8,12}$' }], { eq: '' }] }
}
```

A checkbox: `"1"`, `"true"` and `true` all turn the condition on.

```js
{
    email: ['email', { when: ['subscribe', ['boolean', { eq: true }], 'required'] }]
}
```

A switch: the type is outside the `data` object, which [`variable_object`](/validation-rules/variable_object.html) cannot do.

```js
{
    type: ['required', { one_of: ['card', 'bank'] }],
    data: ['required', { when: ['type', {
        card: { nested_object: { number: ['required', 'credit_card'] } },
        bank: { nested_object: { iban: ['required', 'iban'] } }
    }] }]
}
```
