---
title: unique
group: list
since: '2.5'
syntax: "'unique'"
example:
  rules: |-
    {
        tags: 'unique',
        users: { unique: 'id' }
    }
  input: |-
    {
        tags: ['a', 'b', 'a'],
        users: [{ id: 1 }, { id: 2 }]
    }
---

# unique

Checks that a list has no duplicate items. With key names, checks that no two objects in the list have the same values of these keys.

Error codes: `NOT_UNIQUE_ITEMS`, `FORMAT_ERROR`

<RuleSandbox />

The arguments are none, or one or more key names:

```js
{ tags:      'unique' }
{ users:     { unique: 'id' } }
{ addresses: { unique: ['country', 'zip'] } }
```

- Without keys, the items must be primitive values. They are [compared as strings](/validation-rules/how-it-works.html#comparison), so `1` and `"1"` are duplicates. Empty items are ignored.
- With keys, the items must be objects. Two items are duplicates when all their key values are equal. An item with an empty key value is ignored. A key value that is an object or a list gives `FORMAT_ERROR`, also when another key of the same item is empty.
- Duplicates give `NOT_UNIQUE_ITEMS` for the whole field.
- A value that is not a list, or an item of the wrong type, gives `FORMAT_ERROR`.

The output is the value unchanged.
