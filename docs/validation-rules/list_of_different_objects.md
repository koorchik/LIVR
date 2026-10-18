---
title: list_of_different_objects
group: metarules
syntax: "{ list_of_different_objects: ['type', { … }] }"
example:
  rules: |-
    {
        products: ['required', { list_of_different_objects: [
            'product_type', {
                material: {
                    product_type: 'required',
                    material_id: ['required', 'positive_integer'],
                    quantity: ['required', { min_number: 1 }]
                },
                service: {
                    product_type: 'required',
                    name: ['required', { max_length: 10 }]
                }
            }
        ]}]
    }
  input: |-
    {
        products: [
            { product_type: 'material', material_id: 345, quantity: 5 },
            { product_type: 'service', name: 'Clean the filter' }
        ]
    }
---

# list_of_different_objects

Describes validation rules for a list of different objects. For every element, the value of the selector field chooses the set of rules, like in [`variable_object`](/validation-rules/variable_object.html).

Error codes: a list with the errors of every object, or `FORMAT_ERROR` if the value is not a list, an element is not an object, or its selector field is missing or has an unknown value.

<RuleSandbox />
