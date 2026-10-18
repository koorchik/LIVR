---
title: not_empty_list
group: common
syntax: "'not_empty_list'"
example:
  rules: |-
    {
        product_ids: 'not_empty_list'
    }
  input: |-
    {
        product_ids: []
    }
---

# not_empty_list

Checks that the value is a list with at least one element.

Error codes: `CANNOT_BE_EMPTY` if the value is missing or the list is empty, `FORMAT_ERROR` if the value is present but is not a list.

<RuleSandbox />
