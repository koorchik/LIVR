![LIVR logo](assets/logo.png)

# Language Independent Validation Rules \(v2.0\)

## Existing implemenations

[<img src="assets/languages/js.jpg" width="100" height="100">](https://github.com/koorchik/js-validator-livr) [JavaScript \(LIVR 2.0\)](https://github.com/koorchik/js-validator-livr) available at [npm](https://www.npmjs.com/package/livr), maintainer @koorchik

[<img src="assets/languages/perl.jpg" width="100" height="100">](https://github.com/koorchik/Validator-LIVR) [Perl \(LIVR 2.0\)](https://github.com/koorchik/Validator-LIVR) available at [CPAN](https://metacpan.org/pod/Validator::LIVR), maintainer @koorchik

[<img src="assets/languages/php.png" width="100" height="100">](https://github.com/WebbyLab/php-validator-livr) [PHP \(LIVR 2.0\)](https://github.com/WebbyLab/php-validator-livr) available at [packagist](https://packagist.org/packages/validator/livr), maintainer @WebbyLab

[<img src="assets/languages/python.png" width="100" height="100">](https://github.com/asholok/python-validator-livr) [Python \(LIVR 2.0\)](https://github.com/asholok/python-validator-livr) available at [pypi](https://pypi.python.org/pypi/LIVR), maintainer @asholok

[<img src="assets/languages/erlang.png" width="100" height="100">](https://github.com/Prots/olifer) [Erlang \(LIVR 2.0\)](https://github.com/Prots/olifer), maintainer @Prots

[<img src="assets/languages/java.png" width="100" height="100">](https://github.com/vlbaluk/java-validator-livr) [Java \(LIVR 2.0\)](https://github.com/vlbaluk/java-validator-livr), maintainer @vlbaluk

[<img src="assets/languages/ruby.png" width="100" height="100">](https://github.com/maktwin/ruby-validator-livr) [Ruby \(LIVR 0.4, previous version\)](https://github.com/maktwin/ruby-validator-livr) at [rubygems](https://rubygems.org/gems/livr), maintainer @maktwin

_Latest LIVR version is 2.0_  
_Previous LIVR version is 0.4_


## Validator meets the following requirements:

1. Rules are declarative and language independent
2. Any number of rules for each field
3. Validator should return together errors for all fields
4. Exclude all fields that do not have validation rules described
5. Possibility to validate complex hierarchical structures
6. Easy to describe and understand validation
7. Returns understandable error codes \(neither error messages nor numeric codes\)
8. Easy to implement own rules \(usually you will have several in every project\)
9. Rules should be able to change results output \("trim", "nested\_object", for example\)
10. Multipurpose \(user input validation, configs validation, contracts programming etc\)
11. Unicode support

## Try online

* [Online JavaScript playground](http://webbylab.github.io/livr-playground/)
* [Online multi-language playground](http://livr-multi-playground.webbylab.com/)
