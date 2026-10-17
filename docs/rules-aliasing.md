# Rules aliasing

With rules aliasing you can create custom rules without writing code and assign your own error codes to them. Aliased rules work across all implementations, as they are just data structures.

An alias looks like this:

```js
{
    name: ALIAS_NAME,
    rules: ALIAS_RULES,
    error: ERROR_CODE // optional
}
```

If `error` is not set, the validator returns the errors of the alias rules.

```js
{
    name: 'valid_address',
    rules: { nested_object: {
        country: 'required',
        city: 'required',
        zip: 'positive_integer'
    }}
}

{
    name: 'adult_age',
    rules: ['positive_integer', { min_number: 18 }],
    error: 'WRONG_AGE'
}
```

You can also use aliased rules inside other aliased rules.

## Usage example

Let's assume you have this data:

```js
{
    name: 'Viktor',
    age: 30,
    address: {
        country: 'Ukraine',
        city: 'Kyiv',
        zip: '11111'
    }
}
```

and these validation rules for it:

```js
{
    name: 'required',
    age: ['required', 'positive_integer', { min_number: 18 }],
    address: ['required', { nested_object: {
        country: 'required',
        city: 'required',
        zip: 'positive_integer'
    }}]
}
```

You use `address` in many objects (the user address in a user, the office address in an office, and so on) and want to reuse the same address rules everywhere. Without aliases you have two options:

1. **Write a custom rule `valid_address`.** It takes time and code, and the rule cannot be stored in a serialized JSON file.
2. **Assign the rules to a variable and reuse it.** It is easy, and the address rules can be stored in JSON, but the rules that use them cannot. And you cannot redefine the error code for the address.

Since v0.4 there is a third option: rules aliasing.

You register aliases for complex rules. How you register an alias depends on the implementation, but how you describe and use it is covered by the specification. So you can store aliases in JSON files and use them across different implementations.

```js
// Aliasing pseudo code
validator.registerAliasedRule({
    name: 'valid_address',
    rules: { nested_object: {
        country: 'required',
        city: 'required',
        zip: 'positive_integer'
    }}
})

validator.registerAliasedRule({
    name: 'adult_age',
    rules: ['positive_integer', { min_number: 18 }]
})

// Usage
{
    name: 'required',
    age: ['required', 'adult_age'],
    address: ['required', 'valid_address']
}
```

You can also add your own error codes for the aliases:

```js
validator.registerAliasedRule({
    name: 'valid_address',
    rules: { nested_object: {
        country: 'required',
        city: 'required',
        zip: 'positive_integer'
    }},
    error: 'WRONG_ADDRESS'
})
```

If validation of the address fails, you get this error:

```js
{
    address: 'WRONG_ADDRESS'
}
```

## Try it

```livr
// aliases
[{
    name: 'valid_address',
    rules: { nested_object: {
        country: 'required',
        city: 'required',
        zip: 'positive_integer'
    }},
    error: 'WRONG_ADDRESS'
}, {
    name: 'adult_age',
    rules: ['positive_integer', { min_number: 18 }],
    error: 'WRONG_AGE'
}]
// rules
{
    name: 'required',
    age: ['required', 'adult_age'],
    address: ['required', 'valid_address']
}
// input
{
    name: 'Viktor',
    age: 17,
    address: { country: 'Ukraine', city: '', zip: '11111' }
}
```

<TestCases suite="aliases" />
