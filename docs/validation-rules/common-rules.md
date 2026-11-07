---
aside: false
---

# Common rules

These rules check that a value is present, or that it is an object. Only `required`, `not_empty` and `not_empty_list` check empty values, all other rules skip them.

The [draft LIVR 2.5](/changes.html#v2-5-draft) adds a rule for conditional presence (`required_if`), a rule that accepts any value (`any`), and `boolean`. `required_if` and `any` do not skip empty values.

<RulesOverview group="common" />
