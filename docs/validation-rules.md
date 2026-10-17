# Validation rules

These are the standard rules that every implementation must support. Projects usually add a few rules of their own; see [Create own plugins](/how-to-contribute/create-own-plugins.html) and [Rules aliasing](/rules-aliasing.html).

## Empty values are skipped

All standard rules skip empty values: a missing field, `null` and an empty string `""`. Only `required`, `not_empty` and `not_empty_list` check that a value is present. So the same rules work for optional fields:

```js
first_name: { min_length: 10 }               // optional: the length is checked only if "first_name" is passed
first_name: ['required', { min_length: 10 }] // the name must be present and at least 10 characters long
```

Rules that expect a primitive value (a string, a number or a boolean) return `FORMAT_ERROR` when they receive an object or a list. See [Error codes](/validation-rules/error-codes.html).

## Standard rules

| Group | Rules |
|---|---|
| [Common](/validation-rules/common-rules.html) | [`required`](/validation-rules/common-rules.html#required), [`not_empty`](/validation-rules/common-rules.html#not-empty), [`not_empty_list`](/validation-rules/common-rules.html#not-empty-list), [`any_object`](/validation-rules/common-rules.html#any-object) |
| [String](/validation-rules/string-rules.html) | [`string`](/validation-rules/string-rules.html#string), [`eq`](/validation-rules/string-rules.html#eq), [`one_of`](/validation-rules/string-rules.html#one-of), [`max_length`](/validation-rules/string-rules.html#max-length), [`min_length`](/validation-rules/string-rules.html#min-length), [`length_between`](/validation-rules/string-rules.html#length-between), [`length_equal`](/validation-rules/string-rules.html#length-equal), [`like`](/validation-rules/string-rules.html#like) |
| [Numeric](/validation-rules/numeric-rules.html) | [`integer`](/validation-rules/numeric-rules.html#integer), [`positive_integer`](/validation-rules/numeric-rules.html#positive-integer), [`decimal`](/validation-rules/numeric-rules.html#decimal), [`positive_decimal`](/validation-rules/numeric-rules.html#positive-decimal), [`max_number`](/validation-rules/numeric-rules.html#max-number), [`min_number`](/validation-rules/numeric-rules.html#min-number), [`number_between`](/validation-rules/numeric-rules.html#number-between) |
| [Special](/validation-rules/special-rules.html) | [`email`](/validation-rules/special-rules.html#email), [`url`](/validation-rules/special-rules.html#url), [`iso_date`](/validation-rules/special-rules.html#iso-date), [`equal_to_field`](/validation-rules/special-rules.html#equal-to-field) |
| [Metarules](/validation-rules/metarules.html) | [`nested_object`](/validation-rules/metarules.html#nested-object), [`variable_object`](/validation-rules/metarules.html#variable-object), [`list_of`](/validation-rules/metarules.html#list-of), [`list_of_objects`](/validation-rules/metarules.html#list-of-objects), [`list_of_different_objects`](/validation-rules/metarules.html#list-of-different-objects), [`or`](/validation-rules/metarules.html#or) |
| [Modifiers](/validation-rules/modifiers.html) (previously "filter rules") | [`trim`](/validation-rules/modifiers.html#trim), [`to_lc`](/validation-rules/modifiers.html#to-lc), [`to_uc`](/validation-rules/modifiers.html#to-uc), [`remove`](/validation-rules/modifiers.html#remove), [`leave_only`](/validation-rules/modifiers.html#leave-only), [`default`](/validation-rules/modifiers.html#default) |

Start with [How it works](/validation-rules/how-it-works.html) to learn the syntax, and [Types coercing](/validation-rules/types-coercing.html) to learn what the rules return.
