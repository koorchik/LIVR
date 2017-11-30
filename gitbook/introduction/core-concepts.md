## Core concepts

#### LIVR Specification

Since the task was to make the validator independent of the programming language, a sort of mustache / handlebars, but only in the world of data validation, we started with the specification writing.

**Purpose of the specification:**

1. Standardize the data description format.
2. Describe the minimum set of validation rules that must be supported by each implementation.
3. Standardize error codes.
4. Be a single basic documentation for all implementations.
5. Have a set of test data that allows you to verify the implementation for compliance with the specification

The specification is available in [Documentation](../../README.md#documentation).

The basic idea was that the description of the validation rules should look like a data schema and be as similar to data as possible, only instead of the rule values.

See: [Examples](examples.md) and [Validation Rules](../validation-rules.md).

#### Why not JSON Schema? {#why-not-json-schema}

Frequently Asked Question. Briefly, there are several reasons:
* A complex format for the rules. I want the structure with the rules to be as close as possible to the data structure. Try to describe this example on JSON Schema
* The error format is not specified in any way and different implementations return errors in a different format.
* There is no data conversion, for example "to_lc".

JSON Schema contains interesting things, such as the ability to set the maximum number of items in the list, but in LIVR this is implemented simply by adding one more rule.