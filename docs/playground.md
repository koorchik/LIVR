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

Besides the [standard rules](/validation-rules.html), the playground has the rules of [livr-extra-rules](/introduction/extensions.html#livr-extra-rules) that are not in [LIVR 2.5](/changes.html#v2-5): `ipv4`, `is`, `md5` and `list_items_unique`. Other implementations may not have these rules. The rules of livr-extra-rules with the names of LIVR 2.5 rules (`boolean`, `uuid`, `iso_date` with options, ...) are not registered, so these names are the standard rules, see the [migration table](/changes.html#migration-from-js-livr-extra-rules).

<LivrPlayground />
