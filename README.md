# Language Independent Validation Rules \(v2.0\)

Validator meets the following requirements:

1. Rules are declarative and language independent
2. Any number of rules for each field
3. Validator should return together errors for all fields
4. Exclude all fields that do not have validation rules described
5. Possibility to validate complex hierarchical structures
6. Easy to describe and understand validation
7. Returns understandable error codes \(neither error messages nor numeric codes\)
8. Easy to implement own rules \(usually you will have several in every project\)
9. Rules should be able to change results output \("trim", "nested\_object", for example\)
10. Multipurpose \(user input validation, configs validation, contracts programming etc\)
11. Unicode support

## Existing implemenations

* [JavaScript \(LIVR 2.0\)](https://github.com/koorchik/js-validator-livr) available at [npm](https://www.npmjs.com/package/livr), maintainer @koorchik
* [Perl \(LIVR 2.0\)](https://github.com/koorchik/Validator-LIVR) available at [CPAN](https://metacpan.org/pod/Validator::LIVR), maintainer @koorchik
* [PHP \(LIVR 2.0\)](https://github.com/WebbyLab/php-validator-livr) available at [packagist](https://packagist.org/packages/validator/livr), maintainer @WebbyLab
* [Python \(LIVR 2.0\)](https://github.com/asholok/python-validator-livr) available at [pypi](https://pypi.python.org/pypi/LIVR), maintainer @asholok
* [Erlang \(LIVR 2.0\)](https://github.com/Prots/olifer), maintainer @Prots
* [Java \(LIVR 2.0\)](https://github.com/vlbaluk/java-validator-livr), maintainer @vlbaluk
* [Ruby \(LIVR 0.4, previous version\)](https://github.com/maktwin/ruby-validator-livr) at [rubygems](https://rubygems.org/gems/livr), maintainer @maktwin

_Latest LIVR version is 2.0_  
_Previous LIVR version is 0.4_

## Additional Tools {#additional-tools}

* [Online JavaScript playground](http://webbylab.github.io/livr-playground/)
* [Online multi-language playground](http://livr-multi-playground.webbylab.com/)

### 

### Rules aliasing

With rules aliasing you can create custom rules easely and assign own error codes in case own need. Moreover, aliased rules will work across all implementations as they are just data structures.

Alias struture:

```text
{
    name: ALIAS_NAME,
    rules: ALIAS_RULES,
    error: ERROR_CODE (optional)
}
```

If ERROR\_CODE is empty than validator will return subrules errors.

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

### Usage example

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

You use 'address' in a lot of your objects \(user address in user, office address in office object and others\) and you want to reuse the same address rules in all places.  You have two ways: write custom rule 'valid\_address' or assign rules to a variable and just reuse the variable. The first way requires much time and coding. Moreover, you cannot save new rule implementation is serialzed JSON file. The second way is much easier and you can store rule implemetation in JSON file but you cannot store user validation rules. Moreover, the second way does not allow you to redefine error code for address.

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

* Added special rules \(url, iso\_date\)
* Added filter rules \(remove, leave\_only\)
* Add flags 'i' flag support to the "like" rule
* Introduces new syntax for "one\_of" and "list\_of" rules. \(See "Syntax changes for 'one\_of' and 'list\_of' rules"\)
* Rules aliasing \(with custom errors\)

### v2.0

* Switched to semver. New release version is 2.0
* Unified approach to types handling
* "Base rules" renamed to "Common rules".
* "Filter rules" renamed to "Modifiers". They do not validate anything, just modify data.
* "Helper rules" renamed to "Metarules" as this rules are for describing other rules
* Added common rule "any\_object"
* Added string rule "string"
* Added string rule "eq"
* Added metarule "variable\_object"
* Added metarule "or"
* Added modifier "default"
* Add more edge cases to test suite
* Add experimental status to the "like" rule

## Syntax changes for 'one\_of' and 'list\_of' rules

Old syntax {one\_of: \[\['val1', 'val2'\]\]} was hard to remember for many people. The idea was that list of allowed values should be passed as array reference. So, {one\_of: \[\['val1', 'val2'\]\]} becomes one\_of\(\['val1', 'val2'\]\) but it is not always clear for users. Therefore, it was decided to introduce a new syntax. Now you can write {one\_of: \['val1', 'val2'\]} that becomes one\_of\('val1', 'val2'\). The main problem with it that you do not know how many arguments will be passed to 'one\_of'. Moreover, you should support both syntaxes for backward compatibility \(test suite contains tests for both cases\). But it was decided that "one\_of" and "list\_of" rules can handle both syntaxes by themselves.

## TODO

* Add JSON Schema comparison
* Describe internals with detailed step-by-step example
* Write developers guide

# LICENSE AND COPYRIGHT

Copyright 2012 Viktor Turskyi.

This program is free software; you can redistribute it and/or modify it under the terms of the the Artistic License \(2.0\). You may obtain a copy of the full license at:

[http://www.perlfoundation.org/artistic\_license\_2\_0](http://www.perlfoundation.org/artistic_license_2_0)

Any use, modification, and distribution of the Standard or Modified Versions is governed by this Artistic License. By using, modifying or distributing the Package, you accept this license. Do not use, modify, or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made by someone other than you, you are nevertheless required to ensure that your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge patent license to make, have made, use, offer to sell, sell, import and otherwise transfer the Package with respect to any patent claims licensable by the Copyright Holder that are necessarily infringed by the Package. If you institute patent litigation \(including a cross-claim or counterclaim\) against any party alleging that the Package constitutes direct or contributory patent infringement, then this Artistic License to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES. THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

