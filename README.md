Language Independent Validation Rules (v2.0)
============================================

Validator meets the following requirements:

1. Rules are declarative and language independent
2. Any number of rules for each field
3. Validator should return together errors for all fields
4. Exclude all fields that do not have validation rules described
5. Possibility to validate complex hierarchical structures
6. Easy to describe and understand validation
7. Returns understandable error codes (neither error messages nor numeric codes)
8. Easy to implement own rules (usually you will have several in every project)
9. Rules should be able to change results output ("trim", "nested\_object", for example)
10. Multipurpose (user input validation, configs validation, contracts programming etc)
11. Unicode support

## Existing implemenations

* JavaScript (LIVR 2.0) - https://github.com/koorchik/js-validator-livr (Available for node.js(npm) and browsers)
* Perl (LIVR 2.0) - https://github.com/koorchik/Validator-LIVR (Available on CPAN)
* PHP (LIVR 0.4, previous version) - https://github.com/WebbyLab/php-validator-livr (https://packagist.org/packages/validator/livr)
* Python (LIVR 0.4, previous version) - https://github.com/asholok/python-validator-livr (https://pypi.python.org/pypi/LIVR)
* Erlang (LIVR 2.0) - https://github.com/Prots/olifer
* Ruby (LIVR 0.4, previous version) - https://github.com/maktwin/ruby-validator-livr (https://rubygems.org/gems/livr)

*Latest LIVR version is 2.0*
*Previous LIVR version is 0.4*

## Additional Tools

* Online JavaScript playground - http://webbylab.github.io/livr-playground/
* Online multi-language playground - http://livr-multi-playground.webbylab.com/

## Rules Examples
**Simple registration data** [(demo)](http://webbylab.github.io/livr-playground/#%7B%22rules%22%3A%22%7B%5Cn%20%20%20%20name%3A%20'required'%2C%5Cn%20%20%20%20email%3A%20%5B'required'%2C%20'email'%5D%2C%5Cn%20%20%20%20gender%3A%20%7B%20one_of%3A%20%5B%5B'male'%2C%20'female'%5D%5D%20%7D%2C%5Cn%20%20%20%20phone%3A%20%7Bmax_length%3A%2010%7D%2C%5Cn%20%20%20%20password%3A%20%5B'required'%2C%20%7Bmin_length%3A%2010%7D%20%5D%2C%5Cn%20%20%20%20password2%3A%20%7B%20equal_to_field%3A%20'password'%20%7D%5Cn%7D%22%2C%22data%22%3A%22%7B%5Cn%20%20%20%20name%3A%20'John'%2C%5Cn%20%20%20%20email%3A%20'john%40mail.com'%2C%5Cn%20%20%20%20gender%3A%20'male'%2C%5Cn%20%20%20%20phone%3A%20'%2B22221212'%2C%5Cn%20%20%20%20password%3A%20'mypassword1'%2C%5Cn%20%20%20%20password2%3A%20'mypassword1'%5Cn%7D%22%7D)

    {
        name: 'required',
        email: ['required', 'email'],
        gender: { one_of: ['male', 'female'] },
        phone: {max_length: 10},
        password: ['required', {min_length: 10} ]
        password2: { equal_to_field: 'password' }
    }


* 'required' is a shorter form of { 'required': [] }
* {max\_length: 10} is a shorter form of {max\_length: [10]}
*See "How it works" section*

**Simple validation of nested object** [(demo)](http://webbylab.github.io/livr-playground/#%7B%22rules%22%3A%22%7B%5Cn%20%20%20%20name%3A%20'required'%2C%5Cn%20%20%20%20phone%3A%20%7Bmax_length%3A%2010%7D%2C%5Cn%20%20%20%20address%3A%20%7B%20'nested_object'%3A%20%7B%5Cn%20%20%20%20%20%20%20%20city%3A%20'required'%2C%20%5Cn%20%20%20%20%20%20%20%20zip%3A%20%5B'required'%2C%20'positive_integer'%5D%5Cn%20%20%20%20%7D%7D%5Cn%7D%22%2C%22data%22%3A%22%7B%5Cn%20%20%20%20name%3A%20%5C%22Michael%5C%22%2C%5Cn%20%20%20%20phone%3A%20%5C%220441234567%5C%22%2C%5Cn%20%20%20%20address%3A%20%7B%5Cn%20%20%20%20%20%20%20%20city%3A%20%5C%22Kiev%5C%22%2C%20%5Cn%20%20%20%20%20%20%20%20zip%3A%20%5C%2230552%5C%22%5Cn%20%20%20%20%7D%5Cn%7D%22%7D)

    {
        name: 'required',
        phone: {max_length: 10},
        address: { 'nested_object': {
            city: 'required',
            zip: ['required', 'positive_integer']
        }}
    }
* {nested\_object: {}} is a shorter form of {nested\_object: [{}]}
*See "How it works" section*

**Simple list validation** [(demo)](http://webbylab.github.io/livr-playground/#%7B%22rules%22%3A%22%7B%5Cn%20%20%20%20order_id%3A%20%5B'required'%2C%20'positive_integer'%5D%2C%5Cn%20%20%20%20product_ids%3A%20%7B%20%5Cn%20%20%20%20%20%20%20'list_of'%3A%20%5B%20'required'%2C%20%20'positive_integer'%20%5D%5Cn%20%20%20%20%7D%5Cn%7D%22%2C%22data%22%3A%22%7B%5Cn%20%20%20%20order_id%3A%2010455%2C%5Cn%20%20%20%20product_ids%3A%20%5B3455%2C3456%2C3566%5D%5Cn%7D%22%7D)

    {
        order_id: ['required', 'positive_integer'],
        product_ids: { 'list_of': [ 'required',  'positive_integer' ] }
    }


**Validating list of objects** [(demo)](http://webbylab.github.io/livr-playground/#%7B%22rules%22%3A%22%7B%5Cn%20%20%20%20order_id%3A%20%5B'required'%2C%20'positive_integer'%5D%2C%5Cn%20%20%20%20products%3A%20%5B%20'not_empty_list'%2C%20%7B%20'list_of_objects'%3A%20%7B%5Cn%20%20%20%20%20%20%20%20product_id%3A%20%5B'required'%2C'positive_integer'%5D%2C%5Cn%20%20%20%20%20%20%20%20quantity%3A%20%5B'required'%2C%20'positive_integer'%5D%5Cn%20%20%20%20%7D%7D%5D%5Cn%7D%22%2C%22data%22%3A%22%7B%5Cn%20%20%20%20order_id%3A%2010345%2C%5Cn%20%20%20%20products%3A%20%5B%7B%5Cn%20%20%20%20%20%20%20%20product_id%3A%203455%2C%5Cn%20%20%20%20%20%20%20%20quantity%3A2%5Cn%20%20%20%20%7D%2C%7B%5Cn%20%20%20%20%20%20%20%20product_id%3A%203456%2C%5Cn%20%20%20%20%20%20%20%20quantity%3A3%5Cn%20%20%20%20%7D%5D%5Cn%7D%22%7D)

    {
        order_id: ['required', 'positive_integer'],
        products: [ 'not_empty_list', { 'list_of_objects': {
            product_id: ['required','positive_integer'],
            quantity: ['required', 'positive_integer']
        }}]
    }

**Validating list of different objects** [(demo)](http://webbylab.github.io/livr-playground/#%7B%22rules%22%3A%22%7B%5Cn%20%20%20%20order_id%3A%20%5B'required'%2C%20'positive_integer'%5D%2C%5Cn%20%20%20%20products%3A%20%5B'required'%2C%20%7B%20'list_of_different_objects'%3A%20%5B%5Cn%20%20%20%20%20%20%20%20product_type%2C%20%7B%5Cn%20%20%20%20%20%20%20%20%20%20%20%20material%3A%20%7B%5Cn%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20product_type%3A%20'required'%2C%5Cn%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20material_id%3A%20%5B'required'%2C%20'positive_integer'%5D%2C%5Cn%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20quantity%3A%20%5B'required'%2C%20%7B'min_number'%3A%201%7D%20%5D%2C%5Cn%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20warehouse_id%3A%20'positive_integer'%5Cn%20%20%20%20%20%20%20%20%20%20%20%20%7D%2C%5Cn%20%20%20%20%20%20%20%20%20%20%20%20service%3A%20%7B%5Cn%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20product_type%3A%20'required'%2C%5Cn%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20name%3A%20%5B'required'%2C%20%7B'max_length'%3A%2020%7D%20%5D%5Cn%20%20%20%20%20%20%20%20%20%20%20%20%7D%5Cn%20%20%20%20%20%20%20%20%7D%5Cn%20%20%20%20%5D%7D%5D%5Cn%7D%22%2C%22data%22%3A%22%7B%5Cn%20%20%20%20order_id%3A%2010455%2C%5Cn%20%20%20%20products%3A%20%5B%7B%20%5Cn%20%20%20%20%20%20%20%20product_type%3A%20'material'%2C%5Cn%20%20%20%20%20%20%20%20material_id%3A%20345%2C%5Cn%20%20%20%20%20%20%20%20quantity%3A%20%205%2C%5Cn%20%20%20%20%20%20%20%20warehouse_id%3A%2024%5Cn%20%20%20%20%7D%2C%7B%5Cn%20%20%20%20%20%20%20%20product_type%3A%20'service'%2C%5Cn%20%20%20%20%20%20%20%20name%3A%20'Clean%20filter'%5Cn%20%20%20%20%7D%5D%5Cn%7D%22%7D)

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

**Output modification**

    {
        email: ['trim', 'required', 'email', 'to_lc']
    }

* "trim" removes leading and trailing spaces. (skips empty values and object references)
* "to\_lc" transforms string to lower case. (skips empty values and object references)

You can create pipeline with any modifiers you like.

### How it works
You should define a structure:
    FIELD\_NAME: VALIDATION\_RULE
* FIELD\_NAME is a name of field to validate
* VALIDATION\_RULE is a name of function to be called. It can be function that builds validator or maybe just a validation function itself. Some arguments cab be passed to the function - "{ VALIDATION\_RULE: ARGUMENTS }". You may pass an array of validation rules. If you want to pass several arguments you should use array.

Examples:

'required' or {'required': [] } becomes:

    required();

{ 'max\_length': 5 } or { 'max\_length': [5] } becomes:

    max_length(5);

{'length\_between': [1,10] } becomes:

    length_between(1,10);

{'one\_of': [['Kiev','Moscow']] } (this is old syntax) becomes:

    one_of(['Kiev', 'Moscow']);

{'one\_of': ['Kiev','Moscow'] } (supported from v0.4)  becomes:

    one_of('Kiev', 'Moscow');

{'my\_own\_rule': [1, [2, 3], 'bla'] } becomes:

    my_own_rule(1, [2, 3], 'bla');

Validator receives value to validate and returns an error message(in case of failed validation) or empty string(in case of success). Thats all.

So, the idea is that there is a tiny core which can be easly extended with new rules.

## Validation Rules
Be aware that all standard rules just skip checking empty values.
So, empty string will pass next validation - "first_name: { min_length: [10] }". We have special rules "required" and "not_empty" to check that value is present.
This allows us to use the same rules for not required fields.

    first_name: { min_length: [10] } # name is optional. We will check length only if "first_name" was passed
    first_name: [ 'required', { min_length: [10] } ] # check that the name is present and validate length


### Types coercing

You should treat rules as expectations.  Therefore, all implementation make types coercing in numeric rules. This is reasonable because if someone says "positive_integer" then he expects to receive positive integer after validation.

We follow the same logic for string rules.  We compare values as string as rule are "string rules" but return what developer expects.  For example, if we use "eq" rule with input:

    {
        field1: 1,
        field2: 1
    }

and rules:

    {
        field1: {eq: "1"},
        field2: {eq: 1},
    }

output will be:

    {
        field1: "1",
        field2: 1
    }

[(demo)](http://webbylab.github.io/livr-playground/#%7B%22rules%22%3A%22%7B%5Cn%20%20%20field1%3A%20%7Beq%3A%201%7D%2C%5Cn%20%20%20field2%3A%20%7Beq%3A%20%5C%221%5C%22%7D%2C%5Cn%7D%22%2C%22data%22%3A%22%7B%20%5Cn%20%20%20%20field1%3A%201%2C%20%5Cn%20%20%20%20field2%3A%201%5Cn%7D%22%7D)


*What about the test suite? The test suite is stored in JSON format, therefore we can rely only on types that are supported by JSON. So, if we have input {field: "1"}, rules {field: 'positive_integer'} then the output will be { field: 1 }. As I see it should work. For example, JavaScript will coerce "1" to 1. And the test will pass. Perl will do nothing. And the test will pass. Please, let me know if there are any issues with this.*

Standard rules that should be supported by every implementation:

 * Common Rules
    * required
    * not\_empty
    * not\_empty\_list
    * any_object
 * String Rules
    * string
    * eq
    * one\_of
    * max\_length
    * min\_length
    * length\_between
    * length\_equal
    * like
 * Numeric Rules
    * integer
    * positive\_integer
    * decimal
    * positive\_decimal
    * max\_number
    * min\_number
    * number\_between
 * Special Rules
    * email
    * url
    * iso\_date
    * equal\_to\_field
 * Metarules
    * nested\_object
    * list\_of
    * list\_of\_objects
    * list\_of\_different\_objects
    * or
 * Modifiers (previously - "Filter rules")
    * trim
    * to\_lc
    * to\_uc
    * remove
    * leave\_only
    * default

### Common Rules
#### required
Error code: 'REQUIRED'

Example:

    {first_name: 'required'}

#### not\_empty
Error code: 'CANNOT_BE_EMPTY'

Example:

    {first_name: 'not_empty'}

#### not\_empty\_list
Checks that list contains at least one element

Error code: 'CANNOT\_BE\_EMPTY' (If the value is not present or list is empty). If the value is present but it is not a list the error code will be 'FORMAT\_ERROR'

Example:

    {products_ids: 'not_empty_list'}

#### any\_object
Checks that the value is an plain object

Error code: 'FORMAT\_ERROR' if the value is not a plain object.

Example:

    {address: 'any_object'}


### String Rules


#### string
Checks that value is primitive type and coerces it to the string. Better use more strict rules.

Example:

    {
        data: 'any' // validator will pass "data" field
        payload: ['required', 'string'] //
    }

You can treat this rule as modifier.

#### eq
Error code: 'NOT\_ALLOWED\_VALUE'

Example:
    { first_name: {'eq': 'Anton'} }


#### one\_of
Error code: 'NOT\_ALLOWED\_VALUE'

Example:

    // new syntax (introduced in v0.4)
    { first_name: {'one_of': ['Anton', 'Igor']} }

    // old syntax
    { first_name: {'one_of': [['Anton', 'Igor']]} }

#### max\_length
Error code: 'TOO\_LONG'

Example:

    {first_name: {max_length: 10}

#### min\_length
Error code: 'TOO\_SHORT'

Example:

    {first_name: {min_length: 2}

#### length\_between
Error code: 'TOO\_LONG' or 'TOO\_SHORT'

Example:

    {first_name: {length_between: [2, 10] }

#### length\_equal
Error code: 'TOO\_LONG' or 'TOO\_SHORT'

Example:

    {first_name: {length_equal: 7}

#### like
Error code: 'WRONG\_FORMAT'

Example:

    {first_name: {like: '^\w+?$'}
    {first_name: {like: ['^\w+?$', 'i']} // with flags

Only 'i' flag is currently required by specification.

**Be aware** that regular expressions can be language dependent. Try to use most common syntax. This rule is experimental as it requires more strict semantics.

### Numeric Rules
#### integer
Error code: 'NOT\_INTEGER'

Example:

    {age: 'integer'}

#### positive\_integer
Error code: 'NOT\_POSITIVE\_INTEGER'

Example:

    {age: 'positive_integer'}

#### decimal
Error code: 'NOT\_DECIMAL'

Example:

    {price: 'decimal'}

#### positive\_decimal
Error code: 'NOT\_POSITIVE_DECIMAL'

Example:

    {price: 'positive_decimal'}

#### max\_number
Error code: 'TOO\_HIGH' or 'NOT\_NUMBER'

Example:

    {age: { 'max_number': 95 } }

#### min\_number
Error code: 'TOO\_LOW' or 'NOT\_NUMBER'

Example:

    {age: { 'min_number': 18 } }

#### number\_between
Error code: 'TOO\_HIGH' or 'TOO\_LOW' or 'NOT\_NUMBER'

Example:

    {age: { 'number_between': [18, 95] } }

###  Special Rules
#### email
Error code: 'WRONG_EMAIL'

Example:

    {login: 'email'}

#### url
Allows you to validate url. Allows 'HTTP' and 'HTTPS' protocols. Protocol is required.

Error code: 'WRONG_URL'

Example:

    {url: 'url'}

#### iso\_date

Check whether a value is an ISO 8601 date (without time). Allowed date example - "2014-08-14"

Error code: 'WRONG_DATE'

Example:

    {date: 'iso_date'}


#### equal\_to\_field
Error code: 'FIELDS\_NOT\_EQUAL'

Example:

    {password2: {'equal_to_field': 'password' }}

###  Metarules

Metarules are rules for describing more complex rules.

#### nested_object
Allows you to describe validation rules for a nested object.

Error code: depends on nested validators. If nested object is not a hash should return "FORMAT_ERROR"

Example:

    address: { 'nested_object': {
        city: 'required',
        zip: ['required', 'positive_integer']
    } }


#### variable_object
Allows you to describe validation rules for field that can conatain different objects.

Error code: depends on nested validators. Or "FORMAT_ERROR" in case of receiving data not suitable for validation.

Example:

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


In this example validator will look on "product\_type" and depending on it will use corresponding set of rules

#### list_of
Allows you to describe validation rules for a list. Validation rules will be applyed for each array element.

Error code: depends on nested validators

Example:

    // new syntax (introduced in v0.4)
    { product_ids: { 'list_of': 'positive_integer' }}
    { product_ids: { 'list_of': ['required',  'positive_integer'] }} // new syntax

    // old syntax
    { product_ids: { 'list_of': [[ 'positive_integer' ]] }}
    { product_ids: { 'list_of': [[ 'required',  'positive_integer' ]] }}

#### list_of_objects
Allows you to describe validation rules for list of objects. Validation rules will be applyed for each array element.

Error code: depends on nested validators. Or "FORMAT_ERROR" in case of receiving data not suitable for validation.

Example:

    products: ['required', { 'list_of_objects': [{
        product_id: ['required','positive_integer'],
        quantity: ['required', 'positive_integer']
    }]}]


#### list_of_different_objects
Allows you to describe validation rules for list of different objects. Validation rules will be applied for each array element.

Error code: depends on nested validators. Or "FORMAT_ERROR" in case of receiving data not suitable for validation.

Example:

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


In this example validator will look on "product\_type" in each object and depending on it will use corresponding set of rules

#### or (experimental)

The rule takes sets of other rules and applies them one after another until successful validation.

This rule simplifies alias creation. See "Aliases" section. It is a good idea to define custom error for your alias.

Errors: As we pass several sets of rules it is unclear what should validator return in case of several errors. Currenly we return the last error (this bahavior can change in future, this rule is experimental).

Examples:

"id" should be email or positive_integer:

    {
        id: { or: ['email', 'positive_integer' ] }
    }


Combining with other rules:

    {
        id: [{ or: ['email', 'positive_integer' ] }, 'to_lc']
    }


Set of rules in "or":

    {
        id: { or: [['email', 'to_lc'], 'positive_integer' ] }
    }


Emulate list_of_different_objects:

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


is the same as

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

*Internally there is a difference. "or" will try apply one rule after another, but "list_of_different_objects" will select only one set of rules.*

###  Modifiers

Additional rules for data modification. They do not return errors just skips values that are not appropriate.

#### trim
Removes leading and trailing spaces. Skips object references.

Example:

    {email: 'trim'}

#### to\_lc
Converts string to lower case. Skips object references.

Example:

    {email: 'to_lc'}

#### to\_uc
Converts string to upper case. Skips object references.

Example:

    {currency_code: 'to_uc'}

#### remove
Removes characters from string

Example:

    { text: { remove: '0123456789' } }  // Remove all numbers from text

#### leave\_only
Removes characters from string

Example:

    { text: { leave_only: '0123456789' } }  // Leaves only numbers in text

#### default
Set value if is not present.

Example:

    { age: { default: 18 } }  // Sets age to 18 if not passed

## Rules aliasing

With rules aliasing you can create custom rules easely and assign own error codes in case own need. Moreover, aliased rules will work across all implementations as they are just data structures.

Alias struture:

    {
        name: ALIAS_NAME,
        rules: ALIAS_RULES,
        error: ERROR_CODE (optional)
    }

If ERROR_CODE is empty than validator will return subrules errors.

Example:

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

Moreover, you can use aliased rules in aliased rules.

###  Usage example

Let's assume that you have next data structure:

    {
        name: 'Viktor',
        age: 30,
        address: {
            country: 'Ukraine',
            city: 'Kiev',
            zip: '11111'
        }
    }

And you have next validation rules for it:

    {
        name: 'required',
        age: ['required', 'positive_integer', { min_number: 18 } ],
        address: ['required', {nested_object: {
            country: 'required',
            city: 'required',
            zip: 'positive_integer'
        }}]
    }

You use 'address' in a lot of your objects (user address in user, office address in office object and others) and you want to reuse the same address rules in all places.  You have two ways: write custom rule 'valid_address' or assign rules to a variable and just reuse the variable. The first way requires much time and coding. Moreover, you cannot save new rule implementation is serialzed JSON file. The second way is much easier and you can store rule implemetation in JSON file but you cannot store user validation rules. Moreover, the second way does not allow you to redefine error code for address.

From v0.4 you have the third way - rule aliasing.

You can register aliases for complex rules. The way how you register an alias depends on the implementation but the way how use and describe it is covered by the specification. This appoach allows you store aliases in serialized JSON files and then use them across different implementations.

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

Moreover, you can add own error codes for the rules

For example

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

and if validation of address fails you will have the next error

    {
        address: 'WRONG_ADDRESS'
    }


## Developers Guide

Requirements to implementation

1. Your implementation should support all validation rules described in "Validation Rules"
2. Your implementation should support "Rules aliasing"
3. Your implementation should return error codes descibed in the specification
4. It should be easy to implement own rules
5. Please, use provided "test\_suite" to ensure that your implementation works correctly

## Changes

### v0.2

 * Added not\_empty\_list rule with test cases

### v0.3

 * Added filter rule "trim"
 * Added filter rule "to\_lc"
 * Added filter rule "to\_uc"

### v0.4

 * Added special rules (url, iso\_date)
 * Added filter rules (remove, leave_only)
 * Add flags 'i' flag support to the "like" rule
 * Introduces new syntax for "one_of" and "list_of" rules. (See "Syntax changes for 'one_of' and 'list_of' rules")
 * Rules aliasing (with custom errors)

### v2.0
 * Switched to semver. New release version is 2.0
 * Unified approach to types handling
 * "Base rules" renamed to "Common rules".
 * "Filter rules" renamed to "Modifiers". They do not validate anything, just modify data.
 * "Helper rules" renamed to "Metarules" as this rules are for describing other rules
 * Added common rule "any_object"
 * Added string rule "string"
 * Added string rule "eq"
 * Added metarule "variable_object"
 * Added metarule "or"
 * Added modifier "default"
 * Add more edge cases to test suite
 * Add experimental status to the "like" rule

## Syntax changes for 'one_of' and 'list_of' rules
Old syntax {one_of: [['val1', 'val2']]} was hard to remember for many people. The idea was that list of allowed values should be passed as array reference. So, {one_of: [['val1', 'val2']]} becomes one_of(['val1', 'val2']) but it is not always clear for users. Therefore, it was decided to introduce a new syntax. Now you can write {one_of: ['val1', 'val2']} that becomes one_of('val1', 'val2'). The main problem with it that you do not know how many arguments will be passed to 'one_of'. Moreover, you should support both syntaxes for backward compatibility (test suite contains tests for both cases). But it was decided that "one_of" and "list_of" rules can handle both syntaxes by themselves.

## TODO

* Add JSON Schema comparison
* Describe internals with detailed step-by-step example
* Write developers guide

# LICENSE AND COPYRIGHT

Copyright 2012 Viktor Turskyi.

This program is free software; you can redistribute it and/or modify it under the terms of the the Artistic License (2.0). You may obtain a copy of the full license at:

http://www.perlfoundation.org/artistic\_license\_2\_0

Any use, modification, and distribution of the Standard or Modified Versions is governed by this Artistic License. By using, modifying or distributing the Package, you accept this license. Do not use, modify, or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made by someone other than you, you are nevertheless required to ensure that your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge patent license to make, have made, use, offer to sell, sell, import and otherwise transfer the Package with respect to any patent claims licensable by the Copyright Holder that are necessarily infringed by the Package. If you institute patent litigation (including a cross-claim or counterclaim) against any party alleging that the Package constitutes direct or contributory patent infringement, then this Artistic License to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES. THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
