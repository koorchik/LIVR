Language Independent Validation Rules Specification (DRAFT)
===================================================

I tryed a lot of validators but I did not find any that meet all my needs. So, it was decided to create the ideal validator.

Requirements:

1. Rules must be declarative and language independent
2. Any number of rules for each field
3. Should return together errors for all fields
4. Exclude all fields that do not have validation rules described
5. Possibility to validatate complex hierarchical structures
6. Easy to describe and undersand rules
7. Should return understandable error codes(not error messages)
8. Easy to add own rules
9. Multipurpose (user input validation, configs validation, contracts programming etc)

## Rules Examples ##
**Simple registration data**

    {
        name: 'required',
        email: ['required', 'email'],
        gender: { one_of: [['male', 'female']] },
        phone: {max_length: 10},
        password: ['required', {min_length: 10} ]
        password2: { equal_to_field: 'password' }
    }

* 'required' is a shorter form of { 'required': [] }
* {max_length: 10} is a shorter form of {max_length: [10]}
*See "How it works" section*

**Simple validation of nested object**

    {
        name: 'required',
        phone: {max_length: 10},
        address: { 'nested_object': {
            city: 'required', 
            zip: ['required', 'positive_integer']
        }}
    }
* {nested_object: {}} is a shorter form of {nested_object: [{}]}
*See "How it works" section*

**Simple list validation**

    { 
        order_id: ['required', 'positive_integer'],
        product_ids: { 'list_of': [[ 'required',  'positive_integer' ]] }
    }


**Validating list of objects**

    {
        order_id: ['required', 'positive_integer'],
        products: [ 'required', { 'list_of_objects': {
            product_id: ['required','positive_integer'],
            quantity: ['required', 'positive_integer']
        }}]
    }

**Validating list of different objects**
    
    {
        order_id: ['required', 'positive_integer'],
        products: ['required', { 'list_of_different_objects': [
            'product_type', {
                material: {
                    material_id: ['required', 'positive_integer'],
                    quantity: ['required', {'min_number': 1} ],
                    warehouse_id: 'positive_integer'
                },
                service: {
                    name: ['required', {'max_lengh': 10} ]
                }
            }
        ]}]
    }

### How it works ###
You should define a structure: 
    FIELD_NAME: VALIDATION_RULE
* FIELD_NAME is a name of field to validate
* VALIDATION_RULE is a name of function to be called. It can be function that builds validator or maybe just a validation function itself. Some arguments cab be passed to the function - "{ VALIDATION_RULE: ARGUMENTS }". You may pass an array of validation rules. If you want to pass several arguments you should use array.

Examples:

'required' or {'required': [] } becomes:

    required();

{ 'max_length': 5 } or { 'max_length': [5] } becomes:

    max_length(5);    

{'length_between': [1,10] } becomes:

    length_between(1,10);

{'one_of': [['Kiev','Moscow']] } becomes:
    
    one_of(['Kiev', 'Moscow']);

{'my_own_rule': [1, [2, 3], 'bla'] } becomes: 

    my_own_rule(1, [2, 3], 'bla');

Validator receives value to validate and returns an error message(in case of failed validation) or empty string(in case of success). Thats all.

So, the idea is that there is a tiny core which can be easly extended with new rules. 


## Validation Rules ##
Be aware that all rules just skip checking empty values. 
So, empty string will pass next validation - "first_name: { min_length: [10] }". We have special rules "required" and "not_empty" to check that value is present. 
This allows us to use the same rules for not required fields.

    first_name: { min_length: [10] } # name is optional. We will check length only if "first_name" was passed
    first_name: [ 'required', { min_length: [10] } ] # check that the name is present and validate length


Standard rules that should be supported by every implementation:
 
 * Base Rules
    * required
    * not_empty
 * String Rules
    * one_of
    * max_length
    * min_length
    * length_between
    * length_equal
    * like
 * Numeric Rules
    * integer
    * positive_integer
    * decimal
    * positive_decimal
    * max_number
    * min_number
    * number_between
 * Special Rules
    * email
    * equal_to_field
 * Helper Rules
    * nested_object
    * list_of
    * list_of_objects
    * list_of_different_objects

### Base Rules ###
#### required ####
Error code: 'REQUIRED'

Example:
    
    {first_name: 'required'}

#### not_empty ####
Error code: 'CANNOT_BE_EMPTY'

Example:
    
    {first_name: 'not_empty'}

### String Rules ###
#### one_of ####
Error code: 'NOT_ALLOWED_VALUE'

Example:
    
    {first_name: {'one_of': [['Anton', 'Igor']]} }

#### max_length  ####
Error code: 'TOO_LONG'

Example:
    
    {first_name: {max_length: [10] }

#### min_length ####
Error code: 'TOO_SHORT'

Example:
    
    {first_name: {min_length: [2] }

#### length_between ####
Error code: 'TOO_LONG' or 'TOO_SHORT'

Example:
    
    {first_name: {length_between: [2, 10] }

#### length_equal ####
Error code: 'TOO_LONG' or 'TOO_SHORT'

Example:
    
    {first_name: {length_equal: [7] }

#### like ####
Error code: 'WRONG_FORMAT'

Example:
    
    {first_name: {like: ['^\w+?$'] }

Be aware that regelar expressions cab be language dependent. Try to use most common syntax.

### Numeric Rules ###
#### integer ####
Error code: 'NOT_INTEGER'

Example:
    
    {age: 'integer'}

#### positive_integer ####
Error code: 'NOT_POSITIVE_INTEGER'

Example:
    
    {age: 'positive_integer'}


#### decimal ####
Error code: 'NOT_DECIMAL'

Example:
    
    {price: 'decimal'}

#### positive_decimal ####
Error code: 'NOT_POSITIVE_DECIMAL'

Example:
    
    {price: 'positive_decimal'}

#### max_number ####
Error code: 'TOO_HIGH'

Example:
    
    {age: { 'max_number': [95] } }

#### min_number ####
Error code: 'TOO_LOW'

Example:
    
    {age: { 'min_number': [18] } }

#### number_between ####
Error code: 'TOO_HIGH' or 'TOO_LOW'

Example:
    
    {age: { 'number_between': [18, 95] } }

###  Special Rules ###
#### email ####
Error code: 'WRONG_EMAIL'

Example:
    
    {login: 'email'}

#### equal_to_field ####
Error code: 'WRONG_EMAIL'

Example:
    
    {password2: {'equal_to_field': ['password'] }}

###  Helper Rules ###
#### list_of ####
Allows you to describe validation rules for a list. Validation rules will be applyed for each array element.

Error code: depends on nested validators

Example:
    
    { product_ids: { 'list_of': [[ 'required',  'positive_integer' ]] }}

#### nested_object ####
Allows you to describe validation rules for a nested object.

Error code: depends on nested validators

Example:
    
    address: { 'nested_object': [{
        city: 'required', 
        zip: ['required', 'positive_integer']
    }]}


#### list_of_objects ####
Allows you to describe validation rules for list of objects. Validation rules will be applyed for each array element.

Error code: depends on nested validators

Example:
    
    products: ['required', { 'list_of_objects': [{
        product_id: ['required','positive_integer'],
        quantity: ['required', 'positive_integer']
    }]}]


#### list_of_different_objects ####
Allows you to describe validation rules for list of different objects. Validation rules will be applyed for each array element.

Error code: depends on nested validators

Example:

    products: ['required', { 'list_of_different_objects': [
        'product_type', {
            material: {
                material_id: ['required', 'positive_integer'],
                quantity: ['required', { 'min_number': [1]} ],
                warehouse_id: 'positive_integer'
            },
            service: {
                name: ['required', 'max_lengh': [10] ]
            }
        }
    }]]

In this example validator will look on "product_type" in each object and depending on it will use corresponding set of rules


## Developers Guide ##

Requirements to implementation

1. Your implementation should support all validation rules described in "Validation Rules"
2. Your implementation should return error codes descibed in specification
3. It should be easy to implement own rules

## TODO ##

* Describe internals with detailed step-by-step example
* Write developers guide
* Provide links to existing implementation
