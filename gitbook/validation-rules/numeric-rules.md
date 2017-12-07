### Numeric Rules

#### integer {#integer}

Error code: 'NOT\_INTEGER'

Example:

```javascript
{ age: 'integer' }
```

#### positive\_integer {#positive-integer}

Error code: 'NOT\_POSITIVE\_INTEGER'

Example:

```javascript
{ age: 'positive_integer' }
```

#### decimal {#decimal}

Error code: 'NOT\_DECIMAL'

Example:

```javascript
{ price: 'decimal' }
```

#### positive\_decimal {#positive-decimal}

Error code: 'NOT\_POSITIVE\_DECIMAL'

Example:

```javascript
{ price: 'positive_decimal' }
```

#### max\_number {#max-number}

Error code: 'TOO\_HIGH' or 'NOT\_NUMBER'

Example:

```javascript
{ age: { 'max_number': 95 } }
```

#### min\_number {#min-number}

Error code: 'TOO\_LOW' or 'NOT\_NUMBER'

Example:

```javascript
{ age: { 'min_number': 18 } }
```

#### number\_between {#number-between}

Error code: 'TOO\_HIGH' or 'TOO\_LOW' or 'NOT\_NUMBER'

Example:

```javascript
{ age: { 'number_between': [18, 95] } }
```
