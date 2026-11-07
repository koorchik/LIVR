---
title: iso_date
group: special
syntax: "'iso_date'"
example:
  rules: |-
    {
        birth_date: 'iso_date'
    }
  input: |-
    {
        birth_date: '2014-02-30'
    }
---

# iso_date

Checks that the value is an ISO 8601 date without time, for example `"2014-08-14"`.

Error codes: `WRONG_DATE`, `FORMAT_ERROR`

<RuleSandbox />

## Options form <Badge type="info" text="LIVR 2.5" /> {#options-form}

::: info LIVR 2.5
This form was added in [LIVR 2.5](/changes.html#v2-5). Implementations of LIVR 2.0 do not support it.
:::

The 2.0 forms `'iso_date'` and `{ iso_date: [] }` do not change: they accept only `YYYY-MM-DD`, a valid date in the proleptic Gregorian calendar (`1582-10-10` is valid, `1500-02-29` is not), and do not change the value. `{ iso_date: null }` is the plain `iso_date` too.

The first argument, if there is one, must be an options object. `{ iso_date: 'x' }`, `{ iso_date: 'today' }` and `{ iso_date: ['x', { min: 'today' }] }` are [schema errors](/validation-rules/how-it-works.html#arguments): LIVR 2.0 ignored them, so they never checked what they say. Don't pass arguments after the object: what happens to them depends on the implementation.

LIVR 2.5 adds an options object with bounds:

```js
{ birth_date: { iso_date: { max: 'today' } } }
{ event_date: { iso_date: { min: 'yesterday', max: 'tomorrow' } } }
{ season:     { iso_date: { min: '2026-06-01', max: '2026-08-31' } } }
```

| Option | Values | Default |
|---|---|---|
| `min` | a date bound | no bound |
| `max` | a date bound | no bound |

Error codes: `WRONG_DATE`, `DATE_TOO_EARLY`, `DATE_TOO_LATE`, `FORMAT_ERROR`

- The value is `YYYY-MM-DD`, as in 2.0. The output is the value unchanged.
- A date bound is a date `YYYY-MM-DD` or one of `'today'`, `'yesterday'` and `'tomorrow'`: the current date in UTC, one day before it, one day after it. `'current'` from js-livr-extra-rules is a schema error.
- Dates are compared as calendar dates, and both bounds are inclusive. A date before `min` gives `DATE_TOO_EARLY`, after `max` gives `DATE_TOO_LATE`.
- `{ iso_date: {} }` and `{ iso_date: [{}] }` are the same as `'iso_date'`. An unknown option or a wrong bound is a [schema error](/validation-rules/how-it-works.html#arguments).
- `min` later than `max` is a schema error when both are dates or both are relative (`{ min: 'tomorrow', max: 'yesterday' }`): no value could pass. A date and a relative bound are not checked, because the result depends on the day: `{ min: '2026-12-01', max: 'today' }` accepts nothing before December, and that can be intended. With such bounds a value can be both before `min` and after `max`: `min` is checked first, so it gets `DATE_TOO_EARLY`.
- In every form, also in `'iso_date'`, a value that is not a string (a number, a boolean) gives `WRONG_DATE` (some 2.0 implementations gave `FORMAT_ERROR` for a boolean), and an object or a list gives `FORMAT_ERROR`. The format is checked before the bounds, so `DATE_TOO_EARLY` and `DATE_TOO_LATE` always mean a valid date.

For dates with a time, use [`iso_datetime`](/validation-rules/iso_datetime.html). The `format` option of js-livr-extra-rules is not in 2.5: `{ iso_date: { format: 'datetime' } }` is a schema error.

### The current date

`'today'`, `'yesterday'` and `'tomorrow'` depend on the current time of the system, always in UTC, never in the local time zone of the server. There is no API for it: tests fix the system clock with the usual tools of the language, as dev dependencies only, for example fake timers in JavaScript, `Test::MockTime` in Perl, `php-mock` in PHP, `freezegun` in Python or `Timecop` in Ruby. Where the language cannot replace the system clock (Rust, Go, Java, Swift, Dart without a runtime dependency), the implementation takes the time or a clock, for example as a validator option.
