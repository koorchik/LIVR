. ./common.sh
PACKAGE=olifer
SOURCE=git

# olifer is not published on hex; build its default branch with erlang.mk.
git clone --quiet --depth 1 https://github.com/Prots/olifer.git olifer || fail "git clone olifer failed"
REV=$(git -C olifer rev-parse --short HEAD)
(cd olifer && make deps app) >make.log 2>&1 || { cat make.log; fail "olifer build (erlang.mk) failed"; }

erlc -o . livr_conformance.erl || fail "harness compilation failed"
OLIFER_REV="$REV" erl -noshell -pa . -pa olifer/ebin -pa olifer/deps/*/ebin \
    -eval 'livr_conformance:main(), halt().'
