---
title: mac
group: format
since: '2.5'
syntax: "'mac', { mac: 64 }"
example:
  rules: |-
    {
        device: 'mac'
    }
  input: |-
    {
        device: '00:1a:2b-3c:4d:5e'
    }
---

# mac

Checks that the value is a MAC address: six pairs of hex digits separated by `:` or by `-`. `{ mac: 64 }` checks a 64-bit EUI-64 identifier: eight pairs.

Error codes: `WRONG_MAC`, `FORMAT_ERROR`

<RuleSandbox />

The same separator is used everywhere: `00:1A:2b:3c:4D:5e` and `00-1a-2b-3c-4d-5e` pass, `00:1a:2b-3c:4d:5e` does not. Hex digits are case-insensitive, and the case of the input is kept in the output.

The argument is the number of bits:

| Rule | Pairs | Example | Used for |
|---|---|---|---|
| `'mac'`, `{ mac: 48 }` | 6 | `00:1a:2b:3c:4d:5e` | MAC-48 / EUI-48: Ethernet, Wi-Fi, Bluetooth |
| `{ mac: 64 }` | 8 | `70-B3-D5-7E-D0-00-12-34` | EUI-64: LoRaWAN DevEUI and JoinEUI, IEEE 802.15.4 (Zigbee), IPv6 interface identifiers |

```js
{ dev_eui: ['required', { mac: 64 }] }
```

Any other number (`{ mac: 32 }`) is a [schema error](/validation-rules/how-it-works.html#arguments). Forms without separators (`001a2b3c4d5e`) and with dots (`001a.2b3c.4d5e`) do not pass: use `hex` with `length_equal` for them.
