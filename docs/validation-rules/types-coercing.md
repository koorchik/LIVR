# Types coercing

Treat rules as expectations. If someone writes `positive_integer`, they expect to get a positive integer after validation. That is why all implementations coerce types in numeric rules: the string `"25"` passes `positive_integer` and is returned as the number `25`.

String rules follow the same logic. They compare values as strings, because they are string rules, but they return what the developer expects. For example, with the `eq` rule:

```livr
// rules
{
    field1: { eq: '1' },
    field2: { eq: 1 }
}
// input
{
    field1: 1,
    field2: 1
}
```

the output is `{ field1: "1", field2: 1 }`: each field gets the value from the rule.

The `string` rule accepts any primitive value and returns it as a string, so it can be treated as a modifier as well.

## The test suite and types

The [test suite](/how-to-contribute/test-suite.html) is stored as JSON, so it can rely only on the types that JSON supports. For example, for the input `{ field: "1" }` and the rules `{ field: 'positive_integer' }` the expected output is `{ field: 1 }`. JavaScript coerces `"1"` to `1` and the test passes. Perl does not distinguish between the two values and the test passes as well. If you find a case where this does not work for your language, please [open an issue](https://github.com/koorchik/LIVR/issues/new).
