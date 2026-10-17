# Introduction

**LIVR** (Language Independent Validation Rules) is a specification for describing data validation rules as plain data. You write the rules once, as a structure that looks like the data it validates, and any LIVR implementation, in any language, validates the data the same way:

- it returns only the fields that have rules, so everything else is dropped;
- it reports errors for all fields at once, as readable codes shaped like your data;
- it can also clean the data on the way: trim strings, lowercase emails, set defaults.

```livr
// rules
{
    name: 'required',
    email: ['required', 'email'],
    age: ['positive_integer', { min_number: 18 }]
}
// input
{
    name: '',
    email: 'not an email',
    age: '16',
    is_admin: true
}
```

Because the rules are data, you can store them in JSON, send them from the server to the browser, and use the same schema in services written in different languages. The specification includes a [test suite](/how-to-contribute/test-suite.html) that every implementation runs, so they all behave the same way.

## Where to go next

- [Motivation](/introduction/motivation.html): the problems with typical validators that LIVR solves.
- [Core concepts](/introduction/core-concepts.html): the specification, and how LIVR compares to JSON Schema.
- [Principles](/introduction/principles.html): the requirements every LIVR validator meets.
- [Examples](/introduction/examples.html): editable examples for common cases.
- [Validation rules](/validation-rules.html): the reference for every standard rule.
- [Implementations](/introduction/implementations.html): pick a library for your language.

## Articles and talks

- [LIVR: Data Validation Without Any Issues](https://webbylab.com/blog/language-independent-validation-rules-library-validation/), by the creator of LIVR
- [Language Independent Validation Rules (LIVR) for Perl 6](https://perl6advent.wordpress.com/2017/12/19/day-19-language-independent-validation-rules-livr-for-perl6/), Perl 6 Advent Calendar
- [Talk on LIVR 2.0 at the OSDN-UA 2017 conference](https://www.youtube.com/watch?v=QlwcG3N_rmw) (Russian)
- [LIVR: language independent validation rules](https://habr.com/ru/articles/246521/), article on Habr (Russian)
- [Article on LIVR and its Perl implementation in the PragmaticPerl magazine](http://pragmaticperl.com/issues/05/pragmaticperl-05-livr-language-independent-validation-rules-%D0%BD%D0%B5%D0%B7%D0%B0%D0%B2%D0%B8%D1%81%D0%B8%D0%BC%D1%8B%D0%B5-%D0%BE%D1%82-%D1%8F%D0%B7%D1%8B%D0%BA%D0%B0-%D0%BF%D1%80%D0%B0%D0%B2%D0%B8%D0%BB%D0%B0-%D0%B2%D0%B0%D0%BB%D0%B8%D0%B4%D0%B0%D1%86%D0%B8%D0%B8.html) (Russian)
