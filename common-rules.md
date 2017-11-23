### Common Rules
#### required
Error code: 'REQUIRED'

Example:

```text
{first_name: 'required'}
```

#### not\_empty
Error code: 'CANNOT_BE_EMPTY'

Example:

```text
{first_name: 'not_empty'}
```

#### not\_empty\_list
Checks that list contains at least one element

Error code: 'CANNOT\_BE\_EMPTY' (If the value is not present or list is empty). If the value is present but it is not a list the error code will be 'FORMAT\_ERROR'

Example:

```text
{products_ids: 'not_empty_list'}
```

#### any\_object
Checks that the value is an plain object

Error code: 'FORMAT\_ERROR' if the value is not a plain object.

Example:

```text
{address: 'any_object'}
```


### String Rules


#### string
Checks that value is primitive type and coerces it to the string. Better use more strict rules.

Example:

```text
{
    data: 'any' // validator will pass "data" field
    payload: ['required', 'string'] //
}
```

You can treat this rule as modifier.

#### eq
Error code: 'NOT\_ALLOWED\_VALUE'

Example:

```text
{ first_name: {'eq': 'Anton'} }
```


#### one\_of
Error code: 'NOT\_ALLOWED\_VALUE'

Example:

```text
// new syntax (introduced in v0.4)
{ first_name: {'one_of': ['Anton', 'Igor']} }

// old syntax
{ first_name: {'one_of': [['Anton', 'Igor']]} }
```

#### max\_length
Error code: 'TOO\_LONG'

Example:

```text
{first_name: {max_length: 10}
```

#### min\_length
Error code: 'TOO\_SHORT'

Example:

```text
{first_name: {min_length: 2}
```

#### length\_between
Error code: 'TOO\_LONG' or 'TOO\_SHORT'

Example:

```text
{first_name: {length_between: [2, 10] }
```

#### length\_equal
Error code: 'TOO\_LONG' or 'TOO\_SHORT'

Example:

```text
{first_name: {length_equal: 7}
```

#### like
Error code: 'WRONG\_FORMAT'

Example:

```text
{first_name: {like: '^\w+?$'}
{first_name: {like: ['^\w+?$', 'i']} // with flags
```

Only 'i' flag is currently required by specification.

**Be aware** that regular expressions can be language dependent. Try to use most common syntax. This rule is experimental as it requires more strict semantics.

### Numeric Rules
#### integer
Error code: 'NOT\_INTEGER'

Example:

```text
{age: 'integer'}
```

#### positive\_integer
Error code: 'NOT\_POSITIVE\_INTEGER'

Example:

```text
{age: 'positive_integer'}
```

#### decimal
Error code: 'NOT\_DECIMAL'

Example:

```text
{price: 'decimal'}
```

#### positive\_decimal
Error code: 'NOT\_POSITIVE_DECIMAL'

Example:

```text
{price: 'positive_decimal'}
```

#### max\_number
Error code: 'TOO\_HIGH' or 'NOT\_NUMBER'

Example:

```text
{age: { 'max_number': 95 } }
```

#### min\_number
Error code: 'TOO\_LOW' or 'NOT\_NUMBER'

Example:

```text
{age: { 'min_number': 18 } }
```

#### number\_between
Error code: 'TOO\_HIGH' or 'TOO\_LOW' or 'NOT\_NUMBER'

Example:

```text
{age: { 'number_between': [18, 95] } }
```
