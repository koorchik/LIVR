. ./common.sh
PACKAGE=liver
SOURCE=hex

rebar3 compile >rebar.log 2>&1 || { cat rebar.log; fail "rebar3 could not fetch/compile liver from hex"; }
erl -noshell -pa _build/default/lib/*/ebin -eval 'livr_conformance:main(), halt().'
