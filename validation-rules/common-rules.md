### Common Rules

#### required

Error code: 'REQUIRED'

Example:

```text
{first_name: 'required'}
```

#### not\_empty

Error code: 'CANNOT\_BE\_EMPTY'

Example:

```text
{first_name: 'not_empty'}
```

#### not\_empty\_list

Checks that list contains at least one element

Error code: 'CANNOT\_BE\_EMPTY' \(If the value is not present or list is empty\). If the value is present but it is not a list the error code will be 'FORMAT\_ERROR'

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

Error code: 'NOT\_POSITIVE\_DECIMAL'

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



