---
title: keys
group: metarules
since: '2.5'
syntax: "{ keys: { one_of: ['uk', 'en'] } }"
example:
  rules: |-
    {
        translations: [{ keys: { one_of: ['uk', 'en', 'de'] } },
                       { values: ['required', 'string', { max_length: 200 }] }]
    }
  input: |-
    {
        translations: { en: 'Hello', fr: 'Bonjour' }
    }
---

# keys

Validates every key of an object as a string with the given rules. The rules only check: the keys do not change.

Error codes: `WRONG_KEY` under every failing key, or `FORMAT_ERROR` if the value is not an object.

<RuleSandbox />

```js
{
    translations: [{ keys: { one_of: ['uk', 'en', 'de'] } },
                   { values: ['required', 'string', { max_length: 200 }] }]
}
```

The arguments are the same as in [`list_of`](/validation-rules/list_of.html): `{ keys: ['required', 'string'] }` and `{ keys: [['required', 'string']] }` are the same. An empty list `[]` is a [schema error](/validation-rules/how-it-works.html#arguments).

- A key that fails gives `WRONG_KEY` under that key: `{ translations: { fr: 'WRONG_KEY' } }`.
- The output of the rules is ignored, and the keys do not change. The output is the value unchanged.
- The auto-trim option of the validator trims values, not keys, so keys are checked as they are.
- A list or a primitive value gives `FORMAT_ERROR`.
- An empty object passes.
