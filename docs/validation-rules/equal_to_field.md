---
title: equal_to_field
group: special
syntax: "{ equal_to_field: 'password' }"
example:
  rules: |-
    {
        password: 'required',
        password2: { equal_to_field: 'password' }
    }
  input: |-
    {
        password: 'secret123',
        password2: 'secret124'
    }
---

# equal_to_field

Checks that the value is equal to the value of another field, for example a password confirmation. Values are compared as strings: `"10"` and `10` are equal, while `"10"` and `"1e1"` are not. A missing field is not equal to any value.

Error codes: `FIELDS_NOT_EQUAL`, `FORMAT_ERROR`

<RuleSandbox />

## In aliases, `or` and lists <Badge type="warning" text="LIVR 2.5 draft" /> {#containing-object}

In LIVR 2.0, rules that read other fields (`equal_to_field` and custom rules) saw a made-up object inside an [alias](/rules-aliasing.html), an [`or`](/validation-rules/or.html) branch and an item of [`list_of`](/validation-rules/list_of.html): `{ value: x }`, `{ field: x }` and `{ field: item }` in the JavaScript implementation. So a comparison with a sibling field never worked there, and `{ equal_to_field: 'field' }` in `list_of` compared an item with itself.

The [draft LIVR 2.5](/changes.html#v2-5-draft) fixes it through the [containing object](/validation-rules/how-it-works.html#field-references): in an alias, an `or` branch and the rules of [`when`](/validation-rules/when.html#containing-object) the rule compares with a sibling of the field, in an item of `list_of` the other field is missing. A schema that relied on the made-up object gives a different result. To compare the fields of an item, use [`list_of_objects`](/validation-rules/list_of_objects.html).

The argument stays a plain field name, not a [reference](/validation-rules/how-it-works.html#field-references): `{ equal_to_field: 'a/b' }` compares with the field named `a/b`.
