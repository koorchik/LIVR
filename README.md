Language Independent Validation Rules Specification (FIRST DRAFT)
===================================================

I tryed a lot of validators but I did not find any that meet all my needs. So, it was decided to create the ideal validator.

Requirements:

1. Rules must be declarative and language independent
2. Any number of rules for each field
3. Should return together errors for all fields
4. Exclude all fields that do not have validation rules described
5. Possibility to stop on first failed rule
6. Possibility to validatate complex hierarchical structures
7. Easy to described and undersand rules
8. Should return understandable error codes(not error messages).
9. Easy to implement own rules

## Rules Examples ##
**Simple registration data**

    {
        name: 'required',
        phone: {'max_length': [10]},
        email: ['required', 'email']
        password: ['required', {'min_length': [10]} ]
        password2: { equal_to_field: ['password2'] }
    }

**Sub list validation**

    {
        order_id: ['required', 'positive_integer'],
        products: ['is_required', 'is_valid_list': [{
            product_id: ['required','positive_integer'],
            quantity: ['required', 'positive_integer']
        }]]
    }

**Sub list with conditional rules set**

    {
        order_id: ['required', 'positive_integer'],
        products: ['is_required', 'is_valid_multitype_list': [
            'product_type': {
                material: {
                    material_id: ['required', 'positive_integer'],
                    quantity: ['required', { 'min_number': [1]} ],
                    warehouse_id: 'positive_integer'
                },
                service: {
                    name: ['required', 'max_lengh': [10] ]
                }
            }
        ]]
    }

### How it works ###
You should define a structure: 
    FIELD_NAME: VALIDATION_RULE
* FIELD_NAME is a name of field to validate
* VALIDATION_RULE is a name of function to be called for building validator callback/object. Some arguments cab be passed to the function - "{ VALIDATION_RULE: ARGUMENTS }". You may pass an array of validation rules.

Examples:

* 'required' or {'required': [] } becomes "required()"
* {'length_between': [1,10] } becomes "length_between(1,10)"
* {'in': [['Kiev','Moscow']] } becomes "in(['Kiev', 'Moscow'])"
* {'my_own_rule': [1, 2, 'bla'] } becomes "my_own_rule(1, 2, 'bla')"

Validator callback/object receives value to validate and returns an error message(in case of failed validation) or empty string(in case of success). Thats all.

## Validation Rules ##
### Base Validators ###
#### required ####
Error code: 'REQUIRED'

Example:
    
    {first_name: 'required'}

#### not_empty ####
Error code: 'CANNOT_BE_EMPTY'

Example:
    
    {first_name: 'not_empty'}

#### is_in ####
Error code: 'NOT_ALLOWED_VALUE'

Example:
    
    {first_name: {'is_in': [['Anton', 'Igor']]} }

### String Validators ###
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

### Numeric Validators ###
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

###  Special Validators ###
#### email ####
Error code: 'WRONG_EMAIL'

Example:
    
    {login: 'email'}

#### equal_to_field ####
Error code: 'WRONG_EMAIL'

Example:
    
    {password2: {'equal_to_field': ['password'] }}

## TODO ##

* Describe internals with detailed step-by-step example
* Write developers guide
* Provide links to existing implementation
