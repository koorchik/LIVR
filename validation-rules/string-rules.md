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

### 



