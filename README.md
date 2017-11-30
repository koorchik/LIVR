<!-- Place this tag in your head or just before your close body tag. -->
<script async defer src="https://buttons.github.io/buttons.js"></script>


<a href="https://github.com/koorchik/LIVR">
    <img src="assets/logo.png">
</a>
<a class="github-button" href="https://github.com/koorchik/LIVR" data-icon="octicon-star" data-size="large" data-show-count="true" aria-label="Star koorchik/LIVR on GitHub">Star</a>


# Language Independent Validation Rules \(v2.0\)

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

## Existing implemenations

<div class="langContainer">
    <div class="langItem">
        <a href="https://github.com/koorchik/js-validator-livr">
            <img src="assets/languages/js.jpg" class="icon">
        </a>
        <div class="textBlock">
            <a href="https://travis-ci.org/koorchik/js-validator-livr">
                <img src="https://travis-ci.org/koorchik/js-validator-livr.svg?branch=master"><br>
            </a>
            <a href="https://github.com/koorchik/js-validator-livr">
                JavaScript (LIVR 2.0)
            </a><br>
            available at
            <a href="https://www.npmjs.com/package/livr">
                npm,
            </a><br>
            maintainer @koorchik
        </div>
    </div>
    <div class="langItem">
        <a href="https://github.com/koorchik/Validator-LIVR">
            <img src="assets/languages/perl.jpg" class="icon">
        </a>
        <div class="textBlock">
            <a href="https://travis-ci.org/koorchik/Validator-LIVR">
                <img src="https://travis-ci.org/koorchik/Validator-LIVR.svg?branch=master"><br>
            </a>
            <a href="https://github.com/koorchik/Validator-LIVR">
                Perl (LIVR 2.0)
            </a><br>
            available at
            <a href="https://metacpan.org/pod/Validator::LIVR">
                CPAN,
            </a><br>
            maintainer @koorchik
        </div>
    </div>
    <div class="langItem">
        <a href="https://github.com/WebbyLab/php-validator-livr">
            <img src="assets/languages/php.png" class="icon">
        </a>
        <div class="textBlock">
            <a href="https://travis-ci.org/WebbyLab/php-validator-livr">
                <img src="https://travis-ci.org/WebbyLab/php-validator-livr.svg?branch=master"><br>
            </a>
            <a href="https://github.com/WebbyLab/php-validator-livr">
                PHP (LIVR 2.0)
            </a><br>
            available at
            <a href="https://packagist.org/packages/validator/livr">
                packagist,
            </a><br>
            maintainer @WebbyLab
        </div>
    </div>
    <div class="langItem">
        <a href="https://github.com/asholok/python-validator-livr">
            <img src="assets/languages/python.png" class="icon">
        </a>
        <div class="textBlock">
            <a href="https://travis-ci.org/asholok/python-validator-livr">
                <img src="https://travis-ci.org/asholok/python-validator-livr.svg?branch=master"><br>
            </a>
            <a href="https://github.com/asholok/python-validator-livr">
                Python (LIVR 2.0)
            </a><br>
            available at
            <a href="https://pypi.python.org/pypi/LIVR">
                pypi,
            </a><br>
            maintainer @asholok
        </div>
    </div>
    <div class="langItem">
        <a href="https://github.com/Prots/olifer">
            <img src="assets/languages/erlang.png" class="icon">
        </a>
        <div class="textBlock">
            <a href="https://travis-ci.org/Prots/olifer">
                <img src="https://travis-ci.org/Prots/olifer.svg?branch=2.0.2"><br>
            </a>
            <a href="https://github.com/Prots/olifer">
                Erlang (LIVR 2.0),
            </a><br>
            maintainer @koorchik
        </div>
    </div>
    <div class="langItem">
        <a href="https://github.com/vlbaluk/java-validator-livr">
            <img src="assets/languages/java.png" class="icon">
        </a>
        <div class="textBlock">
            <a href="https://github.com/vlbaluk/java-validator-livr">
                Java (LIVR 2.0),
            </a><br>
            maintainer @vlbaluk
        </div>
    </div>
    <div class="langItem">
        <a href="https://github.com/maktwin/ruby-validator-livr">
            <img src="assets/languages/ruby.png" class="icon">
        </a>
        <div class="textBlock">
            <a href="https://travis-ci.org/maktwin/ruby-validator-livr">
                <img src="https://travis-ci.org/maktwin/ruby-validator-livr.svg?branch=master"><br>
            </a>
            <a href="https://github.com/maktwin/ruby-validator-livr">
                Ruby (LIVR 0.4, previous version),
            </a><br>
            maintainer @maktwin
        </div>
    </div>
    <div>
        <i>Latest LIVR version is 2.0</i><br>
        <i>Previous LIVR version is 0.4</i>
    </div>
</div>


## Documentation {#documentation}

* [Introduction](gitbook/introduction.md)
* [Validation Rules](gitbook/validation-rules.md)
* [Rules aliasing](gitbook/rules-aliasing.md)
* [How to contribute](gitbook/how-to-contribute.md)
* [Changes](gitbook/changes.md)
* [License](gitbook/license-and-copyright.md)

## Examples

* [Simple registration data](http://webbylab.github.io/livr-playground/#%7B%22rules%22%3A%22%7B%5Cn%20%20%20%20name%3A%20'required'%2C%5Cn%20%20%20%20email%3A%20%5B'required'%2C%20'email'%5D%2C%5Cn%20%20%20%20gender%3A%20%7B%20one_of%3A%20%5B%5B'male'%2C%20'female'%5D%5D%20%7D%2C%5Cn%20%20%20%20phone%3A%20%7Bmax_length%3A%2010%7D%2C%5Cn%20%20%20%20password%3A%20%5B'required'%2C%20%7Bmin_length%3A%2010%7D%20%5D%2C%5Cn%20%20%20%20password2%3A%20%7B%20equal_to_field%3A%20'password'%20%7D%5Cn%7D%22%2C%22data%22%3A%22%7B%5Cn%20%20%20%20name%3A%20'John'%2C%5Cn%20%20%20%20email%3A%20'john%40mail.com'%2C%5Cn%20%20%20%20gender%3A%20'male'%2C%5Cn%20%20%20%20phone%3A%20'%2B22221212'%2C%5Cn%20%20%20%20password%3A%20'mypassword1'%2C%5Cn%20%20%20%20password2%3A%20'mypassword1'%5Cn%7D%22%7D)
* [Simple validation of nested object](http://webbylab.github.io/livr-playground/#%7B%22rules%22%3A%22%7B%5Cn%20%20%20%20name%3A%20'required'%2C%5Cn%20%20%20%20phone%3A%20%7Bmax_length%3A%2010%7D%2C%5Cn%20%20%20%20address%3A%20%7B%20'nested_object'%3A%20%7B%5Cn%20%20%20%20%20%20%20%20city%3A%20'required'%2C%20%5Cn%20%20%20%20%20%20%20%20zip%3A%20%5B'required'%2C%20'positive_integer'%5D%5Cn%20%20%20%20%7D%7D%5Cn%7D%22%2C%22data%22%3A%22%7B%5Cn%20%20%20%20name%3A%20%5C%22Michael%5C%22%2C%5Cn%20%20%20%20phone%3A%20%5C%220441234567%5C%22%2C%5Cn%20%20%20%20address%3A%20%7B%5Cn%20%20%20%20%20%20%20%20city%3A%20%5C%22Kiev%5C%22%2C%20%5Cn%20%20%20%20%20%20%20%20zip%3A%20%5C%2230552%5C%22%5Cn%20%20%20%20%7D%5Cn%7D%22%7D)
* [Simple list validation](http://webbylab.github.io/livr-playground/#%7B%22rules%22%3A%22%7B%5Cn%20%20%20%20order_id%3A%20%5B'required'%2C%20'positive_integer'%5D%2C%5Cn%20%20%20%20product_ids%3A%20%7B%20%5Cn%20%20%20%20%20%20%20'list_of'%3A%20%5B%20'required'%2C%20%20'positive_integer'%20%5D%5Cn%20%20%20%20%7D%5Cn%7D%22%2C%22data%22%3A%22%7B%5Cn%20%20%20%20order_id%3A%2010455%2C%5Cn%20%20%20%20product_ids%3A%20%5B3455%2C3456%2C3566%5D%5Cn%7D%22%7D)
* [Validating list of objects](http://webbylab.github.io/livr-playground/#%7B%22rules%22%3A%22%7B%5Cn%20%20%20%20order_id%3A%20%5B'required'%2C%20'positive_integer'%5D%2C%5Cn%20%20%20%20products%3A%20%5B%20'not_empty_list'%2C%20%7B%20'list_of_objects'%3A%20%7B%5Cn%20%20%20%20%20%20%20%20product_id%3A%20%5B'required'%2C'positive_integer'%5D%2C%5Cn%20%20%20%20%20%20%20%20quantity%3A%20%5B'required'%2C%20'positive_integer'%5D%5Cn%20%20%20%20%7D%7D%5D%5Cn%7D%22%2C%22data%22%3A%22%7B%5Cn%20%20%20%20order_id%3A%2010345%2C%5Cn%20%20%20%20products%3A%20%5B%7B%5Cn%20%20%20%20%20%20%20%20product_id%3A%203455%2C%5Cn%20%20%20%20%20%20%20%20quantity%3A2%5Cn%20%20%20%20%7D%2C%7B%5Cn%20%20%20%20%20%20%20%20product_id%3A%203456%2C%5Cn%20%20%20%20%20%20%20%20quantity%3A3%5Cn%20%20%20%20%7D%5D%5Cn%7D%22%7D)
* [Validating list of different objects](http://webbylab.github.io/livr-playground/#%7B%22rules%22%3A%22%7B%5Cn%20%20%20%20order_id%3A%20%5B'required'%2C%20'positive_integer'%5D%2C%5Cn%20%20%20%20products%3A%20%5B'required'%2C%20%7B%20'list_of_different_objects'%3A%20%5B%5Cn%20%20%20%20%20%20%20%20product_type%2C%20%7B%5Cn%20%20%20%20%20%20%20%20%20%20%20%20material%3A%20%7B%5Cn%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20product_type%3A%20'required'%2C%5Cn%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20material_id%3A%20%5B'required'%2C%20'positive_integer'%5D%2C%5Cn%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20quantity%3A%20%5B'required'%2C%20%7B'min_number'%3A%201%7D%20%5D%2C%5Cn%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20warehouse_id%3A%20'positive_integer'%5Cn%20%20%20%20%20%20%20%20%20%20%20%20%7D%2C%5Cn%20%20%20%20%20%20%20%20%20%20%20%20service%3A%20%7B%5Cn%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20product_type%3A%20'required'%2C%5Cn%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20name%3A%20%5B'required'%2C%20%7B'max_length'%3A%2020%7D%20%5D%5Cn%20%20%20%20%20%20%20%20%20%20%20%20%7D%5Cn%20%20%20%20%20%20%20%20%7D%5Cn%20%20%20%20%5D%7D%5D%5Cn%7D%22%2C%22data%22%3A%22%7B%5Cn%20%20%20%20order_id%3A%2010455%2C%5Cn%20%20%20%20products%3A%20%5B%7B%20%5Cn%20%20%20%20%20%20%20%20product_type%3A%20'material'%2C%5Cn%20%20%20%20%20%20%20%20material_id%3A%20345%2C%5Cn%20%20%20%20%20%20%20%20quantity%3A%20%205%2C%5Cn%20%20%20%20%20%20%20%20warehouse_id%3A%2024%5Cn%20%20%20%20%7D%2C%7B%5Cn%20%20%20%20%20%20%20%20product_type%3A%20'service'%2C%5Cn%20%20%20%20%20%20%20%20name%3A%20'Clean%20filter'%5Cn%20%20%20%20%7D%5D%5Cn%7D%22%7D)