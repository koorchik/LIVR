## Validation Rules

Be aware that all standard rules just skip checking empty values.  
So, empty string will pass next validation - "first\_name: { min\_length: \[10\] }". We have special rules "required" and "not\_empty" to check that value is present.  
This allows us to use the same rules for not required fields.

```text
first_name: { min_length: [10] } # name is optional. We will check length only if "first_name" was passed
first_name: [ 'required', { min_length: [10] } ] # check that the name is present and validate length
```



#### Rules:

* [Types coercing](/gitbook/validation-rules/types-coercing.md)
* [Common](/gitbook/validation-rules/common-rules.md)
* [String](/gitbook/validation-rules/string-rules.md)
* [Numeric](/gitbook/validation-rules/numeric-rules.md)
* [Special](/gitbook/validation-rules/special-rules.md)
* [Metarules](/gitbook/validation-rules/metarules.md)
* [Modifiers](/gitbook/validation-rules/modifiers.md)



