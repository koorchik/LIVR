. ./common.sh
PACKAGE=livr-swift-validator
SOURCE=git

# Not published to the Swift Package Index (CocoaPods "Livr" only), so build the
# default branch of the repository from source.
git clone --quiet --depth 1 https://github.com/olxbr/livr-swift-validator.git \
    || fail "git clone livr-swift-validator failed"
POD_VERSION=$(sed -n "s/.*s\.version *= *['\"]\([^'\"]*\)['\"].*/\1/p" livr-swift-validator/Livr.podspec)
REV=$(git -C livr-swift-validator rev-parse --short HEAD)
export LIVR_VERSION="${POD_VERSION:-unknown}@$REV"

if ! swift build -c release >build.log 2>&1; then
    tail -40 build.log
    if grep -q "NSPredicate" build.log; then
        fail "does not build on Linux (needs Apple Foundation: NSPredicate format strings); run on macOS"
    fi
    fail "swift build of livr-swift-validator failed"
fi
.build/release/Harness
