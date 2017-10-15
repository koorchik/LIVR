### How it works
You should define a structure:
    FIELD\_NAME: VALIDATION\_RULE
* FIELD\_NAME is a name of field to validate
* VALIDATION\_RULE is a name of function to be called. It can be function that builds validator or maybe just a validation function itself. Some arguments cab be passed to the function - "{ VALIDATION\_RULE: ARGUMENTS }". You may pass an array of validation rules. If you want to pass several arguments you should use array.

Examples:

'required' or {'required': [] } becomes:

    required();

{ 'max\_length': 5 } or { 'max\_length': [5] } becomes:

    max_length(5);

{'length\_between': [1,10] } becomes:

    length_between(1,10);

{'one\_of': [['Kiev','Moscow']] } (this is old syntax) becomes:

    one_of(['Kiev', 'Moscow']);

{'one\_of': ['Kiev','Moscow'] } (supported from v0.4)  becomes:

    one_of('Kiev', 'Moscow');

{'my\_own\_rule': [1, [2, 3], 'bla'] } becomes:

    my_own_rule(1, [2, 3], 'bla');

Validator receives value to validate and returns an error message(in case of failed validation) or empty string(in case of success). Thats all.

So, the idea is that there is a tiny core which can be easly extended with new rules.
