# Create own implementation

Requirements for an implementation:

1. It supports all [validation rules](/validation-rules.html) described in the specification.
2. It supports [rules aliasing](/rules-aliasing.html).
3. It returns the [error codes](/validation-rules/error-codes.html) described in the specification.
4. It is easy to add your own rules.
5. It passes the [test suite](/how-to-contribute/test-suite.html).

## Tips

- Look at the [JavaScript implementation](https://github.com/koorchik/js-validator-livr): it is the reference implementation, and its rules are small, self-contained functions.
- Copy the `test_suite` directory into your repository, or add this repository as a git submodule, and run it in your CI.
- Follow the conventions of your language for the API (`registerAliasedRule` in JavaScript, `register_aliased_rule` in Perl, and so on), but keep the rules format and the error codes exactly as in the specification.

## Publish it

When your implementation passes the test suite, add it to the [implementations list](/introduction/implementations.html#add-your-implementation). If you add a runner to the [`conformance/`](https://github.com/koorchik/LIVR/tree/master/conformance) directory, the site will show your test suite results too.
