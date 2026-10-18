---
aside: false
---

# Validation rules

The standard rules that every implementation supports. Open a rule to see how it works and to try it live, or filter the list by an error code to find the rule that returns it.

<RulesOverview />

## Empty values are skipped

All standard rules skip empty values: a missing field, `null` and an empty string `""`. Only [`required`](/validation-rules/required.html), [`not_empty`](/validation-rules/not_empty.html) and [`not_empty_list`](/validation-rules/not_empty_list.html) check that a value is present. So the same rules work for optional fields:

```js
first_name: { min_length: 10 }               // optional: the length is checked only if "first_name" is passed
first_name: ['required', { min_length: 10 }] // the name must be present and at least 10 characters long
```

Rules that expect a primitive value (a string, a number or a boolean) return `FORMAT_ERROR` when they receive an object or a list. See [Error codes](/validation-rules/error-codes.html).

## Learn more

- [How it works](/validation-rules/how-it-works.html): the syntax of rules and how they are combined.
- [Types coercing](/validation-rules/types-coercing.html): what the rules return.
- [Rules aliasing](/rules-aliasing.html) and [Create own plugins](/how-to-contribute/create-own-plugins.html): projects usually add a few rules of their own.
