## Validation Rules

Be aware that all standard rules just skip checking empty values.  
So, empty string will pass next validation - "first\_name: { min\_length: \[10\] }". We have special rules "required" and "not\_empty" to check that value is present.  
This allows us to use the same rules for not required fields.

```text
first_name: { min_length: [10] } # name is optional. We will check length only if "first_name" was passed
first_name: [ 'required', { min_length: [10] } ] # check that the name is present and validate length
```

##### Standard rules that should be supported by every implementation:

* [Common Rules](validation-rules/common-rules.md)
  * required
  * not\_empty
  * not\_empty\_list
  * any\_object
* [String Rules](validation-rules/string-rules.md)
  * string
  * eq
  * one\_of
  * max\_length
  * min\_length
  * length\_between
  * length\_equal
  * like
* [Numeric Rules](validation-rules/numeric-rules.md)
  * integer
  * positive\_integer
  * decimal
  * positive\_decimal
  * max\_number
  * min\_number
  * number\_between
* [Special Rules](validation-rules/special-rules.md)
  * email
  * url
  * iso\_date
  * equal\_to\_field
* [Metarules](validation-rules/metarules.md)
  * nested\_object
  * list\_of
  * list\_of\_objects
  * list\_of\_different\_objects
  * or
* [Modifiers](validation-rules/modifiers.md) \(previously - "Filter rules"\)
  * trim
  * to\_lc
  * to\_uc
  * remove
  * leave\_only
  * default
