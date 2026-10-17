# String rules

String rules accept primitive values: strings, numbers and booleans. Numbers are validated as strings. All of them return `FORMAT_ERROR` for objects and lists.

## string {#string}

Checks that the value is a primitive type and converts it to a string. Prefer stricter rules where possible.

Error code: `FORMAT_ERROR`

```js
{ payload: ['required', 'string'] } // 25 becomes "25"
```

You can treat this rule as a modifier.

<TestCases rule="string" />

## eq {#eq}

Checks that the value is equal to the given one. Values are compared as strings, and the output is the value from the rule, see [Types coercing](/validation-rules/types-coercing.html).

Error codes: `NOT_ALLOWED_VALUE`, `FORMAT_ERROR`

```js
{ first_name: { eq: 'Anton' } }
```

<TestCases rule="eq" />

## one_of {#one-of}

Checks that the value is one of the allowed values.

Error codes: `NOT_ALLOWED_VALUE`, `FORMAT_ERROR`

```js
// new syntax (introduced in v0.4)
{ first_name: { one_of: ['Anton', 'Igor'] } }

// old syntax
{ first_name: { one_of: [['Anton', 'Igor']] } }
```

<TestCases rule="one_of" />

## max_length {#max-length}

Error codes: `TOO_LONG`, `FORMAT_ERROR`

```js
{ first_name: { max_length: 10 } }
```

<TestCases rule="max_length" />

## min_length {#min-length}

Error codes: `TOO_SHORT`, `FORMAT_ERROR`

```js
{ first_name: { min_length: 2 } }
```

<TestCases rule="min_length" />

## length_between {#length-between}

Error codes: `TOO_LONG`, `TOO_SHORT`, `FORMAT_ERROR`

```js
{ first_name: { length_between: [2, 10] } }
```

<TestCases rule="length_between" />

## length_equal {#length-equal}

Error codes: `TOO_LONG`, `TOO_SHORT`, `FORMAT_ERROR`

```js
{ first_name: { length_equal: 7 } }
```

<TestCases rule="length_equal" />

## like {#like}

Checks that the value matches a regular expression.

Error codes: `WRONG_FORMAT`, `FORMAT_ERROR`

```js
{ first_name: { like: '^\\w+?$' } }
{ first_name: { like: ['^\\w+?$', 'i'] } } // with flags
```

Only the `i` flag is currently required by the specification.

::: warning Experimental
Regular expression syntax differs between languages. Use the most common syntax. This rule is experimental, as it needs stricter semantics.
:::

<TestCases rule="like" />
