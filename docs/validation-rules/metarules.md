# Metarules

Metarules are rules for describing more complex rules: nested objects, lists and alternatives. Errors of nested rules are returned in the same shape as the data.

## nested_object {#nested-object}

Describes validation rules for a nested object.

Error codes: the errors of the nested rules, or `FORMAT_ERROR` if the value is not an object.

```js
address: { nested_object: {
    city: 'required',
    zip: ['required', 'positive_integer']
}}
```

<TestCases rule="nested_object" />

## variable_object {#variable-object}

Describes validation rules for a field that can contain different kinds of objects. The value of the selector field (`product_type` below) chooses the set of rules.

Error codes: the errors of the nested rules, or `FORMAT_ERROR` if the value is not an object, or the selector field is missing or has an unknown value.

```js
product: ['required', { variable_object: [
    'product_type', {
        material: {
            product_type: 'required',
            material_id: ['required', 'positive_integer'],
            quantity: ['required', { min_number: 1 }],
            warehouse_id: 'positive_integer'
        },
        service: {
            product_type: 'required',
            name: ['required', { max_length: 10 }]
        }
    }
]}]
```

<TestCases rule="variable_object" />

## list_of {#list-of}

Describes validation rules for a list. The rules are applied to every element.

Error codes: a list with the error of every element (`null` for valid elements), or `FORMAT_ERROR` if the value is not a list.

```js
// new syntax (introduced in v0.4)
{ product_ids: { list_of: 'positive_integer' } }
{ product_ids: { list_of: ['required', 'positive_integer'] } }

// old syntax
{ product_ids: { list_of: [['positive_integer']] } }
{ product_ids: { list_of: [['required', 'positive_integer']] } }
```

<TestCases rule="list_of" />

## list_of_objects {#list-of-objects}

Describes validation rules for a list of objects. The rules are applied to every element.

Error codes: a list with the errors of every object, or `FORMAT_ERROR` if the value is not a list of objects.

```js
products: ['required', { list_of_objects: {
    product_id: ['required', 'positive_integer'],
    quantity: ['required', 'positive_integer']
}}]
```

<TestCases rule="list_of_objects" />

## list_of_different_objects {#list-of-different-objects}

Describes validation rules for a list of different objects. For every element, the value of the selector field chooses the set of rules, like in [`variable_object`](#variable-object).

Error codes: a list with the errors of every object, or `FORMAT_ERROR` if the value is not a list, an element is not an object, or its selector field is missing or has an unknown value.

```js
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
            name: ['required', { max_length: 10 }]
        }
    }
]}]
```

<TestCases rule="list_of_different_objects" />

## or <Badge type="warning" text="experimental" /> {#or}

Takes several sets of rules and applies them one after another until one of them succeeds.

This rule simplifies alias creation, see [Rules aliasing](/rules-aliasing.html). It is a good idea to define a custom error code for such an alias.

Error codes: when every set of rules fails, it is unclear which error to return. Currently the error of the last set is returned. This behavior can change in the future, as the rule is experimental.

`id` is either an email or a positive integer:

```js
{
    id: { or: ['email', 'positive_integer'] }
}
```

Combined with other rules:

```js
{
    id: [{ or: ['email', 'positive_integer'] }, 'to_lc']
}
```

A set of rules inside `or`:

```js
{
    id: { or: [['email', 'to_lc'], 'positive_integer'] }
}
```

Emulating `list_of_different_objects`:

```js
{
    products: { list_of: { or: [
        { nested_object: {
            product_type: ['required', { eq: 'material' }],
            material_id: ['required', 'positive_integer'],
            quantity: ['required', { min_number: 1 }],
            warehouse_id: 'positive_integer'
        }},
        { nested_object: {
            product_type: ['required', { eq: 'service' }],
            name: ['required', { max_length: 20 }]
        }}
    ]}}
}
```

is the same as

```js
{
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
```

Internally there is a difference: `or` tries one set of rules after another, while `list_of_different_objects` selects exactly one set of rules.

<TestCases rule="or" />
