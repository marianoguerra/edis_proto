%%%-------------------------------------------------------------------
%%% @author Fernando Benavides <fernando.benavides@inakanetworks.com>
%%% @author Chad DePue <chad@inakanetworks.com>
%%% @copyright (C) 2011 InakaLabs SRL
%%% @doc Edis client supervisor
%%% @end
%%%-------------------------------------------------------------------
-module(edis_client_sup).
-author('Fernando Benavides <fernando.benavides@inakanetworks.com>').
-author('Chad DePue <chad@inakanetworks.com>').

-define(MANAGERS, 1). %%NOTE: Pump it up to reduce message_queue_lens on massive client initialization

-behaviour(supervisor).

-export([start_link/1, start_client/0, init/1, count_clients/0, reload/0]).

%% ====================================================================
%% External functions
%% ====================================================================
%% @doc  Starts the supervisor process
-spec start_link(map()) -> ignore | {error, term()} | {ok, pid()}.
start_link(Opts) ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, Opts).

%% @doc  Starts a new client process
-spec start_client() -> {ok, pid() | undefined} | {error, term()}.
start_client() ->
  _ = random:seed(erlang:now()),
  Manager =
    list_to_atom("edis-client-mgr-" ++ integer_to_list(random:uniform(?MANAGERS))),
  supervisor:start_child(Manager, []).

%% @doc  Reloads configuration. Restarts the managers
-spec reload() -> ok.
reload() ->
  true = exit(erlang:whereis(?MODULE), kill),
  ok.

%% @doc  Returns the count of reigstered clients under the supervision of this process
-spec count_clients() -> non_neg_integer().
count_clients() ->
  lists:sum(
    lists:map(
      fun(I) ->
              proplists:get_value(
                active,
                supervisor:count_children(
                  list_to_atom("edis-client-mgr-" ++ integer_to_list(I))),
                0)
      end, lists:seq(1, ?MANAGERS))).

%% ====================================================================
%% Server functions
%% ====================================================================
%% @hidden
-spec init(map()) -> {ok, {{one_for_one, 5, 10}, [supervisor:child_spec()]}}.
init(Opts) ->
  logger:info("Client supervisor initialized (~p managers)~n", [?MANAGERS]),
  Managers =
    [{name(I), {edis_client_mgr, start_link, [Opts#{name => name(I)}]},
      permanent, brutal_kill, supervisor, [edis_client_mgr]}
     || I <- lists:seq(1, ?MANAGERS)],
  {ok, {{one_for_one, length(Managers), 1}, Managers}}.

name(I) ->
    list_to_atom("edis-client-mgr-" ++ integer_to_list(I)).
