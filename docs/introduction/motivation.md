# Motivation

These are the main problems we kept running into with data validation libraries, and the reason LIVR exists.

### Problem #1. Many validators check only the fields that have rules

> Any user input that is not explicitly allowed must be ignored. The validator has to cut out all data that has no validation rules. For us this is a fundamental requirement.

### Problem #2. Validation rules are described procedurally

> We do not want to think about the validation algorithm every time. We want to describe declaratively what correct data looks like, like a data schema. See also [why not JSON Schema](/introduction/core-concepts.html#why-not-json-schema).

### Problem #3. Validation rules are written as code

> This may not look terrible at first, but it rules out serializing the rules and using the same rules on the backend and the frontend.

### Problem #4. Validation stops at the first field with an error

> Then you cannot highlight all invalid or missing fields of a form at once.

### Problem #5. Error messages are not standardized

> For example, "Field name is required". We cannot show such an error to the user, because:
>
> - the field may have a completely different name in the interface;
> - the interface may not be in English;
> - we need to know the type of error, for example to show empty values in a special way.
>
> So the validator has to return standardized error codes, not messages.

### Problem #6. Numeric error codes

> They are inconvenient to use. Error codes should be self-explanatory: `REQUIRED` is much clearer than `27`. The logic is similar to exception classes.

### Problem #7. No way to validate hierarchical data

> With JSON APIs everywhere, this cannot be avoided. Besides validating hierarchical data, the validator has to return error codes for every nested field.

### Problem #8. A limited set of rules

> The standard rules are never enough. The validator must be extensible and allow adding rules of any complexity.

### Problem #9. Too much responsibility

> The validator should not generate forms, should not generate code, should not do anything other than validation.

### Problem #10. No way to pre-process the data

> Almost always, where there is validation, there is a need for some additional (often preliminary) processing: cut out forbidden characters, convert to lowercase, remove extra spaces. Removing leading and trailing spaces is especially important: in 99% of cases they are not needed.
>
> This seems to contradict the previous point, but these transformations are so tightly coupled with validation that LIVR supports them as [modifiers](/validation-rules/modifiers.html) and nothing more.
