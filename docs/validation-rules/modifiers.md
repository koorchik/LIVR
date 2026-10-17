# Modifiers

Rules that modify data. They never return errors: values they cannot handle (empty values, objects and lists) are passed through unchanged. Modifiers were called "filter rules" before v2.0.

## trim {#trim}

Removes leading and trailing whitespace.

```js
{ email: 'trim' }
```

<TestCases rule="trim" />

## to_lc {#to-lc}

Converts the string to lower case.

```js
{ email: 'to_lc' }
```

<TestCases rule="to_lc" />

## to_uc {#to-uc}

Converts the string to upper case.

```js
{ currency_code: 'to_uc' }
```

<TestCases rule="to_uc" />

## remove {#remove}

Removes the given characters from the string.

```js
{ text: { remove: '0123456789' } } // removes all digits from the text
```

<TestCases rule="remove" />

## leave_only {#leave-only}

Removes all characters except the given ones.

```js
{ text: { leave_only: '0123456789' } } // leaves only digits in the text
```

<TestCases rule="leave_only" />

## default {#default}

Sets the value if it is empty: missing, `null` or an empty string. Other values, including `0`, are kept.

```js
{ age: { default: 18 } } // sets age to 18 if it is not passed
```

<TestCases rule="default" />
