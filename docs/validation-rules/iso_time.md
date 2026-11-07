---
title: iso_time
group: special
since: '2.5'
syntax: "'iso_time', { iso_time: { min: '09:00', max: '18:00' } }"
example:
  rules: |-
    {
        opens_at: 'iso_time'
    }
  input: |-
    {
        opens_at: '24:00'
    }
---

# iso_time

Checks that the value is a time of day without a date and an offset: `HH:MM`, `HH:MM:SS`, or `HH:MM:SS` with a fraction of a second.

Error codes: `WRONG_TIME`, `TIME_TOO_EARLY`, `TIME_TOO_LATE`, `FORMAT_ERROR`

<RuleSandbox />

The [string form](/validation-rules/how-it-works.html#string-form) of the value must be `HH:MM`, `HH:MM:SS`, or `HH:MM:SS.` followed by 1–9 digits. `HH` is `00`–`23`, `MM` and `SS` are `00`–`59`. There is no offset: this is what `<input type="time">` sends. The output is the string form.

```js
{ opens_at: 'iso_time' } // '09:30', '09:30:15', '09:30:15.250'
```

## Bounds {#bounds}

`{ iso_time: { min, max } }` also checks that the time of day is within the bounds. Both options are optional and are times in the same grammar; `{ iso_time: {} }` is the same as `'iso_time'`. Times are compared exactly as times of day: `'09:00'` equals `'09:00:00.000'`, and all nine fraction digits count. A time before `min` gives `TIME_TOO_EARLY`, after `max` gives `TIME_TOO_LATE`.

```js
{ opens_at: { iso_time: { min: '09:00', max: '18:00' } } } // '08:59' gives TIME_TOO_EARLY, '18:01' gives TIME_TOO_LATE
{ starts_at: { iso_time: { min: '06:00' } } }
```

If `min` is greater than `max`, the range goes over midnight: `{ min: '22:00', max: '06:00' }` accepts `'23:30'`, `'00:00'` and `'05:59'`. A time between `max` and `min` gets the error of the nearer bound: `'07:00'` gives `TIME_TOO_LATE` (it is after the end), `'21:00'` gives `TIME_TOO_EARLY` (it is before the start). Exactly: a time `t` in the gap gives `TIME_TOO_LATE` if `t − max < min − t`, otherwise `TIME_TOO_EARLY`, with times compared in nanoseconds. So exactly in the middle (`'14:00'`) it is `TIME_TOO_EARLY`: the choice is arbitrary, but every implementation gives the same code.

```js
{ night_shift: { iso_time: { min: '22:00', max: '06:00' } } }
```

::: warning
Swapped bounds are not an error: `{ min: '18:00', max: '09:00' }` silently means "from 18:00 over midnight to 09:00" and rejects the working day. Check the order when you write the bounds.
:::

There is no `today` or other relative bound: a time without a date and an offset cannot be compared with the current time. An unknown option or a bound that is not a valid time is a [schema error](/validation-rules/how-it-works.html#arguments). The first argument, if there is one, must be an options object: `{ iso_time: '09:00' }` is a schema error. Don't pass arguments after the options object: what happens to them depends on the implementation.
