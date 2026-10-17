"""Runs the LIVR test suite against the PyPI "LIVR" package.

Comparison mirrors python-validator-livr's own tests (assertEqual, i.e. ==):
"1" != 1, but 1 == 1.0; key order does not matter.
"""
import json
import os
import traceback
from importlib.metadata import version

from LIVR import Validator

SUITE_DIR = os.environ.get("TEST_SUITE_DIR", "../../test_suite")
SUITES = ["positive", "negative", "aliases_positive", "aliases_negative"]


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


def run_case(suite, case_dir):
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

    for suite in SUITES:
        suite_dir = os.path.join(SUITE_DIR, suite)
        for name in sorted(n for n in os.listdir(suite_dir) if not n.startswith(".")):
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
