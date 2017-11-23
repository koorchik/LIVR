### Special Rules

#### email

Error code: 'WRONG\_EMAIL'

Example:

```text
{login: 'email'}
```

#### url

Allows you to validate url. Allows 'HTTP' and 'HTTPS' protocols. Protocol is required.

Error code: 'WRONG\_URL'

Example:

```text
{url: 'url'}
```

#### iso\_date

Check whether a value is an ISO 8601 date \(without time\). Allowed date example - "2014-08-14"

Error code: 'WRONG\_DATE'

Example:

```text
{date: 'iso_date'}
```

#### equal\_to\_field

Error code: 'FIELDS\_NOT\_EQUAL'

Example:

```text
{password2: {'equal_to_field': 'password' }}
```



