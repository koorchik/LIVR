%% Runs the LIVR test suite against hex package liver, using its
%% `rule_set => livr_spec' mode.
%%
%% Data is decoded with OTP's json module (maps, binary strings). Rule names
%% are converted to atoms the same way liver's own scripts/livr_import.erl does
%% before liver's tests run. liver returns iso_date values as {Y, M, D}; they
%% are compared in their JSON form ("YYYY-MM-DD"). Values are compared with ==,
%% so 1 == 1.0, but <<"1">> =/= 1.
%%
%% LIVR 2.5 (test_suite_2.5): aliases go to the `aliased_rules' option (liver
%% with add_aliased_rule/1); a schema_errors case passes when
%% liver:check_schema/2 rejects the schema (or, without check_schema, when the
%% first validation of #{} raises); options.json {"now": ...} fixes the clock
%% with liver_clock:set_time/1, as liver's own tests do. Each is
%% feature-detected, so the harness runs with older releases too.
-module(livr_conformance).

-export([main/0]).

-define(SUITES, ["positive", "negative", "aliases_positive", "aliases_negative"]).
%% LIVR 2.5: schemas that must not build
-define(SCHEMA_ERRORS, "schema_errors").
-define(OPTS, #{rule_set => livr_spec}).

-define(LIVR_RULES, [
    <<"required">>, <<"not_empty">>, <<"not_empty_list">>, <<"any_object">>,
    <<"string">>, <<"eq">>, <<"one_of">>, <<"max_length">>, <<"min_length">>,
    <<"length_between">>, <<"length_equal">>, <<"like">>,
    <<"integer">>, <<"positive_integer">>, <<"decimal">>, <<"positive_decimal">>,
    <<"max_number">>, <<"min_number">>, <<"number_between">>,
    <<"email">>, <<"url">>, <<"iso_date">>, <<"equal_to_field">>,
    <<"nested_object">>, <<"variable_object">>, <<"list_of">>, <<"list_of_objects">>,
    <<"list_of_different_objects">>, <<"or">>,
    <<"trim">>, <<"to_lc">>, <<"to_uc">>, <<"remove">>, <<"leave_only">>, <<"default">>,
    %% LIVR 2.5
    <<"boolean">>, <<"not_one_of">>, <<"max_decimals">>, <<"digits">>, <<"starts_with">>,
    <<"ends_with">>, <<"contains">>, <<"iso_datetime">>, <<"iso_time">>, <<"required_if">>,
    <<"when">>, <<"values">>, <<"keys">>, <<"any">>, <<"list_length">>, <<"unique">>,
    <<"split">>, <<"uuid">>, <<"ip">>, <<"cidr">>, <<"hostname">>, <<"base64">>, <<"hex">>,
    <<"digest">>, <<"mongo_id">>, <<"hex_color">>, <<"mac">>, <<"e164">>, <<"semver">>,
    <<"jwt">>, <<"luhn">>, <<"credit_card">>, <<"iban">>
]).

main() ->
    SuiteDir = os:getenv("TEST_SUITE_DIR", "../../test_suite"),
    ok = application:load(liver),
    {module, liver} = code:ensure_loaded(liver),
    {ok, Vsn} = application:get_key(liver, vsn),
    Suites = case filelib:is_dir(filename:join(SuiteDir, ?SCHEMA_ERRORS)) of
        true -> ?SUITES ++ [?SCHEMA_ERRORS];
        false -> ?SUITES
    end,
    {Total, Passed, Failures} = lists:foldl(
        fun(Suite, Acc) -> run_suite(SuiteDir, Suite, Acc) end,
        {0, 0, []},
        Suites),
    Result = #{
        id => <<"erlang-liver">>,
        package => <<"liver">>,
        version => unicode:characters_to_binary(Vsn),
        source => <<"hex">>,
        total => Total,
        passed => Passed,
        failures => lists:reverse(Failures),
        error => null
    },
    Out = [json:format(Result), $\n],
    case os:getenv("OUT_FILE") of
        false -> io:put_chars(Out);
        File -> ok = file:write_file(File, Out)
    end.

run_suite(SuiteDir, Suite, Acc0) ->
    Dir = filename:join(SuiteDir, Suite),
    {ok, Names} = file:list_dir(Dir),
    Cases = lists:sort([N || N <- Names, hd(N) =/= $., filelib:is_dir(filename:join(Dir, N))]),
    lists:foldl(
        fun(Name, {Total, Passed, Failures}) ->
            CaseDir = filename:join(Dir, Name),
            Message = try with_clock(read_json(CaseDir, "options"), fun() -> run_case(Suite, CaseDir) end)
                      catch Class:Reason -> format("exception: ~p:~0p", [Class, Reason])
                      end,
            case Message of
                ok -> {Total + 1, Passed + 1, Failures};
                _ -> {Total + 1, Passed, [#{<<"case">> => list_to_binary(Suite ++ "/" ++ Name),
                                            message => Message} | Failures]}
            end
        end,
        Acc0,
        Cases).

%% options.json {"now": "<ISO datetime>"}: the current time of the case.
%% liver_clock:set_time/1 (liver with LIVR 2.5) fixes it; without it the case
%% runs with the system time.
with_clock(#{<<"now">> := Now}, Fun) ->
    case has_function(liver_clock, set_time, 1) of
        true ->
            Ms = calendar:rfc3339_to_system_time(binary_to_list(Now), [{unit, millisecond}]),
            ok = liver_clock:set_time(Ms),
            try Fun() after liver_clock:set_time(undefined) end;
        false ->
            Fun()
    end;
with_clock(_Options, Fun) ->
    Fun().

has_function(Module, Function, Arity) ->
    code:ensure_loaded(Module) =:= {module, Module}
        andalso erlang:function_exported(Module, Function, Arity).

run_case(Suite, Dir) ->
    case {read_json(Dir, "aliases"), has_function(liver, add_aliased_rule, 1)} of
        {undefined, _} ->
            run_case(Suite, Dir, ?OPTS);
        {Aliases, true} ->
            run_case(Suite, Dir, ?OPTS#{aliased_rules => [convert_alias(A) || A <- Aliases]});
        {_, false} ->
            <<"liver has no API for registering aliased rules">>
    end.

run_case(?SCHEMA_ERRORS, Dir, Opts) ->
    Rules = convert_schema(read_json(Dir, "rules")),
    case schema_error(Rules, Opts) of
        true -> ok;
        false -> <<"expected building the validator to fail">>
    end;
run_case(Suite, Dir, Opts) ->
    Rules = convert_schema(read_json(Dir, "rules")),
    Input = read_json(Dir, "input"),
    Result = liver:validate(Rules, Input, Opts),
    case {lists:suffix("positive", Suite), Result} of
        {true, {ok, Output0}} ->
            Expected = read_json(Dir, "output"),
            Output = to_json_term(Output0),
            case Output == Expected of
                true -> ok;
                false -> format("expected output ~ts, got ~ts", [show(Expected), show(Output)])
            end;
        {true, {error, Errors}} ->
            format("expected no errors, got ~ts", [show(to_json_term(Errors))]);
        {false, {error, Errors0}} ->
            Expected = read_json(Dir, "errors"),
            Errors = to_json_term(Errors0),
            case Errors == Expected of
                true -> ok;
                false -> format("expected errors ~ts, got ~ts", [show(Expected), show(Errors)])
            end;
        {false, {ok, Output}} ->
            format("expected validation to fail, got output ~ts", [show(to_json_term(Output))])
    end.

%% check_schema/2 (liver with LIVR 2.5) returns {error, Reason}; older liver
%% has no build step, so the first validation (of an empty object) must
%% raise. Field errors ({error, #{...}}) are not a schema error.
schema_error(Rules, Opts) ->
    case has_function(liver, check_schema, 2) of
        true ->
            try liver:check_schema(Rules, Opts) of
                ok -> false;
                _ -> true
            catch _:_ -> true
            end;
        false ->
            try liver:validate(Rules, #{}, Opts) of
                {ok, _} -> false;
                {error, Errors} when is_map(Errors) -> false;
                _ -> true
            catch _:_ -> true
            end
    end.

read_json(Dir, Name) ->
    case file:read_file(filename:join(Dir, Name ++ ".json")) of
        {ok, Bin} -> json:decode(Bin);
        {error, enoent} -> undefined
    end.

%% ---- rule conversion (mirrors liver's scripts/livr_import.erl, on maps) ----

is_rule_name(Name) -> lists:member(Name, ?LIVR_RULES).

convert_schema(Map) when is_map(Map) ->
    maps:map(fun(_Field, Rule) -> convert_rule(Rule) end, Map);
convert_schema(Other) ->
    Other.

convert_rule(Name) when is_binary(Name) ->
    case is_rule_name(Name) of
        true -> binary_to_atom(Name, utf8);
        false -> Name
    end;
convert_rule(List) when is_list(List) ->
    [convert_rule(R) || R <- List];
convert_rule(Map) when is_map(Map) ->
    maps:from_list([
        case is_rule_name(K) of
            true -> Rule = binary_to_atom(K, utf8), {Rule, convert_args(Rule, V)};
            false -> {K, V}
        end
        || {K, V} <- maps:to_list(Map)]);
convert_rule(Other) ->
    Other.

convert_args(nested_object, Args) -> convert_schema_args(Args);
convert_args(list_of_objects, Args) -> convert_schema_args(Args);
convert_args(list_of, Args) -> convert_rule(Args);
convert_args('or', Args) when is_list(Args) -> [convert_rule(A) || A <- Args];
convert_args(variable_object, [Selector, Variants]) -> [Selector, convert_variants(Variants)];
convert_args(list_of_different_objects, [Selector, Variants]) -> [Selector, convert_variants(Variants)];
%% LIVR 2.5: when takes a reference and rules (or an object of them), values and keys take rules
convert_args('when', [Ref, Cases]) when is_map(Cases) ->
    [Ref, maps:map(fun(_Value, Rule) -> convert_rule(Rule) end, Cases)];
convert_args('when', [Ref | Rules]) when Rules =/= [] -> [Ref | [convert_rule(R) || R <- Rules]];
convert_args(values, Args) -> convert_rule(Args);
convert_args(keys, Args) -> convert_rule(Args);
convert_args(_Rule, Args) -> Args.

%% aliases.json {"name": ..., "rules": ..., "error": ...}, as liver's livr_import does
convert_alias(Alias) ->
    maps:from_list([case K of
                        <<"name">> -> {name, binary_to_atom(V, utf8)};
                        <<"rules">> -> {rules, convert_rule(V)};
                        _ -> {binary_to_atom(K, utf8), V}
                    end || {K, V} <- maps:to_list(Alias)]).

convert_schema_args([Schema]) when is_map(Schema) -> [convert_schema(Schema)];
convert_schema_args(Schema) -> convert_schema(Schema).

convert_variants(Variants) when is_map(Variants) ->
    maps:map(fun(_Name, Schema) -> convert_schema(Schema) end, Variants);
convert_variants(Other) ->
    Other.

%% ---- output normalisation & formatting ----

to_json_term({Y, M, D}) when is_integer(Y), is_integer(M), is_integer(D) ->
    list_to_binary(io_lib:format("~4..0B-~2..0B-~2..0B", [Y, M, D]));
to_json_term(Map) when is_map(Map) ->
    maps:map(fun(_K, V) -> to_json_term(V) end, Map);
to_json_term(List) when is_list(List) ->
    [to_json_term(V) || V <- List];
to_json_term(Other) ->
    Other.

show(Term) ->
    S = try iolist_to_binary(json:encode(Term))
        catch _:_ -> iolist_to_binary(io_lib:format("~0p", [Term]))
        end,
    case byte_size(S) > 300 of
        true -> <<(binary:part(S, 0, 300))/binary, "..."/utf8>>;
        false -> S
    end.

format(Fmt, Args) ->
    unicode:characters_to_binary(io_lib:format(Fmt, Args)).
