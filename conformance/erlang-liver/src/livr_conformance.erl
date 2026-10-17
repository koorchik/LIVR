%% Runs the LIVR test suite against hex package liver, using its
%% `rule_set => livr_spec' mode.
%%
%% Data is decoded with OTP's json module (maps, binary strings). Rule names
%% are converted to atoms the same way liver's own scripts/livr_import.erl does
%% before liver's tests run. liver returns iso_date values as {Y, M, D}; they
%% are compared in their JSON form ("YYYY-MM-DD"). Values are compared with ==,
%% so 1 == 1.0, but <<"1">> =/= 1.
-module(livr_conformance).

-export([main/0]).

-define(SUITES, ["positive", "negative", "aliases_positive", "aliases_negative"]).

-define(LIVR_RULES, [
    <<"required">>, <<"not_empty">>, <<"not_empty_list">>, <<"any_object">>,
    <<"string">>, <<"eq">>, <<"one_of">>, <<"max_length">>, <<"min_length">>,
    <<"length_between">>, <<"length_equal">>, <<"like">>,
    <<"integer">>, <<"positive_integer">>, <<"decimal">>, <<"positive_decimal">>,
    <<"max_number">>, <<"min_number">>, <<"number_between">>,
    <<"email">>, <<"url">>, <<"iso_date">>, <<"equal_to_field">>,
    <<"nested_object">>, <<"variable_object">>, <<"list_of">>, <<"list_of_objects">>,
    <<"list_of_different_objects">>, <<"or">>,
    <<"trim">>, <<"to_lc">>, <<"to_uc">>, <<"remove">>, <<"leave_only">>, <<"default">>
]).

main() ->
    SuiteDir = os:getenv("TEST_SUITE_DIR", "../../test_suite"),
    ok = application:load(liver),
    {ok, Vsn} = application:get_key(liver, vsn),
    {Total, Passed, Failures} = lists:foldl(
        fun(Suite, Acc) -> run_suite(SuiteDir, Suite, Acc) end,
        {0, 0, []},
        ?SUITES),
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
    Cases = lists:sort([N || N <- Names, hd(N) =/= $.]),
    lists:foldl(
        fun(Name, {Total, Passed, Failures}) ->
            Message = try run_case(Suite, filename:join(Dir, Name))
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

run_case(Suite, Dir) ->
    case read_json(Dir, "aliases") of
        undefined -> run_case(Suite, Dir, read_json(Dir, "rules"), read_json(Dir, "input"));
        _ -> <<"liver has no API for registering aliased rules">>
    end.

run_case(Suite, Dir, Rules0, Input) ->
    Rules = convert_schema(Rules0),
    Result = liver:validate(Rules, Input, #{rule_set => livr_spec}),
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
convert_args(_Rule, Args) -> Args.

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
