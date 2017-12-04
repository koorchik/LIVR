### Rules aliasing

With rules aliasing you can create custom rules easely and assign own error codes in case own need. Moreover, aliased rules will work across all implementations as they are just data structures.

Alias struture:

```text
{
    name: ALIAS_NAME,
    rules: ALIAS_RULES,
    error: ERROR_CODE (optional)
}
```

If ERROR\_CODE is empty than validator will return subrules errors.

Example:

```text
{
    name: 'valid_address',
    rules: { nested_object: {
        country: 'required',
        city: 'required',
        zip: 'positive_integer'
    }}
}

{
    name: 'adult_age'
    rules: [ 'positive_integer', { min_number: 18 } ],
    error: 'WRONG_AGE'
}
```

Moreover, you can use aliased rules in aliased rules.

### Usage example

Let's assume that you have next data structure:

```text
{
    name: 'Viktor',
    age: 30,
    address: {
        country: 'Ukraine',
        city: 'Kiev',
        zip: '11111'
    }
}
```

And you have next validation rules for it:

```text
{
    name: 'required',
    age: ['required', 'positive_integer', { min_number: 18 } ],
    address: ['required', {nested_object: {
        country: 'required',
        city: 'required',
        zip: 'positive_integer'
    }}]
}
```

You use 'address' in a lot of your objects \(user address in user, office address in office object and others\) and you want to reuse the same address rules in all places.  You have two ways: write custom rule 'valid\_address' or assign rules to a variable and just reuse the variable. The first way requires much time and coding. Moreover, you cannot save new rule implementation is serialzed JSON file. The second way is much easier and you can store rule implemetation in JSON file but you cannot store user validation rules. Moreover, the second way does not allow you to redefine error code for address.

From v0.4 you have the third way - rule aliasing.

You can register aliases for complex rules. The way how you register an alias depends on the implementation but the way how use and describe it is covered by the specification. This appoach allows you store aliases in serialized JSON files and then use them across different implementations.

```text
// Aliasing pseudo code
validator.register_rule_alias({
    name: 'valid_address',
    rules: { nested_object: {
        country: 'required',
        city: 'required',
        zip: 'positive_integer'
    }}
});

validator.register_rule_alias( {
    name: 'adult_age',
    rules: [ 'positive_integer', { min_number: 18 } ]
});

// Usage
{
    name: 'required',
    age: ['required', 'adult_age' ],
    address: ['required', 'valid_address']
}
```

Moreover, you can add own error codes for the rules

For example

```text
// Aliasing pseudo code
validator.register_rule_alias({
    name: 'valid_address',
    rules: { nested_object: {
        country: 'required',
        city: 'required',
        zip: 'positive_integer'
    }},
    error: 'WRONG_ADDRESS'
});
```

and if validation of address fails you will have the next error

```text
{
    address: 'WRONG_ADDRESS'
}
```



