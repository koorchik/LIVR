# Error codes

LIVR returns error codes, not messages. Codes are stable across implementations, so you can map them to messages in any language of your interface.

## Shape of errors

Errors have the same shape as the data. Every invalid field gets its error code, nested objects get nested errors, and lists get a list of errors with `null` for valid elements:

```js
{
    name: 'REQUIRED',
    address: { zip: 'NOT_POSITIVE_INTEGER' },
    tags: [null, 'TOO_LONG']
}
```

An alias can replace the errors of its rules with a single custom code, see [Rules aliasing](/rules-aliasing.html).

## All error codes

| Code | Meaning | Returned by |
|---|---|---|
| `REQUIRED` | The value is missing, `null` or an empty string | [`required`](/validation-rules/common-rules.html#required) |
| `CANNOT_BE_EMPTY` | The value is an empty string, or the list is empty | [`not_empty`](/validation-rules/common-rules.html#not-empty), [`not_empty_list`](/validation-rules/common-rules.html#not-empty-list) |
| `FORMAT_ERROR` | The value has a wrong type: an object or a list where a primitive value is expected, or vice versa | Almost every rule, see below |
| `NOT_ALLOWED_VALUE` | The value is not one of the allowed values | [`eq`](/validation-rules/string-rules.html#eq), [`one_of`](/validation-rules/string-rules.html#one-of) |
| `TOO_LONG` | The string is too long | [`max_length`](/validation-rules/string-rules.html#max-length), [`length_between`](/validation-rules/string-rules.html#length-between), [`length_equal`](/validation-rules/string-rules.html#length-equal) |
| `TOO_SHORT` | The string is too short | [`min_length`](/validation-rules/string-rules.html#min-length), [`length_between`](/validation-rules/string-rules.html#length-between), [`length_equal`](/validation-rules/string-rules.html#length-equal) |
| `WRONG_FORMAT` | The string does not match the regular expression | [`like`](/validation-rules/string-rules.html#like) |
| `NOT_INTEGER` | The value is not an integer | [`integer`](/validation-rules/numeric-rules.html#integer) |
| `NOT_POSITIVE_INTEGER` | The value is not an integer greater than zero | [`positive_integer`](/validation-rules/numeric-rules.html#positive-integer) |
| `NOT_DECIMAL` | The value is not a number | [`decimal`](/validation-rules/numeric-rules.html#decimal) |
| `NOT_POSITIVE_DECIMAL` | The value is not a number greater than zero | [`positive_decimal`](/validation-rules/numeric-rules.html#positive-decimal) |
| `NOT_NUMBER` | The value is not a number | [`max_number`](/validation-rules/numeric-rules.html#max-number), [`min_number`](/validation-rules/numeric-rules.html#min-number), [`number_between`](/validation-rules/numeric-rules.html#number-between) |
| `TOO_HIGH` | The number is too high | [`max_number`](/validation-rules/numeric-rules.html#max-number), [`number_between`](/validation-rules/numeric-rules.html#number-between) |
| `TOO_LOW` | The number is too low | [`min_number`](/validation-rules/numeric-rules.html#min-number), [`number_between`](/validation-rules/numeric-rules.html#number-between) |
| `WRONG_EMAIL` | The value is not an email | [`email`](/validation-rules/special-rules.html#email) |
| `WRONG_URL` | The value is not an http or https URL | [`url`](/validation-rules/special-rules.html#url) |
| `WRONG_DATE` | The value is not an ISO 8601 date | [`iso_date`](/validation-rules/special-rules.html#iso-date) |
| `FIELDS_NOT_EQUAL` | The value differs from the value of another field | [`equal_to_field`](/validation-rules/special-rules.html#equal-to-field) |

## FORMAT_ERROR

`FORMAT_ERROR` means that the value has a type the rule cannot handle:

- string, numeric and special rules return it for objects and lists;
- `any_object` and `nested_object` return it for anything that is not an object;
- `not_empty_list`, `list_of`, `list_of_objects` and `list_of_different_objects` return it for anything that is not a list (or a list of objects);
- `variable_object` and `list_of_different_objects` also return it when the selector field is missing or has an unknown value.

[Modifiers](/validation-rules/modifiers.html) never return errors. All rules except `required`, `not_empty` and `not_empty_list` skip empty values (missing, `null` or `""`), so for them an empty value never causes `FORMAT_ERROR`.
