. ./common.sh
PACKAGE=livr
SOURCE=crates.io

# LIVR_RUST_PATH: a local checkout of rust-livr instead of crates.io, to try the harness
if [ -n "${LIVR_RUST_PATH:-}" ]; then
    SOURCE=path
    cargo add --quiet livr --path "$LIVR_RUST_PATH/livr" || fail "cargo add livr (path) failed"
fi
cargo build --quiet --release || fail "cargo build of harness failed"
SOURCE="$SOURCE" cargo run --quiet --release || fail "cargo run of harness failed"
