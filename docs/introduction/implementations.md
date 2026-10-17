# Implementations

LIVR is a specification, so you need an implementation for your language. All of them use the same rules format and return the same error codes. The latest version of the specification is **2.0**; the previous one was 0.4.

<ImplementationCards />

Package versions and repository activity are refreshed every time the site is built.

## Test suite results

Every implementation is checked against the shared [test suite](/how-to-contribute/test-suite.html). Every week, and whenever the specification changes, CI installs each implementation the way a user would and runs all test cases against it.

<ConformanceTable />

## Add your implementation

Wrote a LIVR implementation? Great!

1. Check that it passes the [test suite](/how-to-contribute/test-suite.html), see [Create own implementation](/how-to-contribute/create-own-implementation.html).
2. Add it to [`docs/data/implementations.json`](https://github.com/koorchik/LIVR/blob/master/docs/data/implementations.json) and, if you can, add a test suite runner to [`conformance/`](https://github.com/koorchik/LIVR/tree/master/conformance).
3. Run `npm run readme` to update the list in the repository README and open a pull request.
