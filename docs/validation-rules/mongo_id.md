---
title: mongo_id
group: format
since: '2.5'
syntax: "'mongo_id'"
example:
  rules: |-
    {
        id: 'mongo_id'
    }
  input: |-
    {
        id: '507f1f77bcf86cd79943901'
    }
---

# mongo_id

Checks that the value is a BSON ObjectId: 24 hex digits.

Error codes: `WRONG_MONGO_ID`, `FORMAT_ERROR`

<RuleSandbox />

Hex digits are case-insensitive, and the case of the input is kept in the output.
