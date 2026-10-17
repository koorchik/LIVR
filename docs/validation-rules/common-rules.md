# Common rules

## required {#required}

Checks that the value is present: not missing, not `null` and not an empty string. Note that `0` and `false` are valid values.

Error code: `REQUIRED`

```js
{ first_name: 'required' }
```

<TestCases rule="required" />

## not_empty {#not-empty}

Checks that the value is not an empty string, if the field is passed at all. Unlike `required`, a missing field is valid.

Error code: `CANNOT_BE_EMPTY`

```js
{ first_name: 'not_empty' }
```

<TestCases rule="not_empty" />

## not_empty_list {#not-empty-list}

Checks that the value is a list with at least one element.

Error codes: `CANNOT_BE_EMPTY` if the value is missing or the list is empty, `FORMAT_ERROR` if the value is present but is not a list.

```js
{ products_ids: 'not_empty_list' }
```

<TestCases rule="not_empty_list" />

## any_object {#any-object}

Checks that the value is a plain object (a hash, a dictionary). The content of the object is not validated, use [`nested_object`](/validation-rules/metarules.html#nested-object) for that.

Error code: `FORMAT_ERROR` if the value is not a plain object.

```js
{ address: 'any_object' }
```

<TestCases rule="any_object" />
