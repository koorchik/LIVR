. ./common.sh
PACKAGE=Validator::LIVR
SOURCE=cpan

# --from: the CPAN index itself (02packages), not the cpanmetadb cache, which can lag behind a
# release by days
cpanm --quiet --notest --from https://www.cpan.org Validator::LIVR || fail "cpanm Validator::LIVR failed"
# Fixes the current time of the LIVR 2.5 cases with options.json; the harness runs without it
cpanm --quiet --notest --from https://www.cpan.org Test::MockTime || echo "conformance: cpanm Test::MockTime failed, the cases run with the system clock" >&2
perl harness.pl
