. ./common.sh
PACKAGE=livr-swift-validator
SOURCE=git

# Not published to the Swift Package Index (CocoaPods "Livr" only), so build the
# default branch of the repository from source.
# LIVR_SWIFT_DIR builds a local checkout instead, e.g. an unreleased branch
# mounted into the container.
if [ -n "${LIVR_SWIFT_DIR:-}" ]; then
    mkdir livr-swift-validator \
        && (cd "$LIVR_SWIFT_DIR" && tar cf - --exclude=./.build .) | tar xf - -C livr-swift-validator \
        || fail "copying $LIVR_SWIFT_DIR failed"
else
    git clone --quiet --depth 1 https://github.com/olxbr/livr-swift-validator.git \
        || fail "git clone livr-swift-validator failed"
fi
POD_VERSION=$(sed -n "s/.*s\.version *= *['\"]\([^'\"]*\)['\"].*/\1/p" livr-swift-validator/Livr.podspec)
REV=$(git -c safe.directory="*" -C livr-swift-validator rev-parse --short HEAD 2>/dev/null || echo local)
export LIVR_VERSION="${POD_VERSION:-unknown}@$REV"

# LIVR 2.5 fixes the clock with LIVR.now (options.json). Released versions do
# not have it and Swift cannot test for a member at compile time, so tell the
# harness whether the library declares it.
DEFINES=""
if grep -Eq 'static var now *:' livr-swift-validator/Livr/*.swift; then
    DEFINES="-Xswiftc -DLIVR_HAS_NOW"
fi

# shellcheck disable=SC2086  # DEFINES is a list of arguments
if ! swift build -c release $DEFINES >build.log 2>&1; then
    tail -40 build.log
    if grep -q "NSPredicate" build.log; then
        fail "does not build on Linux (needs Apple Foundation: NSPredicate format strings); run on macOS"
    fi
    fail "swift build of livr-swift-validator failed"
fi
.build/release/Harness
