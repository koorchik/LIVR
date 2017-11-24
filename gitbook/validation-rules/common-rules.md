### Common Rules {#common}

#### required {#required}

Error code: 'REQUIRED'

Example:

```text
{ first_name: 'required' }
```

#### not\_empty {#not-empty}

Error code: 'CANNOT\_BE\_EMPTY'

Example:

```text
{ first_name: 'not_empty' }
```

#### not\_empty\_list {#not-empty-list}

Checks that list contains at least one element

Error code: 'CANNOT\_BE\_EMPTY' \(If the value is not present or list is empty\). If the value is present but it is not a list the error code will be 'FORMAT\_ERROR'

Example:

```text
{ products_ids: 'not_empty_list' }
```

#### any\_object {#any-object}

Checks that the value is an plain object

Error code: 'FORMAT\_ERROR' if the value is not a plain object.

Example:

```text
{ address: 'any_object' }
```



