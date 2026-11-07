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
| `REQUIRED` | The value is missing, `null` or an empty string | [`required`](/validation-rules/required.html) |
| `CANNOT_BE_EMPTY` | The value is an empty string, or the list is empty | [`not_empty`](/validation-rules/not_empty.html), [`not_empty_list`](/validation-rules/not_empty_list.html) |
| `FORMAT_ERROR` | The value has a wrong type: an object or a list where a primitive value is expected, or vice versa | Almost every rule, see below |
| `NOT_ALLOWED_VALUE` | The value is not one of the allowed values | [`eq`](/validation-rules/eq.html), [`one_of`](/validation-rules/one_of.html) |
| `TOO_LONG` | The string is too long | [`max_length`](/validation-rules/max_length.html), [`length_between`](/validation-rules/length_between.html), [`length_equal`](/validation-rules/length_equal.html) |
| `TOO_SHORT` | The string is too short | [`min_length`](/validation-rules/min_length.html), [`length_between`](/validation-rules/length_between.html), [`length_equal`](/validation-rules/length_equal.html) |
| `WRONG_FORMAT` | The string does not match the regular expression | [`like`](/validation-rules/like.html) |
| `NOT_INTEGER` | The value is not an integer | [`integer`](/validation-rules/integer.html) |
| `NOT_POSITIVE_INTEGER` | The value is not an integer greater than zero | [`positive_integer`](/validation-rules/positive_integer.html) |
| `NOT_DECIMAL` | The value is not a number | [`decimal`](/validation-rules/decimal.html) |
| `NOT_POSITIVE_DECIMAL` | The value is not a number greater than zero | [`positive_decimal`](/validation-rules/positive_decimal.html) |
| `NOT_NUMBER` | The value is not a number | [`max_number`](/validation-rules/max_number.html), [`min_number`](/validation-rules/min_number.html), [`number_between`](/validation-rules/number_between.html) |
| `TOO_HIGH` | The number is too high | [`max_number`](/validation-rules/max_number.html), [`number_between`](/validation-rules/number_between.html) |
| `TOO_LOW` | The number is too low | [`min_number`](/validation-rules/min_number.html), [`number_between`](/validation-rules/number_between.html) |
| `WRONG_EMAIL` | The value is not an email | [`email`](/validation-rules/email.html) |
| `WRONG_URL` | The value is not an http or https URL | [`url`](/validation-rules/url.html) |
| `WRONG_DATE` | The value is not an ISO 8601 date | [`iso_date`](/validation-rules/iso_date.html) |
| `FIELDS_NOT_EQUAL` | The value differs from the value of another field | [`equal_to_field`](/validation-rules/equal_to_field.html) |

## LIVR 2.5 codes <Badge type="info" text="LIVR 2.5" /> {#codes-2-5}

The rules added in [LIVR 2.5](/changes.html#v2-5) add these codes:

| Code | Meaning | Returned by |
|---|---|---|
| `NOT_BOOLEAN` | The value is not one of the accepted boolean values | [`boolean`](/validation-rules/boolean.html) |
| `TOO_MANY_DECIMALS` | The number has too many digits after the decimal point | [`max_decimals`](/validation-rules/max_decimals.html) |
| `NOT_DIGITS` | The value is not a string of ASCII digits | [`digits`](/validation-rules/digits.html) |
| `DATE_TOO_EARLY` | The date is before `min` | [`iso_date`](/validation-rules/iso_date.html#options-form) with `min` |
| `DATE_TOO_LATE` | The date is after `max` | [`iso_date`](/validation-rules/iso_date.html#options-form) with `max` |
| `DATETIME_TOO_EARLY` | The date and time is before `min` | [`iso_datetime`](/validation-rules/iso_datetime.html#bounds) with `min` |
| `DATETIME_TOO_LATE` | The date and time is after `max` | [`iso_datetime`](/validation-rules/iso_datetime.html#bounds) with `max` |
| `TIME_TOO_EARLY` | The time of day is before `min` | [`iso_time`](/validation-rules/iso_time.html#bounds) with `min` |
| `TIME_TOO_LATE` | The time of day is after `max` | [`iso_time`](/validation-rules/iso_time.html#bounds) with `max` |
| `WRONG_DATETIME` | The value is not an ISO 8601 date and time with an offset | [`iso_datetime`](/validation-rules/iso_datetime.html) |
| `WRONG_TIME` | The value is not a time `HH:MM[:SS[.fraction]]` | [`iso_time`](/validation-rules/iso_time.html) |
| `WRONG_KEY` | The key of an object does not pass the rules | [`keys`](/validation-rules/keys.html) |
| `TOO_FEW_ITEMS` | The list has too few items | [`list_length`](/validation-rules/list_length.html) |
| `TOO_MANY_ITEMS` | The list has too many items | [`list_length`](/validation-rules/list_length.html) |
| `NOT_UNIQUE_ITEMS` | The list has duplicate items | [`unique`](/validation-rules/unique.html) |
| `WRONG_UUID` | The value is not a UUID | [`uuid`](/validation-rules/uuid.html) |
| `WRONG_IP` | The value is not an IP address | [`ip`](/validation-rules/ip.html) |
| `WRONG_CIDR` | The value is not an IP address with a prefix length | [`cidr`](/validation-rules/cidr.html) |
| `WRONG_HOSTNAME` | The value is not a hostname | [`hostname`](/validation-rules/hostname.html) |
| `WRONG_BASE64` | The value is not a Base64 string | [`base64`](/validation-rules/base64.html) |
| `WRONG_HEX` | The value is not a hex string | [`hex`](/validation-rules/hex.html) |
| `WRONG_DIGEST` | The value is not a hex digest of the given algorithms | [`digest`](/validation-rules/digest.html) |
| `WRONG_MONGO_ID` | The value is not a BSON ObjectId | [`mongo_id`](/validation-rules/mongo_id.html) |
| `WRONG_HEX_COLOR` | The value is not a hex color | [`hex_color`](/validation-rules/hex_color.html) |
| `WRONG_MAC` | The value is not a MAC address | [`mac`](/validation-rules/mac.html) |
| `WRONG_E164` | The value is not an E.164 phone number | [`e164`](/validation-rules/e164.html) |
| `WRONG_SEMVER` | The value is not a semantic version | [`semver`](/validation-rules/semver.html) |
| `WRONG_JWT` | The value is not a JWT | [`jwt`](/validation-rules/jwt.html) |
| `WRONG_CHECKSUM` | The Luhn checksum is wrong | [`luhn`](/validation-rules/luhn.html) |
| `WRONG_CREDIT_CARD_NUMBER` | The value is not a payment card number | [`credit_card`](/validation-rules/credit_card.html) |
| `WRONG_IBAN` | The value is not an IBAN | [`iban`](/validation-rules/iban.html) |

They also return existing codes: `REQUIRED` ([`required_if`](/validation-rules/required_if.html)), `NOT_ALLOWED_VALUE` ([`not_one_of`](/validation-rules/not_one_of.html), [`when`](/validation-rules/when.html)), `NOT_NUMBER` ([`max_decimals`](/validation-rules/max_decimals.html)), `WRONG_FORMAT` ([`starts_with`](/validation-rules/starts_with.html), [`ends_with`](/validation-rules/ends_with.html), [`contains`](/validation-rules/contains.html)), `WRONG_DATE` ([`iso_date`](/validation-rules/iso_date.html)) and `FORMAT_ERROR`.

The codes tell the structure from the value:

- `FORMAT_ERROR`: a wrong structure, an object or a list where a primitive value is expected (or the other way round);
- `WRONG_<FORMAT>` and `NOT_<TYPE>`: a primitive value that is not what the rule expects, a typo of the user. A boolean is a primitive value, so `true` for a date is `WRONG_DATE`, not `FORMAT_ERROR`;
- bound codes (`TOO_*`, `<FORMAT>_TOO_EARLY`, `<FORMAT>_TOO_LATE`): the value itself is right, but it is out of bounds.

So a rule checks the format before the bounds, and a bound code always means a valid value: an `iso_datetime` value that is in the year 10000 in UTC gives `WRONG_DATETIME`, even if it is also after `max`.

Naming: `NOT_<TYPE>` for a wrong type, `WRONG_<FORMAT>` for a wrong format, `TOO_*` for bounds. Date and time bounds are `<FORMAT>_TOO_EARLY` / `<FORMAT>_TOO_LATE`, with the same `<FORMAT>` as the `WRONG_<FORMAT>` code of the rule, so a message can say "the date is too early" or "the time is too late". Codes are never renamed later, so these names are final.

## FORMAT_ERROR

`FORMAT_ERROR` means that the value has a type the rule cannot handle:

- string, numeric and special rules return it for objects and lists;
- `any_object` and `nested_object` return it for anything that is not an object;
- `not_empty_list`, `list_of`, `list_of_objects` and `list_of_different_objects` return it for anything that is not a list (or a list of objects);
- `variable_object` and `list_of_different_objects` also return it when the selector field is missing or has an unknown value.

[Modifiers](/validation-rules/modifiers.html) never return errors. All rules except `required`, `not_empty` and `not_empty_list` skip empty values (missing, `null` or `""`), so for them an empty value never causes `FORMAT_ERROR`.

In LIVR 2.5, the rules that expect a primitive value return `FORMAT_ERROR` for objects and lists (a boolean is a primitive value, so [format](/validation-rules/format-rules.html) and [checksum](/validation-rules/checksum-rules.html) rules return their own code for it, and `iso_date` returns `WRONG_DATE`, not `FORMAT_ERROR`); `list_length` and `unique` return it for anything that is not a list, and `values` and `keys` for anything that is not an object. See [Conventions of the 2.5 rules](/validation-rules/how-it-works.html#conventions-2-5).
