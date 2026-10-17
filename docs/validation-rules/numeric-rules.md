# Numeric rules

Numeric rules accept numbers and strings that look like numbers, and return the value as a number, see [Types coercing](/validation-rules/types-coercing.html). All of them return `FORMAT_ERROR` for objects and lists.

## integer {#integer}

Error codes: `NOT_INTEGER`, `FORMAT_ERROR`

```js
{ age: 'integer' }
```

<TestCases rule="integer" />

## positive_integer {#positive-integer}

Checks that the value is an integer greater than zero.

Error codes: `NOT_POSITIVE_INTEGER`, `FORMAT_ERROR`

```js
{ age: 'positive_integer' }
```

<TestCases rule="positive_integer" />

## decimal {#decimal}

Error codes: `NOT_DECIMAL`, `FORMAT_ERROR`

```js
{ price: 'decimal' }
```

<TestCases rule="decimal" />

## positive_decimal {#positive-decimal}

Checks that the value is a number greater than zero.

Error codes: `NOT_POSITIVE_DECIMAL`, `FORMAT_ERROR`

```js
{ price: 'positive_decimal' }
```

<TestCases rule="positive_decimal" />

## max_number {#max-number}

Error codes: `TOO_HIGH`, `NOT_NUMBER`, `FORMAT_ERROR`

```js
{ age: { max_number: 95 } }
```

<TestCases rule="max_number" />

## min_number {#min-number}

Error codes: `TOO_LOW`, `NOT_NUMBER`, `FORMAT_ERROR`

```js
{ age: { min_number: 18 } }
```

<TestCases rule="min_number" />

## number_between {#number-between}

Error codes: `TOO_HIGH`, `TOO_LOW`, `NOT_NUMBER`, `FORMAT_ERROR`

```js
{ age: { number_between: [18, 95] } }
```

<TestCases rule="number_between" />
