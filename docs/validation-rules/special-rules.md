# Special rules

All special rules return `FORMAT_ERROR` for objects and lists.

## email {#email}

Error codes: `WRONG_EMAIL`, `FORMAT_ERROR`

```js
{ login: 'email' }
```

<TestCases rule="email" />

## url {#url}

Checks that the value is a URL. Only the `http` and `https` protocols are allowed, and the protocol is required.

Error codes: `WRONG_URL`, `FORMAT_ERROR`

```js
{ url: 'url' }
```

<TestCases rule="url" />

## iso_date {#iso-date}

Checks that the value is an ISO 8601 date without time, for example `"2014-08-14"`.

Error codes: `WRONG_DATE`, `FORMAT_ERROR`

```js
{ date: 'iso_date' }
```

<TestCases rule="iso_date" />

## equal_to_field {#equal-to-field}

Checks that the value is equal to the value of another field.

Error codes: `FIELDS_NOT_EQUAL`, `FORMAT_ERROR`

```js
{ password2: { equal_to_field: 'password' } }
```

<TestCases rule="equal_to_field" />
