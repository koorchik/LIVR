. ./common.sh
PACKAGE=livr
SOURCE=git

# livr is not on pub.dev yet: test the default branch of its repository.
# Until it is published, "dart pub add livr" could install another package with
# the same name. LIVR_DART_PATH: a local checkout instead, to try the harness.
if [ -n "${LIVR_DART_PATH:-}" ]; then
    SOURCE=path
    REV=""
    dart pub add "livr:{\"path\": \"$LIVR_DART_PATH\"}" || fail "dart pub add livr (path) failed"
else
    git clone --quiet --depth 1 https://github.com/koorchik/dart-livr.git dart-livr || fail "git clone dart-livr failed"
    REV=$(git -C dart-livr rev-parse --short HEAD)
    dart pub add "livr:{\"path\": \"dart-livr\"}" || fail "dart pub add livr failed"
fi
SOURCE="$SOURCE" LIVR_REV="$REV" dart run harness.dart || fail "dart run harness.dart failed"
