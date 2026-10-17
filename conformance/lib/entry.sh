#!/bin/sh
# Entry point used by conformance/run.sh, inside the container (or directly on
# the host with NATIVE=1). Copies conformance/<id>/ into a writable work dir and
# runs its container.sh, which installs the implementation and runs the harness.
set -u

REPO_DIR="${REPO_DIR:-/repo}"
HARNESS_DIR="$REPO_DIR/conformance/$ID"
WORK="${WORK_ROOT:-/tmp}/livr-conformance/$ID"

rm -rf "$WORK"
mkdir -p "$WORK"
cp -R "$HARNESS_DIR/." "$WORK/"
cp "$REPO_DIR/conformance/lib/common.sh" "$WORK/common.sh"
cd "$WORK" || exit 1

rm -f "$OUT_FILE"
# Safety net against an implementation that hangs (installs included).
if command -v timeout >/dev/null 2>&1; then
    timeout 1500 sh ./container.sh
else
    sh ./container.sh
fi
rc=$?

if [ ! -s "$OUT_FILE" ]; then
    printf '{"id":"%s","package":null,"version":null,"source":null,"total":0,"passed":0,"failures":[],"error":"harness exited with code %s before producing results"}\n' \
        "$ID" "$rc" >"$OUT_FILE"
fi

chown "${HOST_UID:-0}:${HOST_GID:-0}" "$OUT_FILE" 2>/dev/null || true
exit 0
