"""Runs the LIVR test suite against the PyPI "LIVR" package.

Comparison mirrors python-validator-livr's own tests (assertEqual, i.e. ==):
"1" != 1, but 1 == 1.0; key order does not matter.
"""
import json
import os
import sys
import traceback
from datetime import datetime
from importlib.metadata import version

from LIVR import Validator

SUITE_DIR = os.environ.get("TEST_SUITE_DIR", "../../test_suite")
SUITES = ["positive", "negative", "aliases_positive", "aliases_negative"]
# LIVR 2.5: schemas that must not build
SCHEMA_ERRORS = "schema_errors"


def read_json(case_dir, name):
    path = os.path.join(case_dir, name + ".json")
    if not os.path.exists(path):
        return None
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def show(value):
    try:
        s = json.dumps(value, ensure_ascii=False, sort_keys=True)
    except (TypeError, ValueError):
        s = repr(value)
    return s if len(s) <= 300 else s[:300] + "…"


def clock_modules():
    """The modules with the clock of the date rules, Dates.utc_now() (LIVR 2.5).

    LIVR puts its Rules directory on sys.path, so the module is "Dates"; "LIVR.Rules.Dates" too,
    in case it is imported as a package. Versions without the date rules have none.
    """
    names = ("Dates", "LIVR.Rules.Dates")
    return [sys.modules[n] for n in names if callable(getattr(sys.modules.get(n), "utc_now", None))]


def with_clock(options, fn):
    """options.json {"now": "..."} is the current time for the bounds today, yesterday and
    tomorrow. Like python-validator-livr's own tests, Dates.utc_now is replaced for the case and
    restored after it"""
    if not options or "now" not in options:
        return fn()
    now = datetime.fromisoformat(options["now"].replace("Z", "+00:00")).timestamp()
    saved = [(m, m.utc_now) for m in clock_modules()]
    for m, _ in saved:
        m.utc_now = lambda: now
    try:
        return fn()
    finally:
        for m, utc_now in saved:
            m.utc_now = utc_now


def run_schema_error_case(case_dir):
    try:
        validator = Validator.Validator(read_json(case_dir, "rules"))
        for alias in read_json(case_dir, "aliases") or []:
            validator.register_aliased_rule(alias)
        if hasattr(validator, "prepare"):
            validator.prepare()
        else:
            validator.validate({})
    except Exception:  # noqa: BLE001 - any exception is a schema error
        return None
    return "expected building the validator to fail"


def run_case(suite, case_dir):
    run = (lambda: run_schema_error_case(case_dir)) if suite == SCHEMA_ERRORS else (
        lambda: run_validation_case(suite, case_dir))
    return with_clock(read_json(case_dir, "options"), run)


def run_validation_case(suite, case_dir):
    rules = read_json(case_dir, "rules")
    data = read_json(case_dir, "input")
    aliases = read_json(case_dir, "aliases") or []

    validator = Validator.Validator(rules)
    for alias in aliases:
        validator.register_aliased_rule(alias)

    output = validator.validate(data)
    errors = validator.get_errors()

    if suite.endswith("positive"):
        expected = read_json(case_dir, "output")
        if errors:
            return "expected no errors, got " + show(errors)
        if output != expected:
            return "expected output %s, got %s" % (show(expected), show(output))
    else:
        expected = read_json(case_dir, "errors")
        if output:
            return "expected validation to fail, got output " + show(output)
        if errors != expected:
            return "expected errors %s, got %s" % (show(expected), show(errors))
    return None


def main():
    result = {
        "id": "python",
        "package": "LIVR",
        "version": version("LIVR"),
        "source": "pypi",
        "total": 0,
        "passed": 0,
        "failures": [],
        "error": None,
    }

    suites = SUITES + [SCHEMA_ERRORS] if os.path.isdir(os.path.join(SUITE_DIR, SCHEMA_ERRORS)) else SUITES
    for suite in suites:
        suite_dir = os.path.join(SUITE_DIR, suite)
        names = (n for n in os.listdir(suite_dir) if not n.startswith("."))
        for name in sorted(n for n in names if os.path.isdir(os.path.join(suite_dir, n))):
            result["total"] += 1
            try:
                message = run_case(suite, os.path.join(suite_dir, name))
            except Exception as e:  # noqa: BLE001 - any crash is a failed case
                message = "exception: %s: %s" % (type(e).__name__, e)
                traceback.print_exc()
            if message:
                result["failures"].append({"case": suite + "/" + name, "message": message})
            else:
                result["passed"] += 1

    out = json.dumps(result, indent=2, ensure_ascii=False) + "\n"
    if os.environ.get("OUT_FILE"):
        with open(os.environ["OUT_FILE"], "w", encoding="utf-8") as f:
            f.write(out)
    else:
        print(out, end="")


main()
