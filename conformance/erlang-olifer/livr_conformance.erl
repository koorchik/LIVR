%% Runs the LIVR test suite against olifer (github.com/Prots/olifer).
%%
%% Data is decoded with jsx (olifer's own dependency) into proplists, exactly as
%% olifer's test/main_SUITE.erl does. olifer's tests compare ordered proplists;
%% JSON objects are unordered, so here both sides are converted to maps before
%% comparing with ==.
-module(livr_conformance).

-export([main/0]).

-define(SUITES, ["positive", "negative", "aliases_positive", "aliases_negative"]).
-define(CASE_TIMEOUT, 10000).

main() ->
    SuiteDir = os:getenv("TEST_SUITE_DIR", "../../test_suite"),
    ok = olifer:start(),
    {ok, Vsn} = application:get_key(olifer, vsn),
    Version = case os:getenv("OLIFER_REV") of
        false -> Vsn;
        Rev -> Vsn ++ "@" ++ Rev
    end,
    {Total, Passed, Failures} = lists:foldl(
        fun(Suite, Acc) -> run_suite(SuiteDir, Suite, Acc) end,
        {0, 0, []},
        ?SUITES),
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
    Cases = lists:sort([N || N <- Names, hd(N) =/= $.]),
    lists:foldl(
        fun(Name, {Total, Passed, Failures}) ->
            Message = run_isolated(Suite, filename:join(Dir, Name)),
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
