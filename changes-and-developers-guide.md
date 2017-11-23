### Developers Guide

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



