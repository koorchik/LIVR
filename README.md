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


###  Special Rules
#### email
Error code: 'WRONG_EMAIL'

Example:

```text
{login: 'email'}
```

#### url
Allows you to validate url. Allows 'HTTP' and 'HTTPS' protocols. Protocol is required.

Error code: 'WRONG_URL'

Example:

```text
{url: 'url'}
```

#### iso\_date

Check whether a value is an ISO 8601 date (without time). Allowed date example - "2014-08-14"

Error code: 'WRONG_DATE'

Example:

```text
{date: 'iso_date'}
```


#### equal\_to\_field
Error code: 'FIELDS\_NOT\_EQUAL'

Example:

```text
{password2: {'equal_to_field': 'password' }}
```

###  Metarules

Metarules are rules for describing more complex rules.

#### nested_object
Allows you to describe validation rules for a nested object.

Error code: depends on nested validators. If nested object is not a hash should return "FORMAT_ERROR"

Example:

```text
address: { 'nested_object': {
    city: 'required',
    zip: ['required', 'positive_integer']
} }
```


#### variable_object
Allows you to describe validation rules for field that can conatain different objects.

Error code: depends on nested validators. Or "FORMAT_ERROR" in case of receiving data not suitable for validation.

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

#### list_of
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

#### list_of_objects
Allows you to describe validation rules for list of objects. Validation rules will be applyed for each array element.

Error code: depends on nested validators. Or "FORMAT_ERROR" in case of receiving data not suitable for validation.

Example:

```text
products: ['required', { 'list_of_objects': [{
    product_id: ['required','positive_integer'],
    quantity: ['required', 'positive_integer']
}]}]
```

#### list_of_different_objects
Allows you to describe validation rules for list of different objects. Validation rules will be applied for each array element.

Error code: depends on nested validators. Or "FORMAT_ERROR" in case of receiving data not suitable for validation.

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

#### or (experimental)

The rule takes sets of other rules and applies them one after another until successful validation.

This rule simplifies alias creation. See "Aliases" section. It is a good idea to define custom error for your alias.

Errors: As we pass several sets of rules it is unclear what should validator return in case of several errors. Currenly we return the last error (this bahavior can change in future, this rule is experimental).

Examples:

"id" should be email or positive_integer:

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


Emulate list_of_different_objects:

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

*Internally there is a difference. "or" will try apply one rule after another, but "list_of_different_objects" will select only one set of rules.*

###  Modifiers

Additional rules for data modification. They do not return errors just skips values that are not appropriate.

#### trim
Removes leading and trailing spaces. Skips object references.

Example:

```text
{email: 'trim'}
```

#### to\_lc
Converts string to lower case. Skips object references.

Example:

```text
{email: 'to_lc'}
```

#### to\_uc
Converts string to upper case. Skips object references.

Example:

```text
{currency_code: 'to_uc'}
```

#### remove
Removes characters from string

Example:

```text
{ text: { remove: '0123456789' } }  // Remove all numbers from text
```

#### leave\_only
Removes characters from string

Example:

```text
{ text: { leave_only: '0123456789' } }  // Leaves only numbers in text
```

#### default
Set value if is not present.

Example:

```text
{ age: { default: 18 } }  // Sets age to 18 if not passed
```

## Rules aliasing

With rules aliasing you can create custom rules easely and assign own error codes in case own need. Moreover, aliased rules will work across all implementations as they are just data structures.

Alias struture:

```text
{
    name: ALIAS_NAME,
    rules: ALIAS_RULES,
    error: ERROR_CODE (optional)
}
```

If ERROR_CODE is empty than validator will return subrules errors.

Example:

```text
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
```

Moreover, you can use aliased rules in aliased rules.

###  Usage example

Let's assume that you have next data structure:

```text
{
    name: 'Viktor',
    age: 30,
    address: {
        country: 'Ukraine',
        city: 'Kiev',
        zip: '11111'
    }
}
```

And you have next validation rules for it:

```text
{
    name: 'required',
    age: ['required', 'positive_integer', { min_number: 18 } ],
    address: ['required', {nested_object: {
        country: 'required',
        city: 'required',
        zip: 'positive_integer'
    }}]
}
```

You use 'address' in a lot of your objects (user address in user, office address in office object and others) and you want to reuse the same address rules in all places.  You have two ways: write custom rule 'valid_address' or assign rules to a variable and just reuse the variable. The first way requires much time and coding. Moreover, you cannot save new rule implementation is serialzed JSON file. The second way is much easier and you can store rule implemetation in JSON file but you cannot store user validation rules. Moreover, the second way does not allow you to redefine error code for address.

From v0.4 you have the third way - rule aliasing.

You can register aliases for complex rules. The way how you register an alias depends on the implementation but the way how use and describe it is covered by the specification. This appoach allows you store aliases in serialized JSON files and then use them across different implementations.

```text
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
```

Moreover, you can add own error codes for the rules

For example

```text
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
```

and if validation of address fails you will have the next error

```text
{
    address: 'WRONG_ADDRESS'
}
```

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
