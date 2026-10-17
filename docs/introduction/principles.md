# Principles

Every LIVR validator meets the following requirements:

1. Rules are declarative and language independent.
2. Any number of rules for each field.
3. The validator returns errors for all fields together.
4. Fields that do not have validation rules are excluded from the output.
5. Complex hierarchical structures can be validated.
6. Validation is easy to describe and to understand.
7. Errors are understandable codes (neither error messages nor numeric codes).
8. It is easy to implement your own rules (usually you will have several in every project).
9. Rules can change the output, for example `trim` and `nested_object`.
10. Multipurpose: user input validation, configs validation, contracts programming, etc.
11. Unicode support.
