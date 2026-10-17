. ./common.sh
PACKAGE=github.com/k33nice/go-livr
SOURCE=go

export GOFLAGS=-mod=mod
go get github.com/k33nice/go-livr@latest || fail "go get github.com/k33nice/go-livr failed"
go run . || fail "go build of harness failed"
