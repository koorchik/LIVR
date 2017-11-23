### Metarules

Metarules are rules for describing more complex rules.

#### nested\_object

Allows you to describe validation rules for a nested object.

Error code: depends on nested validators. If nested object is not a hash should return "FORMAT\_ERROR"

Example:

```text
address: { 'nested_object': {
    city: 'required',
    zip: ['required', 'positive_integer']
} }
```

#### variable\_object

Allows you to describe validation rules for field that can conatain different objects.

Error code: depends on nested validators. Or "FORMAT\_ERROR" in case of receiving data not suitable for validation.

Example:

```text
product: ['required', { 'variable_object': [
    product_type, {
        material: {
            product_type: 'required',
            material_id: ['required', 'positive_integer'],
            quantity: ['required', {'min_number': 1} ],
            warehouse_id: 'positive_integer'
        },
        service: {
            product_type: 'required',
            name: ['required', {'max_length': 10} ]
        }
    }
]}]
```

In this example validator will look on "product\_type" and depending on it will use corresponding set of rules

#### list\_of

Allows you to describe validation rules for a list. Validation rules will be applyed for each array element.

Error code: depends on nested validators

Example:

```text
// new syntax (introduced in v0.4)
{ product_ids: { 'list_of': 'positive_integer' }}
{ product_ids: { 'list_of': ['required',  'positive_integer'] }} // new syntax

// old syntax
{ product_ids: { 'list_of': [[ 'positive_integer' ]] }}
{ product_ids: { 'list_of': [[ 'required',  'positive_integer' ]] }}
```

#### list\_of\_objects

Allows you to describe validation rules for list of objects. Validation rules will be applyed for each array element.

Error code: depends on nested validators. Or "FORMAT\_ERROR" in case of receiving data not suitable for validation.

Example:

```text
products: ['required', { 'list_of_objects': [{
    product_id: ['required','positive_integer'],
    quantity: ['required', 'positive_integer']
}]}]
```

#### list\_of\_different\_objects

Allows you to describe validation rules for list of different objects. Validation rules will be applied for each array element.

Error code: depends on nested validators. Or "FORMAT\_ERROR" in case of receiving data not suitable for validation.

Example:

```text
products: ['required', { 'list_of_different_objects': [
    product_type, {
        material: {
            product_type: 'required',
            material_id: ['required', 'positive_integer'],
            quantity: ['required', {'min_number': 1} ],
            warehouse_id: 'positive_integer'
        },
        service: {
            product_type: 'required',
            name: ['required', {'max_length': 10} ]
        }
    }
]}]
```

In this example validator will look on "product\_type" in each object and depending on it will use corresponding set of rules

#### or \(experimental\)

The rule takes sets of other rules and applies them one after another until successful validation.

This rule simplifies alias creation. See "Aliases" section. It is a good idea to define custom error for your alias.

Errors: As we pass several sets of rules it is unclear what should validator return in case of several errors. Currenly we return the last error \(this bahavior can change in future, this rule is experimental\).

Examples:

"id" should be email or positive\_integer:

```text
{
    id: { or: ['email', 'positive_integer' ] }
}
```

Combining with other rules:

```text
{
    id: [{ or: ['email', 'positive_integer' ] }, 'to_lc']
}
```

Set of rules in "or":

```text
{
    id: { or: [['email', 'to_lc'], 'positive_integer' ] }
}
```

Emulate list\_of\_different\_objects:

```text
{
    products: {list_of: { or: [
        {nested_object: {
            product_type: ['required', {eq: 'material'}],
            material_id: ['required', 'positive_integer'],
            quantity: ['required', {'min_number': 1} ],
            warehouse_id: 'positive_integer'
        }},

        {nested_object: {
            product_type: ['required', {eq: 'service'}],
            name: ['required', {'max_length': 20} ]
        }}
    ]}}
}
```

is the same as

```text
{
    order_id: ['required', 'positive_integer'],
    products: ['required', { 'list_of_different_objects': [
        product_type, {
            material: {
                product_type: 'required',
                material_id: ['required', 'positive_integer'],
                quantity: ['required', {'min_number': 1} ],
                warehouse_id: 'positive_integer'
            },
            service: {
                product_type: 'required',
                name: ['required', {'max_length': 20} ]
            }
        }
    ]}]
}
```

_Internally there is a difference. "or" will try apply one rule after another, but "list\_of\_different\_objects" will select only one set of rules._

