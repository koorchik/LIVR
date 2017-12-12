### Special Rules

#### email {#email}

Error code: 'WRONG\_EMAIL'

Example:

```javascript
{ login: 'email' }
```

#### url {#url}

Allows you to validate url. Allows 'HTTP' and 'HTTPS' protocols. Protocol is required.

Error code: 'WRONG\_URL'

Example:

```javascript
{ url: 'url' }
```

#### iso\_date {#iso-date}

Check whether a value is an ISO 8601 date \(without time\). Allowed date example - "2014-08-14"

Error code: 'WRONG\_DATE'

Example:

```javascript
{ date: 'iso_date' }
```

#### equal\_to\_field {#equal-to-field}

Error code: 'FIELDS\_NOT\_EQUAL'

Example:

```javascript
{ password2: { 'equal_to_field': 'password' } }
```
