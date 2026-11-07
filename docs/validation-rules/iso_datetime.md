---
title: iso_datetime
group: special
since: '2.5'
syntax: "'iso_datetime', { iso_datetime: { min: 'today' } }"
example:
  rules: |-
    {
        starts_at: 'iso_datetime',
        ends_at: { iso_datetime: { max: '2026-12-31' } }
    }
  input: |-
    {
        starts_at: '2026-10-29T10:00:00.123456+02:00',
        ends_at: '2026-10-29'
    }
---

# iso_datetime

Checks that the value is an ISO 8601 date and time with an offset, and returns it in UTC, for example `"2026-10-29T08:00:00.000Z"`.

Error codes: `WRONG_DATETIME`, `DATETIME_TOO_EARLY`, `DATETIME_TOO_LATE`, `FORMAT_ERROR`

<RuleSandbox />

The [string form](/validation-rules/how-it-works.html#string-form) of the value must be a date and a time with an offset:

```text
YYYY-MM-DD "T" HH ":" MM [ ":" SS [ "." 1*9DIGIT ] ] ( "Z" / ( "+" / "-" ) HH ":" MM )
```

- `T` and `Z` are uppercase. `HH` is `00`–`23` (in the offset too), `MM` and `SS` are `00`–`59` (no leap second), and the date is a valid calendar date.
- The offset is required: `'2026-10-29T10:00'` gives `WRONG_DATETIME`.
- Seconds are optional, so a value from `<input type="datetime-local">` with an offset added passes.
- A date without a time gives `WRONG_DATETIME`. Use [`iso_date`](/validation-rules/iso_date.html) for dates.

```js
{ starts_at: 'iso_datetime' } // '2026-10-29T10:00Z', '2026-10-29T10:00:15+02:00', '2026-10-29T10:00:15.250-05:00'
```

## Output {#output}

The output is the instant in UTC as `YYYY-MM-DDTHH:MM:SS.sssZ`, with exactly three fraction digits. Further digits are cut off, not rounded:

| Input | Output |
|---|---|
| `'2026-10-29T10:00+02:00'` | `'2026-10-29T08:00:00.000Z'` |
| `'2026-10-29T10:00:00.123456+02:00'` | `'2026-10-29T08:00:00.123Z'` |
| `'2026-10-29T00:30:00-01:00'` | `'2026-10-29T01:30:00.000Z'` |

A value whose UTC instant falls outside the years `0000`–`9999` gives `WRONG_DATETIME`, because it cannot be written in this form: `'0000-01-01T00:00+01:00'` is in the year `-0001` in UTC.

## Bounds {#bounds}

`{ iso_datetime: { min, max } }` also checks that the instant is within the bounds. Both options are optional, both bounds are inclusive, and `{ iso_datetime: {} }` is the same as `'iso_datetime'`.

```js
{ starts_at: { iso_datetime: { min: '2026-01-01T09:00:00Z', max: 'tomorrow' } } }
{ paid_at:   { iso_datetime: { max: 'today' } } }
{ slot:      { iso_datetime: { min: '2026-06-01', max: '2026-08-31' } } }
```

A bound is:

- a datetime in the grammar above: that instant;
- a date `YYYY-MM-DD`: as `min` the start of that UTC day (`00:00:00.000Z`), as `max` the end of it (`23:59:59.999Z`);
- `'today'`, `'yesterday'` or `'tomorrow'`: the current date in UTC, one day before it, one day after it, with the same start-of-day and end-of-day rule.

A value before `min` gives `DATETIME_TOO_EARLY`, after `max` gives `DATETIME_TOO_LATE`. Any other bound (`null`, or `'current'` from js-livr-extra-rules) or an unknown option is a [schema error](/validation-rules/how-it-works.html#arguments). Don't pass arguments after the options object: what happens to them depends on the implementation.

The first argument, if there is one, must be an options object: `{ iso_datetime: 'today' }` is a schema error. `min` later than `max` is a schema error, as in [`iso_date`](/validation-rules/iso_date.html#options-form), when both bounds are fixed (datetimes or dates) or both are relative; the bounds are compared after they are cut to milliseconds. A fixed and a relative bound are not checked, because the result depends on the day; `min` is checked first.

The format is checked before the bounds, so a bound code always means a valid value: `'9999-12-31T23:30-01:00'` (the year 10000 in UTC) gives `WRONG_DATETIME`, even with a `max` that it is after. A bound itself may fall outside the years `0000`–`9999` in UTC: it is only compared, never written out.

Values and bounds are cut to milliseconds before they are compared, so all implementations agree: `'2026-10-29T23:59:59.9999Z'` is not after a `max` of `'2026-10-29'`.

`'today'` is a date, not the current instant: `{ max: 'today' }` means the end of today and lets times later today pass. There is no bound for the current moment.

## The current date {#current-date}

`'today'`, `'yesterday'` and `'tomorrow'` depend on the current time of the system, always in UTC, never in the local time zone of the server. There is no API for it: tests fix the system clock with the usual tools of the language, as dev dependencies only, see [`iso_date`](/validation-rules/iso_date.html#the-current-date).
