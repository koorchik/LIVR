#!/usr/bin/env bash
# Runs the LIVR test suite against one implementation (or all of them)
# inside the implementation's official Docker image.
#
#   conformance/run.sh js            # one implementation
#   conformance/run.sh all           # every implementation, sequentially
#   OUT_DIR=/tmp/results conformance/run.sh perl
#   NATIVE=1 conformance/run.sh swift  # no Docker: use the host toolchain
#                                      # (livr-swift-validator needs macOS)
#
# Results are written to $OUT_DIR/<id>.json (default: conformance/out),
# the container log to $OUT_DIR/<id>.log.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$HERE")"
OUT_DIR="${OUT_DIR:-$HERE/out}"

IDS=(js perl raku php python erlang-liver erlang-olifer java ruby lua go swift dart)

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
        *)             return 1 ;;
    esac
}

run_one() {
    local id="$1" image
    if ! image="$(image_for "$id")"; then
        echo "Unknown implementation id: $id (known: ${IDS[*]})" >&2
        return 2
    fi

    mkdir -p "$OUT_DIR"
    rm -f "$OUT_DIR/$id.json"

    if [ "${NATIVE:-}" = "1" ]; then
        echo "==> $id (native)"
        REPO_DIR="$ROOT" ID="$id" TEST_SUITE_DIR="$ROOT/test_suite" OUT_FILE="$OUT_DIR/$id.json" \
            WORK_ROOT="${RUNNER_TEMP:-${TMPDIR:-/tmp}}" \
            sh "$HERE/lib/entry.sh" >"$OUT_DIR/$id.log" 2>&1
        report "$id" $?
        return
    fi

    echo "==> $id ($image)"
    docker run --rm \
        -v "$ROOT:/repo:ro" \
        -v "$OUT_DIR:/out" \
        -e "ID=$id" \
        -e "TEST_SUITE_DIR=/repo/test_suite" \
        -e "OUT_FILE=/out/$id.json" \
        -e "HOST_UID=$(id -u)" \
        -e "HOST_GID=$(id -g)" \
        "$image" sh /repo/conformance/lib/entry.sh >"$OUT_DIR/$id.log" 2>&1
    report "$id" $?
}

report() {
    local id="$1" rc="$2"
    if [ ! -s "$OUT_DIR/$id.json" ]; then
        # The container never got as far as writing a result (e.g. image pull failed).
        printf '{"id":"%s","package":null,"version":null,"source":null,"total":0,"passed":0,"failures":[],"error":"runner failed with exit code %s before producing results"}\n' \
            "$id" "$rc" >"$OUT_DIR/$id.json"
    fi

    # shellcheck disable=SC2016  # JavaScript template literals, not shell expansions
    node -e '
        const r = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
        console.log(r.error
            ? `    error: ${r.error}`
            : `    ${r.package} ${r.version}: ${r.passed}/${r.total} passed`);
    ' "$OUT_DIR/$id.json" 2>/dev/null || cat "$OUT_DIR/$id.json"
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
