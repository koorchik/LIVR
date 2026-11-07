---
aside: false
---

# Checksum rules <Badge type="warning" text="LIVR 2.5 draft" />

Checksum rules check numbers with a check digit. The [string form](/validation-rules/how-it-works.html#string-form) of the value is checked as it is: no spaces, dashes or lowercase letters are removed. Use modifiers before, for example `[{ remove: ' -' }, 'to_uc', 'iban']`. The output is the string form. A boolean gives the error code of the rule, and an object or a list gives `FORMAT_ERROR`.

These rules are part of the [draft LIVR 2.5](/changes.html#v2-5-draft).

<RulesOverview group="checksum" />
