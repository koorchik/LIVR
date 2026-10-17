. ./common.sh
PACKAGE=Validator::LIVR
SOURCE=cpan

cpanm --quiet --notest Validator::LIVR || fail "cpanm Validator::LIVR failed"
perl harness.pl
