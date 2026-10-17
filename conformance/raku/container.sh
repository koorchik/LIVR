. ./common.sh
PACKAGE=LIVR
SOURCE=zef

zef install --/test LIVR JSON::Tiny >zef.log 2>&1 || { cat zef.log; fail "zef install LIVR failed"; }
raku harness.raku
