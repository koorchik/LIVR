---
title: semver
group: format
since: '2.5'
syntax: "'semver'"
example:
  rules: |-
    {
        version: 'semver'
    }
  input: |-
    {
        version: 'v1.2.3'
    }
---

# semver

Checks that the value is a semantic version, for example `1.2.3` or `2.0.0-rc.1+build.5`.

Error codes: `WRONG_SEMVER`, `FORMAT_ERROR`

<RuleSandbox />

The grammar of [Semantic Versioning 2.0.0](https://semver.org/). It accepts the same strings as the [suggested regular expression](https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string) of semver.org, with ASCII classes and a [whole-string match](/validation-rules/how-it-works.html#grammars):

```text
version        = core [ "-" pre-release ] [ "+" build ]
core           = number "." number "." number
number         = "0" / ( %x31-39 *DIGIT )                 ; no leading zeros
pre-release    = pre-id *( "." pre-id )
pre-id         = number / alnum-id
build          = build-id *( "." build-id )
build-id       = 1*( DIGIT / ALPHA / "-" )
alnum-id       = *DIGIT ( ALPHA / "-" ) *( DIGIT / ALPHA / "-" )
```

There is no `v` prefix: `v1.2.3` does not pass. Leading zeros are rejected in the version numbers and in numeric pre-release identifiers (`1.2.3-01`), but allowed in build metadata (`1.2.3+001`).
