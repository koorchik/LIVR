# Create own plugins

Every implementation lets you register your own rules. A rule is a function that receives the rule arguments and returns a validator; the validator receives a value and returns an error code, or nothing if the value is valid. See [How it works](/validation-rules/how-it-works.html).

If a rule can be built from existing rules, you do not need code at all: use [rules aliasing](/rules-aliasing.html). Aliases are plain data and work in every implementation.

Rules that are useful across projects can be published as a package. See [Extensions](/introduction/extensions.html) for examples, such as [livr-extra-rules](https://github.com/koorchik/js-livr-extra-rules) for JavaScript.
