---
title: list_of_objects
group: metarules
syntax: "{ list_of_objects: { … } }"
example:
  rules: |-
    {
        products: ['required', { list_of_objects: {
            product_id: ['required', 'positive_integer'],
            quantity: ['required', 'positive_integer']
        }}]
    }
  input: |-
    {
        products: [
            { product_id: 3455, quantity: 2 },
            { product_id: 3456, quantity: 0 }
        ]
    }
---

# list_of_objects

Describes validation rules for a list of objects. The rules are applied to every element.

Error codes: a list with the errors of every object, or `FORMAT_ERROR` if the value is not a list of objects.

<RuleSandbox />
