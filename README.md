Language Independent Validation Rules Specification
===================================================

1. Rules must be declarative and language independent
2. Easy to use
3. Easy to extend

## Simple Rules Example ##
    {
        name: 'required', 
        email: ['required', 'email'] 
    }

## Standard validator shortcuts ##

    [ {'min_length': [1]}, {'max_length': [10]}, { is_in: [['a', 'b']] }]

    [ {'min_length': [1]}, {'max_length': [10]}, { is_in: [['a', 'b']] }]

    ['required', { between: [10, 20] } ]

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

### How it works ###
You should define a structure: 
    FIELD_NAME: VALIDATION_RULES
* FIELD_NAME is a name of field to validate
* VALIDATION_RULES is a name of function((or array of functions) to be called for validation.

Validation function receives value to validate and return an error message(in case of failed validation) or empty string(in case of success)
Thats all.
