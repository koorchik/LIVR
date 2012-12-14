Language Independent Validation Rules Specification (FIRST DRAFT)
===================================================

I tryed a lot of validators but I did not find any that meet all my needs. So, it was decided to create the ideal validator.

Requirements:

1. Rules must be declarative and language independent
2. Any quantity of rules for each field
3. Return together errors for all fields
4. Exclude all fields that do not have validation rules described
5. Possibility to stop on first failed field
6. Possibility to validatate complex hierarchical structures
7. Easy to described and undersand rules
8. Easy to implement own rules

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
Default Error: 'REQUIRED'

Example:
    
    {name: 'required'}

#### not_empty ####
Default Error: 'CANNOT_BE_EMPTY'

Example:
    
    {name: 'not_empty'}

#### is_in ####
Default Error: 'NOT_ALLOWED_VALUE'

Example:
    
    {name: {'is_in': [['val1', 'val2']]} }

### String Validators ###
#### max_length  ####
Default Error: 'TOO_LONG'

Example:
    
    {name: {max_length: [10] }

#### min_length ####
Default Error: 'TOO_SHORT'

Example:
    
    {name: {min_length: [2] }

#### length_between ####
Default Error: 'TOO_LONG' or 'TOO_SHORT'

Example:
    
    {name: {length_between: [5, 10] }

#### length_equal ####
Default Error: 'TOO_LONG' or 'TOO_SHORT'

Example:
    
    {name: {length_equal: [7] }

#### like ####
Default Error: 'WRONG_FORMAT'

Example:
    
    {name: {like: ['^\w+?$'] }

### Numeric Validators ###
#### integer ####
Default Error: 'NOT_INTEGER'

Example:
    
    {name: 'integer'}

#### positive_integer ####
Default Error: 'NOT_POSITIVE_INTEGER'

Example:
    
    {name: 'positive_integer'}


#### decimal ####
Default Error: 'NOT_DECIMAL'

Example:
    
    {name: 'decimal'}

#### positive_decimal ####
Default Error: 'NOT_POSITIVE_DECIMAL'

Example:
    
    {name: 'positive_decimal'}

#### max_number ####
Default Error: 'TOO_HIGH'

Example:
    
    {name: { 'max_number': [42] } }

#### min_number ####
Default Error: 'TOO_LOW'

Example:
    
    {name: { 'min_number': [42] } }

#### number_between ####
Default Error: 'TOO_HIGH' or 'TOO_LOW'

Example:
    
    {name: { 'number_between': [10, 42] } }

###  Special Validators ###
#### email ####
Default Error: 'WRONG_EMAIL'

Example:
    
    {name: 'email'}

#### equal_to_field ####
Default Error: 'WRONG_EMAIL'

Example:
    
    {password2: {'equal_to_field': ['password'] }}

## TODO ##

* Describe internals with detailed step-by-step example
* Write developers guide
* Provide links to existing implementation
