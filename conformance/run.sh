#!/usr/bin/env bash
# Runs the LIVR test suite against one implementation (or all of them)
# inside the implementation's official Docker image.
#
#   conformance/run.sh js            # one implementation
#   conformance/run.sh all           # every implementation, sequentially
#   OUT_DIR=/tmp/results conformance/run.sh perl
#   NATIVE=1 conformance/run.sh swift  # no Docker: use the host toolchain
#                                      # (livr-swift-validator needs macOS)
#   SUITE=2.5 conformance/run.sh js    # the LIVR 2.5 suite (test_suite_2.5)
#
# Results are written to $OUT_DIR/<id>.json (default: conformance/out),
# the container log to $OUT_DIR/<id>.log. With SUITE=2.5 the files are
# $OUT_DIR/<id>.v2.5.json and $OUT_DIR/<id>.v2.5.log.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$HERE")"
OUT_DIR="${OUT_DIR:-$HERE/out}"

IDS=(js perl raku php python erlang-liver erlang-olifer java ruby lua go swift dart rust)

SUITE="${SUITE:-2.0}"
case "$SUITE" in
    2.0) SUITE_DIR="test_suite"; SUFFIX="" ;;
    2.5) SUITE_DIR="test_suite_2.5"; SUFFIX=".v2.5" ;;
    *)   echo "Unknown SUITE: $SUITE (known: 2.0, 2.5)" >&2; exit 2 ;;
esac

image_for() {
    case "$1" in
        js)            echo "node:24-slim" ;;
        perl)          echo "perl:5.40" ;;
        raku)          echo "rakudo-star:2024.02" ;;  # LIVR 2.1.0 no longer compiles on current Rakudo
        php)           echo "composer:2" ;;
        python)        echo "python:3.13-slim" ;;
        erlang-liver)  echo "erlang:27" ;;
        erlang-olifer) echo "erlang:29" ;;
        java)          echo "maven:3-eclipse-temurin-21" ;;
        ruby)          echo "ruby:4.0" ;;
        lua)           echo "alpine:3.20" ;;
        go)            echo "golang:1.23" ;;
        swift)         echo "swift:5.10" ;;
        dart)          echo "dart:3" ;;
        rust)          echo "rust:1-slim" ;;
        *)             return 1 ;;
    esac
}

run_one() {
    local id="$1" image suite_dir mount=() out
    out="$id$SUFFIX"
    if ! image="$(image_for "$id")"; then
        echo "Unknown implementation id: $id (known: ${IDS[*]})" >&2
        return 2
    fi

    mkdir -p "$OUT_DIR"
    rm -f "$OUT_DIR/$out.json"

    suite_dir="$ROOT/$SUITE_DIR"

    if [ "${NATIVE:-}" = "1" ]; then
        echo "==> $id (native, suite $SUITE)"
        REPO_DIR="$ROOT" ID="$id" TEST_SUITE_DIR="$suite_dir" OUT_FILE="$OUT_DIR/$out.json" \
            WORK_ROOT="${RUNNER_TEMP:-${TMPDIR:-/tmp}}" \
            sh "$HERE/lib/entry.sh" >"$OUT_DIR/$out.log" 2>&1
        report "$id" "$out" $?
        cleanup_suite "$suite_dir"
        return
    fi

    if [ "$suite_dir" = "$ROOT/$SUITE_DIR" ]; then
        mount=(-e "TEST_SUITE_DIR=/repo/$SUITE_DIR")
    else
        mount=(-v "$suite_dir:/suite:ro" -e "TEST_SUITE_DIR=/suite")
    fi

    echo "==> $id ($image, suite $SUITE)"
    docker run --rm \
        -v "$ROOT:/repo:ro" \
        -v "$OUT_DIR:/out" \
        "${mount[@]}" \
        -e "ID=$id" \
        -e "OUT_FILE=/out/$out.json" \
        -e "HOST_UID=$(id -u)" \
        -e "HOST_GID=$(id -g)" \
        "$image" sh /repo/conformance/lib/entry.sh >"$OUT_DIR/$out.log" 2>&1
    report "$id" "$out" $?
    cleanup_suite "$suite_dir"
}

cleanup_suite() {
    [ "$1" != "$ROOT/$SUITE_DIR" ] && rm -rf "$1"
    return 0
}

# A copy of a suite without the cases that have options.json

report() {
    local id="$1" out="$2" rc="$3"  # out: the name of the result file, <id> or <id>.v2.5
    if [ ! -s "$OUT_DIR/$out.json" ]; then
        # The container never got as far as writing a result (e.g. image pull failed).
        printf '{"id":"%s","package":null,"version":null,"source":null,"total":0,"passed":0,"failures":[],"error":"runner failed with exit code %s before producing results"}\n' \
            "$id" "$rc" >"$OUT_DIR/$out.json"
    fi

    # shellcheck disable=SC2016  # JavaScript template literals, not shell expansions
    node -e '
        const r = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
        console.log(r.error
            ? `    error: ${r.error}`
            : `    ${r.package} ${r.version}: ${r.passed}/${r.total} passed`);
    ' "$OUT_DIR/$out.json" 2>/dev/null || cat "$OUT_DIR/$out.json"
}

if [ $# -ne 1 ]; then
    echo "Usage: $0 <id>|all   (ids: ${IDS[*]})" >&2
    exit 2
fi

if [ "$1" = "all" ]; then
    for id in "${IDS[@]}"; do run_one "$id"; done
else
    run_one "$1"
fi
