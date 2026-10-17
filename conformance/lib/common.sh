# Helpers sourced by conformance/<id>/container.sh.
# Expects ID and OUT_FILE in the environment; PACKAGE and SOURCE may be set
# by the caller before fail() is used.

# fail "<reason>" - records that the implementation could not be installed
# or built, then stops the container script.
fail() {
    reason=$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')
    printf '{"id":"%s","package":"%s","version":null,"source":"%s","total":0,"passed":0,"failures":[],"error":"%s"}\n' \
        "$ID" "${PACKAGE:-}" "${SOURCE:-}" "$reason" >"$OUT_FILE"
    echo "conformance: $reason" >&2
    exit 1
}
