---
title: Playground
description: Try LIVR validation rules in the browser. Edit rules, input data and aliases and see the output or the error codes immediately.
sidebar: false
aside: false
outline: false
pageClass: playground-page
editLink: false
lastUpdated: false
prev: false
next: false
---

# Playground

Write LIVR rules and input data and see the result immediately. Rules and data use the [JSON5](https://json5.org) syntax: unquoted keys, single quotes and trailing commas are allowed. The URL updates as you type, so you can share it.

Besides the [standard rules](/validation-rules.html), the playground has the rules of [livr-extra-rules](/introduction/extensions.html#livr-extra-rules): `ipv4`, `boolean`, `is`, `uuid`, `credit_card`, `mongo_id`, `base64`, `md5`, `list_length`, `list_items_unique`, `required_if` and an extended `iso_date` with `min`, `max` and `format` options. Other implementations may not have these rules.

<LivrPlayground />
