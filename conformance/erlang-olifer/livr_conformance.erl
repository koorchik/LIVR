%% Runs the LIVR test suite against olifer (github.com/Prots/olifer).
%%
%% Data is decoded with jsx (olifer's own dependency) into proplists, exactly as
%% olifer's test/main_SUITE.erl does. olifer's tests compare ordered proplists;
%% JSON objects are unordered, so here both sides are converted to maps before
%% comparing with ==.
%%
%% LIVR 2.5 (test_suite_2.5): a schema_errors case passes when
%% olifer:check_schema/1 rejects the schema (or, without check_schema, when the
%% first validation of an empty object raises). options.json {"now": ...} is
%% the current time: olifer's tests replace olifer_clock with meck; here
%% olifer_clock is replaced by a module compiled for the case, and the original
%% is loaded back after it. Both are feature-detected, so the harness runs
%% with olifer versions without them too.
-module(livr_conformance).

-export([main/0]).

-define(SUITES, ["positive", "negative", "aliases_positive", "aliases_negative"]).
-define(CASE_TIMEOUT, 10000).
%% LIVR 2.5: schemas that must not build
-define(SCHEMA_ERRORS, "schema_errors").

main() ->
    SuiteDir = os:getenv("TEST_SUITE_DIR", "../../test_suite"),
    ok = olifer:start(),
    {ok, Vsn} = application:get_key(olifer, vsn),
    Version = case os:getenv("OLIFER_REV") of
        false -> Vsn;
        Rev -> Vsn ++ "@" ++ Rev
    end,
    Suites = case filelib:is_dir(filename:join(SuiteDir, ?SCHEMA_ERRORS)) of
        true -> ?SUITES ++ [?SCHEMA_ERRORS];
        false -> ?SUITES
    end,
    {Total, Passed, Failures} = lists:foldl(
        fun(Suite, Acc) -> run_suite(SuiteDir, Suite, Acc) end,
        {0, 0, []},
        Suites),
    Result = [
        {<<"id">>, <<"erlang-olifer">>},
        {<<"package">>, <<"olifer">>},
        {<<"version">>, list_to_binary(Version)},
        {<<"source">>, <<"git">>},
        {<<"total">>, Total},
        {<<"passed">>, Passed},
        {<<"failures">>, lists:reverse(Failures)},
        {<<"error">>, null}
    ],
    Out = [jsx:prettify(jsx:encode(Result)), $\n],
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
            Message = with_clock(read_json(CaseDir, "options"),
                                 fun() -> run_isolated(Suite, CaseDir) end),
            case Message of
                ok -> {Total + 1, Passed + 1, Failures};
                _ -> {Total + 1, Passed, [[{<<"case">>, list_to_binary(Suite ++ "/" ++ Name)},
                                           {<<"message">>, Message}] | Failures]}
            end
        end,
        Acc0,
        Cases).

%% Each case runs in its own process: olifer loops forever on some inputs.
run_isolated(Suite, Dir) ->
    Parent = self(),
    {Pid, Ref} = spawn_monitor(fun() ->
        Message = try run_case(Suite, Dir)
                  catch Class:Reason -> format("exception: ~p:~0p", [Class, Reason])
                  end,
        Parent ! {self(), Message}
    end),
    receive
        {Pid, Message} ->
            erlang:demonitor(Ref, [flush]),
            Message;
        {'DOWN', Ref, process, Pid, Reason} ->
            format("crashed: ~0p", [Reason])
    after ?CASE_TIMEOUT ->
        exit(Pid, kill),
        erlang:demonitor(Ref, [flush]),
        format("timeout: no result after ~B seconds", [?CASE_TIMEOUT div 1000])
    end.

%% options.json {"now": "<ISO datetime>"}: the current time of the case.
%% olifer (with LIVR 2.5) reads it from olifer_clock:system_time/0 (seconds);
%% without olifer_clock the case runs with the system time.
with_clock(Options, Fun) when is_list(Options) ->
    case {proplists:get_value(<<"now">>, Options), clock_module()} of
        {Now, {ok, File, Original}} when is_binary(Now) ->
            Seconds = calendar:rfc3339_to_system_time(binary_to_list(Now)),
            load_clock(File, fixed_clock(Seconds)),
            try Fun() after load_clock(File, Original) end;
        _ ->
            Fun()
    end;
with_clock(_Options, Fun) ->
    Fun().

clock_module() ->
    case code:ensure_loaded(olifer_clock) of
        {module, olifer_clock} ->
            case {erlang:function_exported(olifer_clock, system_time, 0),
                  code:get_object_code(olifer_clock)} of
                {true, {olifer_clock, Bin, File}} -> {ok, File, Bin};
                _ -> none
            end;
        _ ->
            none
    end.

fixed_clock(Seconds) ->
    Forms = [{attribute, 1, module, olifer_clock},
             {attribute, 1, export, [{system_time, 0}]},
             {function, 1, system_time, 0, [{clause, 1, [], [], [{integer, 1, Seconds}]}]}],
    {ok, olifer_clock, Bin} = compile:forms(Forms, [binary]),
    Bin.

load_clock(File, Bin) ->
    _ = code:purge(olifer_clock),
    {module, olifer_clock} = code:load_binary(olifer_clock, File, Bin),
    _ = code:soft_purge(olifer_clock),
    ok.

run_case(?SCHEMA_ERRORS, Dir) ->
    case read_json(Dir, "aliases") of
        undefined -> ok;
        Aliases -> ok = olifer:register_aliased_rule(Aliases)
    end,
    case schema_error(read_json(Dir, "rules")) of
        true -> ok;
        false -> <<"expected building the validator to fail">>
    end;
run_case(Suite, Dir) ->
    Rules = read_json(Dir, "rules"),
    Input = read_json(Dir, "input"),
    case read_json(Dir, "aliases") of
        undefined -> ok;
        Aliases -> ok = olifer:register_aliased_rule(Aliases)
    end,
    Result = olifer:validate(Input, Rules),
    case {lists:suffix("positive", Suite), Result} of
        {true, {ok, Output}} ->
            compare("output", read_json(Dir, "output"), Output);
        {true, {errors, Errors}} ->
            format("expected no errors, got ~ts", [show(Errors)]);
        {false, {errors, Errors}} ->
            compare("errors", read_json(Dir, "errors"), Errors);
        {false, {ok, Output}} ->
            format("expected validation to fail, got output ~ts", [show(Output)]);
        {_, Other} ->
            format("unexpected result ~0p", [Other])
    end.

%% check_schema/1 (olifer with LIVR 2.5) returns {error, Message}; older
%% olifer has no build step, so the first validation (of an empty object) must
%% raise. Field errors ({errors, ...}) are not a schema error.
schema_error(Rules) ->
    case erlang:function_exported(olifer, check_schema, 1) of
        true ->
            try olifer:check_schema(Rules) of
                ok -> false;
                _ -> true
            catch _:_ -> true
            end;
        false ->
            try olifer:validate([{}], Rules) of
                {ok, _} -> false;
                {errors, _} -> false;
                _ -> true
            catch _:_ -> true
            end
    end.

compare(What, Expected, Got) ->
    case to_map(Expected) == to_map(Got) of
        true -> ok;
        false -> format("expected ~s ~ts, got ~ts", [What, show(Expected), show(Got)])
    end.

read_json(Dir, Name) ->
    case file:read_file(filename:join(Dir, Name ++ ".json")) of
        {ok, Bin} -> jsx:decode(Bin);
        {error, enoent} -> undefined
    end.

%% jsx proplists ([{}] is an empty object) -> maps, recursively.
to_map([{}]) ->
    #{};
to_map([{K, _} | _] = List) when is_binary(K) ->
    maps:from_list([{Key, to_map(V)} || {Key, V} <- List]);
to_map(List) when is_list(List) ->
    [to_map(V) || V <- List];
to_map(Other) ->
    Other.

show(Term) ->
    S = try jsx:encode(Term)
        catch _:_ -> iolist_to_binary(io_lib:format("~0p", [Term]))
        end,
    case byte_size(S) > 300 of
        true -> <<(binary:part(S, 0, 300))/binary, "...">>;
        false -> S
    end.

format(Fmt, Args) ->
    unicode:characters_to_binary(io_lib:format(Fmt, Args)).
