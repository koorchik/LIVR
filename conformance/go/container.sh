. ./common.sh
PACKAGE=github.com/k33nice/go-livr
SOURCE=go

export GOFLAGS=-mod=mod
if [ -n "${GO_LIVR_DIR:-}" ]; then
    # A local checkout instead of the released module, e.g. an unreleased branch. go-livr has no
    # go.mod, so a writable copy gets one.
    cp -R "$GO_LIVR_DIR" ./go-livr-src || fail "cannot copy $GO_LIVR_DIR"
    [ -f go-livr-src/go.mod ] || printf 'module github.com/k33nice/go-livr\n\ngo 1.21\n' >go-livr-src/go.mod
    go mod edit -require=github.com/k33nice/go-livr@v0.0.0-00010101000000-000000000000 \
        -replace=github.com/k33nice/go-livr=./go-livr-src
else
    go get github.com/k33nice/go-livr@latest || fail "go get github.com/k33nice/go-livr failed"
fi
go run . || fail "go build of harness failed"
