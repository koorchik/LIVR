## Motivation

#### The main problems that occur in data validation libraries

**Problem #1.** Many validators check only those data for which the validation rules are described. 

> It is important for us that any user input that is not explicitly allowed is ignored. That is, the validator must cut out all data for which the validation rules are not described. This is simply a fundamental requirement.

**Problem #2.** Procedural description of validation rules.

> We do not want to think about the validation algorithm every time, we just want to describe declaratively how the correct data should look. In fact, we want to specify a data schema ([why not "JSON Schema"](core-concepts.md#why-not-json-schema)).

**Problem #3.** Description of validation rules in the form of code. 

> It would seem that this is not so terrible, but this immediately nullifies all attempts to serialize the validation rules and use the same validation rules on the backend and frontend.

**Problem #4.** Validation stops at the first field with an error.

> This approach does not allow you to highlight all the error / required fields in the form.

**Problem #5.** Non-standardized error messages.

> For example, "Field name is required". I can not show such a mistake to the user for a number of reasons:
>
> * The field in the interface can be called quite differently
> * interface may not be in English
> * you need to distinguish between the type of error. For example, show errors on an empty value in a special way
>
> That is, you need to return not an error message, but standardized error codes.

**Problem #6.** Numerical error codes.

> It's just inconvenient to use. I want the error codes to be intuitive. Agree that the error code "REQUIRED" is more understandable than the code "27". The logic is similar to working with exception classes.

**Problem #7.** There is no way to check hierarchical data structures.

> Today, in the days of different JSON APIs, this can not be avoided. In addition to the validation of hierarchical data, it is necessary to provide and return error codes for each field.

**Problem #8.** Limited rule set.

> There are always not enough standard rules. The validator must be extensible and allow adding rules of any complexity to it.

**Problem #9.** Too much responsibility.

> The validator should not generate forms, should not generate code, should not do anything other than validation.

**Problem #10.** Inability to perform additional data processing.

> Almost always, where there is validation, there is a need for some additional (often preliminary) data processing: cut out prohibited characters, bring them to lowercase, remove unnecessary spaces. Especially important is the removal of spaces at the beginning and end of the line. In 99% of cases they are not needed there. I know that before that I said that the validator should not do anything except validation.