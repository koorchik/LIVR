## Rules Examples

**Simple registration data **[\(demo\)](http://webbylab.github.io/livr-playground/#%7B%22rules%22%3A%22%7B%5Cn%20%20%20%20name%3A%20'required'%2C%5Cn%20%20%20%20email%3A%20%5B'required'%2C%20'email'%5D%2C%5Cn%20%20%20%20gender%3A%20%7B%20one_of%3A%20%5B%5B'male'%2C%20'female'%5D%5D%20%7D%2C%5Cn%20%20%20%20phone%3A%20%7Bmax_length%3A%2010%7D%2C%5Cn%20%20%20%20password%3A%20%5B'required'%2C%20%7Bmin_length%3A%2010%7D%20%5D%2C%5Cn%20%20%20%20password2%3A%20%7B%20equal_to_field%3A%20'password'%20%7D%5Cn%7D%22%2C%22data%22%3A%22%7B%5Cn%20%20%20%20name%3A%20'John'%2C%5Cn%20%20%20%20email%3A%20'john%40mail.com'%2C%5Cn%20%20%20%20gender%3A%20'male'%2C%5Cn%20%20%20%20phone%3A%20'%2B22221212'%2C%5Cn%20%20%20%20password%3A%20'mypassword1'%2C%5Cn%20%20%20%20password2%3A%20'mypassword1'%5Cn%7D%22%7D)

```text
{
    name: 'required',
    email: ['required', 'email'],
    gender: { one_of: ['male', 'female'] },
    phone: {max_length: 10},
    password: ['required', {min_length: 10} ]
    password2: { equal_to_field: 'password' }
}
```

* 'required' is a shorter form of { 'required': \[\] }
* {max\_length: 10} is a shorter form of {max\_length: \[10\]}
* _See "How it works" section_

**Simple validation of nested object **[\(demo\)](http://webbylab.github.io/livr-playground/#%7B%22rules%22%3A%22%7B%5Cn%20%20%20%20name%3A%20'required'%2C%5Cn%20%20%20%20phone%3A%20%7Bmax_length%3A%2010%7D%2C%5Cn%20%20%20%20address%3A%20%7B%20'nested_object'%3A%20%7B%5Cn%20%20%20%20%20%20%20%20city%3A%20'required'%2C%20%5Cn%20%20%20%20%20%20%20%20zip%3A%20%5B'required'%2C%20'positive_integer'%5D%5Cn%20%20%20%20%7D%7D%5Cn%7D%22%2C%22data%22%3A%22%7B%5Cn%20%20%20%20name%3A%20%5C%22Michael%5C%22%2C%5Cn%20%20%20%20phone%3A%20%5C%220441234567%5C%22%2C%5Cn%20%20%20%20address%3A%20%7B%5Cn%20%20%20%20%20%20%20%20city%3A%20%5C%22Kiev%5C%22%2C%20%5Cn%20%20%20%20%20%20%20%20zip%3A%20%5C%2230552%5C%22%5Cn%20%20%20%20%7D%5Cn%7D%22%7D)

```text
{
    name: 'required',
    phone: {max_length: 10},
    address: { 'nested_object': {
        city: 'required',
        zip: ['required', 'positive_integer']
    }}
}
```

* {nested\_object: {}} is a shorter form of {nested\_object: \[{}\]}
* _See "How it works" section_

**Simple list validation **[\(demo\)](http://webbylab.github.io/livr-playground/#%7B%22rules%22%3A%22%7B%5Cn%20%20%20%20order_id%3A%20%5B'required'%2C%20'positive_integer'%5D%2C%5Cn%20%20%20%20product_ids%3A%20%7B%20%5Cn%20%20%20%20%20%20%20'list_of'%3A%20%5B%20'required'%2C%20%20'positive_integer'%20%5D%5Cn%20%20%20%20%7D%5Cn%7D%22%2C%22data%22%3A%22%7B%5Cn%20%20%20%20order_id%3A%2010455%2C%5Cn%20%20%20%20product_ids%3A%20%5B3455%2C3456%2C3566%5D%5Cn%7D%22%7D)

```text
{
    order_id: ['required', 'positive_integer'],
    product_ids: { 'list_of': [ 'required',  'positive_integer' ] }
}
```

**Validating list of objects **[\(demo\)](http://webbylab.github.io/livr-playground/#%7B%22rules%22%3A%22%7B%5Cn%20%20%20%20order_id%3A%20%5B'required'%2C%20'positive_integer'%5D%2C%5Cn%20%20%20%20products%3A%20%5B%20'not_empty_list'%2C%20%7B%20'list_of_objects'%3A%20%7B%5Cn%20%20%20%20%20%20%20%20product_id%3A%20%5B'required'%2C'positive_integer'%5D%2C%5Cn%20%20%20%20%20%20%20%20quantity%3A%20%5B'required'%2C%20'positive_integer'%5D%5Cn%20%20%20%20%7D%7D%5D%5Cn%7D%22%2C%22data%22%3A%22%7B%5Cn%20%20%20%20order_id%3A%2010345%2C%5Cn%20%20%20%20products%3A%20%5B%7B%5Cn%20%20%20%20%20%20%20%20product_id%3A%203455%2C%5Cn%20%20%20%20%20%20%20%20quantity%3A2%5Cn%20%20%20%20%7D%2C%7B%5Cn%20%20%20%20%20%20%20%20product_id%3A%203456%2C%5Cn%20%20%20%20%20%20%20%20quantity%3A3%5Cn%20%20%20%20%7D%5D%5Cn%7D%22%7D)

```text
{
    order_id: ['required', 'positive_integer'],
    products: [ 'not_empty_list', { 'list_of_objects': {
        product_id: ['required','positive_integer'],
        quantity: ['required', 'positive_integer']
    }}]
}
```

**Validating list of different objects **[\(demo\)](http://webbylab.github.io/livr-playground/#%7B%22rules%22%3A%22%7B%5Cn%20%20%20%20order_id%3A%20%5B'required'%2C%20'positive_integer'%5D%2C%5Cn%20%20%20%20products%3A%20%5B'required'%2C%20%7B%20'list_of_different_objects'%3A%20%5B%5Cn%20%20%20%20%20%20%20%20product_type%2C%20%7B%5Cn%20%20%20%20%20%20%20%20%20%20%20%20material%3A%20%7B%5Cn%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20product_type%3A%20'required'%2C%5Cn%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20material_id%3A%20%5B'required'%2C%20'positive_integer'%5D%2C%5Cn%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20quantity%3A%20%5B'required'%2C%20%7B'min_number'%3A%201%7D%20%5D%2C%5Cn%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20warehouse_id%3A%20'positive_integer'%5Cn%20%20%20%20%20%20%20%20%20%20%20%20%7D%2C%5Cn%20%20%20%20%20%20%20%20%20%20%20%20service%3A%20%7B%5Cn%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20product_type%3A%20'required'%2C%5Cn%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20name%3A%20%5B'required'%2C%20%7B'max_length'%3A%2020%7D%20%5D%5Cn%20%20%20%20%20%20%20%20%20%20%20%20%7D%5Cn%20%20%20%20%20%20%20%20%7D%5Cn%20%20%20%20%5D%7D%5D%5Cn%7D%22%2C%22data%22%3A%22%7B%5Cn%20%20%20%20order_id%3A%2010455%2C%5Cn%20%20%20%20products%3A%20%5B%7B%20%5Cn%20%20%20%20%20%20%20%20product_type%3A%20'material'%2C%5Cn%20%20%20%20%20%20%20%20material_id%3A%20345%2C%5Cn%20%20%20%20%20%20%20%20quantity%3A%20%205%2C%5Cn%20%20%20%20%20%20%20%20warehouse_id%3A%2024%5Cn%20%20%20%20%7D%2C%7B%5Cn%20%20%20%20%20%20%20%20product_type%3A%20'service'%2C%5Cn%20%20%20%20%20%20%20%20name%3A%20'Clean%20filter'%5Cn%20%20%20%20%7D%5D%5Cn%7D%22%7D)

```text
{
    order_id: ['required', 'positive_integer'],
    products: ['required', { 'list_of_different_objects': [
        'product_type', {
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
}
```

**Output modification**

```text
{
    email: ['trim', 'required', 'email', 'to_lc']
}
```

* "trim" removes leading and trailing spaces. \(skips empty values and object references\)
* "to\_lc" transforms string to lower case. \(skips empty values and object references\)

You can create pipeline with any modifiers you like.

