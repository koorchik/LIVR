. ./common.sh
PACKAGE=livr
SOURCE=npm

npm install --no-audit --no-fund --silent livr || fail "npm install livr failed"
node harness.mjs
