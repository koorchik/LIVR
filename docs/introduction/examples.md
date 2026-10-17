# Examples

Every example below is live: edit the rules or the input and the result updates immediately. The examples run on the JavaScript implementation, and all implementations behave the same.

## Registration form

```livr
// rules
{
    name: 'required',
    email: ['required', 'email'],
    gender: { one_of: ['male', 'female'] },
    phone: { max_length: 10 },
    password: ['required', { min_length: 10 }],
    password2: { equal_to_field: 'password' }
}
// input
{
    name: 'John',
    email: 'john@mail.com',
    gender: 'male',
    phone: '+22221212',
    password: 'mypassword1',
    password2: 'mypassword1'
}
```

- `'required'` is a shorter form of `{ required: [] }`.
- `{ max_length: 10 }` is a shorter form of `{ max_length: [10] }`.
- See [How it works](/validation-rules/how-it-works.html) for the full syntax.

## Nested object

```livr
// rules
{
    name: 'required',
    phone: { max_length: 10 },
    address: { nested_object: {
        city: 'required',
        zip: ['required', 'positive_integer']
    }}
}
// input
{
    name: 'Michael',
    phone: '0441234567',
    address: {
        city: 'Kyiv',
        zip: '30552'
    }
}
```

- `{ nested_object: {} }` is a shorter form of `{ nested_object: [{}] }`.
- Note that `zip` is returned as a number: rules are expectations, see [types coercing](/validation-rules/types-coercing.html).

## List of values

```livr
// rules
{
    order_id: ['required', 'positive_integer'],
    product_ids: { list_of: ['required', 'positive_integer'] }
}
// input
{
    order_id: 10455,
    product_ids: [3455, 3456, 'abc']
}
```

## List of objects

```livr
// rules
{
    order_id: ['required', 'positive_integer'],
    products: ['not_empty_list', { list_of_objects: {
        product_id: ['required', 'positive_integer'],
        quantity: ['required', 'positive_integer']
    }}]
}
// input
{
    order_id: 10345,
    products: [
        { product_id: 3455, quantity: 2 },
        { product_id: 3456, quantity: 3 }
    ]
}
```

## List of different objects

The `product_type` field of each object selects the set of rules to apply.

```livr
// rules
{
    order_id: ['required', 'positive_integer'],
    products: ['required', { list_of_different_objects: [
        'product_type', {
            material: {
                product_type: 'required',
                material_id: ['required', 'positive_integer'],
                quantity: ['required', { min_number: 1 }],
                warehouse_id: 'positive_integer'
            },
            service: {
                product_type: 'required',
                name: ['required', { max_length: 20 }]
            }
        }
    ]}]
}
// input
{
    order_id: 10455,
    products: [{
        product_type: 'material',
        material_id: 345,
        quantity: 5,
        warehouse_id: 24
    }, {
        product_type: 'service',
        name: 'Clean filter'
    }]
}
```

## Output modification

```livr
// rules
{
    email: ['trim', 'required', 'email', 'to_lc']
}
// input
{
    email: '  John.Smith@Example.COM  '
}
```

- `trim` removes leading and trailing spaces.
- `to_lc` converts the string to lower case.

Modifiers skip empty values and objects, so you can build a pipeline from any modifiers you like. See [Modifiers](/validation-rules/modifiers.html).
