### Types coercing

You should treat rules as expectations.  Therefore, all implementation make types coercing in numeric rules. This is reasonable because if someone says "positive\_integer" then he expects to receive positive integer after validation.

We follow the same logic for string rules.  We compare values as string as rule are "string rules" but return what developer expects.  For example, if we use "eq" rule with input:

```text
{
    field1: 1,
    field2: 1
}
```

and rules:

```text
{
    field1: {eq: "1"},
    field2: {eq: 1},
}
```

output will be:

```text
{
    field1: "1",
    field2: 1
}
```

[\(demo\)](http://webbylab.github.io/livr-playground/#%7B%22rules%22%3A%22%7B%5Cn%20%20%20field1%3A%20%7Beq%3A%201%7D%2C%5Cn%20%20%20field2%3A%20%7Beq%3A%20%5C%221%5C%22%7D%2C%5Cn%7D%22%2C%22data%22%3A%22%7B%20%5Cn%20%20%20%20field1%3A%201%2C%20%5Cn%20%20%20%20field2%3A%201%5Cn%7D%22%7D)

_What about the test suite? The test suite is stored in JSON format, therefore we can rely only on types that are supported by JSON. So, if we have input {field: "1"}, rules {field: 'positive\_integer'} then the output will be { field: 1 }. As I see it should work. For example, JavaScript will coerce "1" to 1. And the test will pass. Perl will do nothing. And the test will pass. Please, let me know if there are any issues with this._

