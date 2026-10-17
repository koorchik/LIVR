. ./common.sh
PACKAGE=olifer
SOURCE=git

# olifer is not published on hex; build its default branch with erlang.mk.
git clone --quiet --depth 1 https://github.com/Prots/olifer.git olifer || fail "git clone olifer failed"
REV=$(git -C olifer rev-parse --short HEAD)
# Its declared dependency github.com/erlangbureau/parselib (the bstring module, used by
# trim/to_lc/to_uc/remove) no longer exists. Fetch the v2.1.0 tag from a mirror,
# pinned to the commit (the code was reviewed: pure string functions).
# erlang.mk builds with -Werror by default; OTP 24 warns that http_uri is deprecated.
(cd olifer && make deps app ERLC_OPTS="+debug_info" \
    dep_parselib="git https://github.com/SCDependencies/parselib.git 85d58541403a4ae236eec0fa91150a2e50e1ef96") >make.log 2>&1 \
    || { cat make.log; fail "olifer build (erlang.mk) failed"; }

erlc -o . livr_conformance.erl || fail "harness compilation failed"
OLIFER_REV="$REV" erl -noshell -pa . -pa olifer/ebin -pa olifer/deps/*/ebin \
    -eval 'livr_conformance:main(), halt().'
