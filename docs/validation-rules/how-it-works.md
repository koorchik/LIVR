# How it works

Rules are a structure that maps field names to validation rules:

```text
{ FIELD_NAME: VALIDATION_RULE, ... }
```

- `FIELD_NAME` is the name of the field to validate.
- `VALIDATION_RULE` is the name of a rule, a rule with arguments `{ RULE_NAME: ARGUMENTS }`, or a list of such rules. Rules in a list are applied one after another.

To pass several arguments, use a list. A single argument that is not a list can be passed as is.

## From rules to function calls

Each rule is the name of a function that builds a validator. Arguments from the rules are passed to that function:

| Rule | Becomes |
|---|---|
| `'required'` or `{ required: [] }` | `required()` |
| `{ max_length: 5 }` or `{ max_length: [5] }` | `max_length(5)` |
| `{ length_between: [1, 10] }` | `length_between(1, 10)` |
| `{ one_of: ['Kyiv', 'Lviv'] }` (supported since v0.4) | `one_of('Kyiv', 'Lviv')` |
| `{ one_of: [['Kyiv', 'Lviv']] }` (old syntax) | `one_of(['Kyiv', 'Lviv'])` |
| `{ my_own_rule: [1, [2, 3], 'bla'] }` | `my_own_rule(1, [2, 3], 'bla')` |

The built validator receives a value and returns an error code, for example `'REQUIRED'`, if validation fails, or nothing if it succeeds. Validators may also change the value they return, and that is how modifiers and type coercion work.

That's all: a tiny core that is easy to extend with new rules.

## What the validator returns

- If all fields are valid, the validator returns the output data: only the fields that have rules, with values changed by the rules (see [Types coercing](/validation-rules/types-coercing.html)).
- If some fields are invalid, it returns an error for every invalid field. Errors have the same shape as the data, so nested objects and lists get nested errors.

```livr
// rules
{
    name: 'required',
    address: { nested_object: {
        city: 'required',
        zip: 'positive_integer'
    }},
    tags: { list_of: { max_length: 5 } }
}
// input
{
    address: { city: 'Kyiv', zip: '-1' },
    tags: ['short', 'too long']
}
```

In lists, the errors of valid items are `null`, so the position of every error is preserved.
