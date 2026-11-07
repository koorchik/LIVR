---
aside: false
---

# Format rules <Badge type="warning" text="LIVR 2.5 draft" />

Format rules check that a value is an identifier, a network address, an encoding or another common format. They check the [string form](/validation-rules/how-it-works.html#string-form) of a primitive value, and return it. A boolean gives the error code of the rule (`true` is not a hostname, although `'true'` is), and an object or a list gives `FORMAT_ERROR`. A number is checked as its string form: `123` passes `hex` and gives `'123'`.

Hex digits are `0-9a-fA-F`. All hex comparisons are case-insensitive, and the case of the input is kept in the output. A rule without arguments that is given arguments, or an unknown argument value, is a [schema error](/validation-rules/how-it-works.html#arguments).

These rules are part of the [draft LIVR 2.5](/changes.html#v2-5-draft).

<RulesOverview group="format" />
