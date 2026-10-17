# Extensions

Libraries and tools built on top of LIVR implementations. Built something with LIVR? [Add it to this page](https://github.com/koorchik/LIVR/edit/master/docs/introduction/extensions.md).

## JavaScript

### [livr-extra-rules](https://github.com/koorchik/js-livr-extra-rules)

[npm](https://www.npmjs.com/package/livr-extra-rules) · maintainer [@koorchik](https://github.com/koorchik)

Extra rules for LIVR: `ipv4`, `boolean`, `uuid`, `credit_card`, `list_length`, `list_items_unique`, `required_if` and more. It is absolutely fine to have your own custom rules in a project, but some rules are useful across projects.

The rules are available in the [playground](/playground.html), except `instance_of` and `has_methods`, which need JavaScript classes and functions.

### [react-livr-validation](https://github.com/one-more/react-livr-validation)

[npm](https://www.npmjs.com/package/react-livr-validation) · maintainer [@one-more](https://github.com/one-more)

Validation component for React with LIVR as the validation engine.

### [vue-livr](https://github.com/olxbr/vue-livr)

[npm](https://www.npmjs.com/package/vue-livr) · maintainer [@olxbr](https://github.com/olxbr)

Validation plugin for Vue.js with LIVR as the validation engine.

### [confme](https://github.com/koorchik/node-confme)

[npm](https://www.npmjs.com/package/confme) · maintainer [@koorchik](https://github.com/koorchik)

An opinionated config library that supports complex configs and follows the "Twelve-Factor App" rules. Configs are validated with LIVR.

## Perl

### [LIVR::Contract](https://github.com/koorchik/LIVR-Contract)

[CPAN](https://metacpan.org/pod/LIVR::Contract) · maintainer [@koorchik](https://github.com/koorchik)

Design by contract in Perl with LIVR. Uses Validator::LIVR underneath.

### [MVC::Neaf::X::Form::LIVR](https://metacpan.org/pod/MVC::Neaf::X::Form::LIVR)

[CPAN](https://metacpan.org/pod/MVC::Neaf::X::Form::LIVR) · maintainer [@KHEDIN](https://metacpan.org/author/KHEDIN)

Input validation for the Neaf web framework using Validator::LIVR. Returns an object with `is_valid()`, `data()`, `error()` and `raw()` methods.

## PHP

### [php-livr-extra](https://github.com/umotif-public/php-validator-livr-extra)

`composer require umotif/php-livr-extra` · maintainer [@umotif-public](https://github.com/umotif-public)

Additional rules for the PHP implementation, such as `list_length`, based on livr-extra-rules.

## Go

### [Ægir](https://github.com/olxbr/aegir) <Badge type="info" text="archived" />

maintainer [@olxbr](https://github.com/olxbr)

A validating admission webhook for Kubernetes: it rejects cluster resources that violate rules written in LIVR.
