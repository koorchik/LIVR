---
title: variable_object
group: metarules
syntax: "{ variable_object: ['type', { … }] }"
example:
  rules: |-
    {
        product: ['required', { variable_object: [
            'product_type', {
                material: {
                    product_type: 'required',
                    material_id: ['required', 'positive_integer'],
                    quantity: ['required', { min_number: 1 }],
                    warehouse_id: 'positive_integer'
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
        product: {
            product_type: 'service',
            name: 'Clean the filter'
        }
    }
---

# variable_object

Describes validation rules for a field that can contain different kinds of objects. The value of the selector field (`product_type` in the example) chooses the set of rules.

Error codes: the errors of the nested rules, or `FORMAT_ERROR` if the value is not an object, or the selector field is missing or has an unknown value.

<RuleSandbox />
