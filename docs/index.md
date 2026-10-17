---
layout: home
title: Language Independent Validation Rules
titleTemplate: LIVR · :title

hero:
  name: LIVR
  text: Language Independent Validation Rules
  tagline: Describe valid data once, as a declarative schema. Get the same validation, the same output and the same error codes in JavaScript, Perl, PHP, Python, Go, Erlang and more.
  actions:
    - theme: brand
      text: Get started
      link: /introduction.html
    - theme: alt
      text: Validation rules
      link: /validation-rules.html
    - theme: alt
      text: Playground
      link: /playground.html

features:
  - icon: 📝
    title: Declarative and portable
    details: Rules are plain data. Store them as JSON and share one schema between the backend, the frontend and services written in other languages.
  - icon: 🛡️
    title: Strict by default
    details: Fields without rules are removed from the output, so data that is not explicitly allowed never reaches your code.
  - icon: 🏷️
    title: Error codes, not messages
    details: "Errors are readable codes shaped like your data, for example { email: 'WRONG_EMAIL' }. They are easy to translate and to map to your UI."
  - icon: 🌳
    title: Hierarchical data
    details: Validate nested objects, lists and lists of different objects. Get errors for every field in a single pass.
  - icon: ✂️
    title: Built-in modifiers
    details: Trim, lowercase, set defaults and clean values in the same pipeline that validates them.
  - icon: 🧩
    title: Extensible
    details: Add your own rules, or combine existing ones into reusable aliases with custom error codes. Aliases work in every implementation.
---

<div class="home-section">

## Try it right here

Edit the rules or the input. The result is computed live in your browser by the JavaScript implementation, and every other implementation returns exactly the same.

```livr
// rules
{
    name: 'required',
    email: ['required', 'email', 'to_lc'],
    gender: { one_of: ['male', 'female'] },
    password: ['required', { min_length: 10 }],
    password2: { equal_to_field: 'password' }
}
// input
{
    name: 'John',
    email: 'John@Example.com',
    gender: 'male',
    password: 'mypassword1',
    password2: 'mypassword1',
    is_admin: true
}
```

<p class="home-more"><a href="/introduction/examples.html">More examples →</a></p>

</div>

<div class="home-section">

## Implementations

One specification and one shared test suite, many languages.

<ImplementationCards compact />

<p class="home-more"><a href="/introduction/implementations.html">All implementations and test suite results →</a></p>

</div>

<div class="home-section">

## Used by

<UsersGrid />

<p class="home-more"><a href="/users.html">Using LIVR? Add your logo →</a></p>

</div>
