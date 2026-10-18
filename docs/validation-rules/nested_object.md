---
title: nested_object
group: metarules
syntax: "{ nested_object: { … } }"
example:
  rules: |-
    {
        address: { nested_object: {
            city: 'required',
            zip: ['required', 'positive_integer']
        }}
    }
  input: |-
    {
        address: {
            city: 'Kyiv',
            zip: 'O1001'
        }
    }
---

# nested_object

Describes validation rules for a nested object.

Error codes: the errors of the nested rules, or `FORMAT_ERROR` if the value is not an object.

<RuleSandbox />

Errors are returned in the same shape as the data.
