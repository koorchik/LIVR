## Rules Examples

**Simple registration data **\[\(demo\)\]\([http://webbylab.github.io/livr-playground/\#{"rules"%3A"{\n    name%3A 'required'%2C\n    email%3A \['required'%2C 'email'\]%2C\n    gender%3A { one\_of%3A \[\['male'%2C 'female'\]\] }%2C\n    phone%3A {max\_length%3A 10}%2C\n    password%3A \['required'%2C {min\_length%3A 10} \]%2C\n    password2%3A { equal\_to\_field%3A 'password' }\n}"%2C"data"%3A"{\n    name%3A 'John'%2C\n    email%3A 'john%40mail.com'%2C\n    gender%3A 'male'%2C\n    phone%3A '%2B22221212'%2C\n    password%3A 'mypassword1'%2C\n    password2%3A 'mypassword1'\n}"}](http://webbylab.github.io/livr-playground/#{"rules"%3A"{\n    name%3A 'required'%2C\n    email%3A ['required'%2C 'email']%2C\n    gender%3A { one_of%3A [['male'%2C 'female']] }%2C\n    phone%3A {max_length%3A 10}%2C\n    password%3A ['required'%2C {min_length%3A 10} ]%2C\n    password2%3A { equal_to_field%3A 'password' }\n}"%2C"data"%3A"{\n    name%3A 'John'%2C\n    email%3A 'john%40mail.com'%2C\n    gender%3A 'male'%2C\n    phone%3A '%2B22221212'%2C\n    password%3A 'mypassword1'%2C\n    password2%3A 'mypassword1'\n}"})\)

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

**Simple validation of nested object **\[\(demo\)\]\([http://webbylab.github.io/livr-playground/\#{"rules"%3A"{\n    name%3A 'required'%2C\n    phone%3A {max\_length%3A 10}%2C\n    address%3A { 'nested\_object'%3A {\n        city%3A 'required'%2C \n        zip%3A \['required'%2C 'positive\_integer'\]\n    }}\n}"%2C"data"%3A"{\n    name%3A \"Michael\"%2C\n    phone%3A \"0441234567\"%2C\n    address%3A {\n        city%3A \"Kiev\"%2C \n        zip%3A \"30552\"\n    }\n}"}](http://webbylab.github.io/livr-playground/#{"rules"%3A"{\n    name%3A 'required'%2C\n    phone%3A {max_length%3A 10}%2C\n    address%3A { 'nested_object'%3A {\n        city%3A 'required'%2C \n        zip%3A ['required'%2C 'positive_integer']\n    }}\n}"%2C"data"%3A"{\n    name%3A \"Michael\"%2C\n    phone%3A \"0441234567\"%2C\n    address%3A {\n        city%3A \"Kiev\"%2C \n        zip%3A \"30552\"\n    }\n}"})\)

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

**Simple list validation **\[\(demo\)\]\([http://webbylab.github.io/livr-playground/\#{"rules"%3A"{\n    order\_id%3A \['required'%2C 'positive\_integer'\]%2C\n    product\_ids%3A { \n       'list\_of'%3A \[ 'required'%2C  'positive\_integer' \]\n    }\n}"%2C"data"%3A"{\n    order\_id%3A 10455%2C\n    product\_ids%3A \[3455%2C3456%2C3566\]\n}"}](http://webbylab.github.io/livr-playground/#{"rules"%3A"{\n    order_id%3A ['required'%2C 'positive_integer']%2C\n    product_ids%3A { \n       'list_of'%3A [ 'required'%2C  'positive_integer' ]\n    }\n}"%2C"data"%3A"{\n    order_id%3A 10455%2C\n    product_ids%3A [3455%2C3456%2C3566]\n}"})\)

```text
{
    order_id: ['required', 'positive_integer'],
    product_ids: { 'list_of': [ 'required',  'positive_integer' ] }
}
```

**Validating list of objects **\[\(demo\)\]\([http://webbylab.github.io/livr-playground/\#{"rules"%3A"{\n    order\_id%3A \['required'%2C 'positive\_integer'\]%2C\n    products%3A \[ 'not\_empty\_list'%2C { 'list\_of\_objects'%3A {\n        product\_id%3A \['required'%2C'positive\_integer'\]%2C\n        quantity%3A \['required'%2C 'positive\_integer'\]\n    }}\]\n}"%2C"data"%3A"{\n    order\_id%3A 10345%2C\n    products%3A \[{\n        product\_id%3A 3455%2C\n        quantity%3A2\n    }%2C{\n        product\_id%3A 3456%2C\n        quantity%3A3\n    }\]\n}"}](http://webbylab.github.io/livr-playground/#{"rules"%3A"{\n    order_id%3A ['required'%2C 'positive_integer']%2C\n    products%3A [ 'not_empty_list'%2C { 'list_of_objects'%3A {\n        product_id%3A ['required'%2C'positive_integer']%2C\n        quantity%3A ['required'%2C 'positive_integer']\n    }}]\n}"%2C"data"%3A"{\n    order_id%3A 10345%2C\n    products%3A [{\n        product_id%3A 3455%2C\n        quantity%3A2\n    }%2C{\n        product_id%3A 3456%2C\n        quantity%3A3\n    }]\n}"})\)

```text
{
    order_id: ['required', 'positive_integer'],
    products: [ 'not_empty_list', { 'list_of_objects': {
        product_id: ['required','positive_integer'],
        quantity: ['required', 'positive_integer']
    }}]
}
```

**Validating list of different objects **\[\(demo\)\]\([http://webbylab.github.io/livr-playground/\#{"rules"%3A"{\n    order\_id%3A \['required'%2C 'positive\_integer'\]%2C\n    products%3A \['required'%2C { 'list\_of\_different\_objects'%3A \[\n        product\_type%2C {\n            material%3A {\n                product\_type%3A 'required'%2C\n                material\_id%3A \['required'%2C 'positive\_integer'\]%2C\n                quantity%3A \['required'%2C {'min\_number'%3A 1} \]%2C\n                warehouse\_id%3A 'positive\_integer'\n            }%2C\n            service%3A {\n                product\_type%3A 'required'%2C\n                name%3A \['required'%2C {'max\_length'%3A 20} \]\n            }\n        }\n    \]}\]\n}"%2C"data"%3A"{\n    order\_id%3A 10455%2C\n    products%3A \[{ \n        product\_type%3A 'material'%2C\n        material\_id%3A 345%2C\n        quantity%3A  5%2C\n        warehouse\_id%3A 24\n    }%2C{\n        product\_type%3A 'service'%2C\n        name%3A 'Clean filter'\n    }\]\n}"}](http://webbylab.github.io/livr-playground/#{"rules"%3A"{\n    order_id%3A ['required'%2C 'positive_integer']%2C\n    products%3A ['required'%2C { 'list_of_different_objects'%3A [\n        product_type%2C {\n            material%3A {\n                product_type%3A 'required'%2C\n                material_id%3A ['required'%2C 'positive_integer']%2C\n                quantity%3A ['required'%2C {'min_number'%3A 1} ]%2C\n                warehouse_id%3A 'positive_integer'\n            }%2C\n            service%3A {\n                product_type%3A 'required'%2C\n                name%3A ['required'%2C {'max_length'%3A 20} ]\n            }\n        }\n    ]}]\n}"%2C"data"%3A"{\n    order_id%3A 10455%2C\n    products%3A [{ \n        product_type%3A 'material'%2C\n        material_id%3A 345%2C\n        quantity%3A  5%2C\n        warehouse_id%3A 24\n    }%2C{\n        product_type%3A 'service'%2C\n        name%3A 'Clean filter'\n    }]\n}"})\)

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

