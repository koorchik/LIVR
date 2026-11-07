. ./common.sh
PACKAGE=Validator::LIVR
SOURCE=cpan

# --from: the CPAN index itself (02packages), not the cpanmetadb cache, which can lag behind a
# release by days
cpanm --quiet --notest --from https://www.cpan.org Validator::LIVR || fail "cpanm Validator::LIVR failed"
perl harness.pl
