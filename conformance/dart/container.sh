. ./common.sh
PACKAGE=livr
SOURCE=pub

# LIVR_DART_PATH: a local checkout instead of pub.dev, to try the harness
if [ -n "${LIVR_DART_PATH:-}" ]; then
    SOURCE=path
    dart pub add "livr:{\"path\": \"$LIVR_DART_PATH\"}" || fail "dart pub add livr (path) failed"
else
    dart pub add livr || fail "dart pub add livr failed"
fi
SOURCE="$SOURCE" dart run harness.dart || fail "dart run harness.dart failed"
