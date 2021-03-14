%%%-------------------------------------------------------------------
%% @doc arke_ws public API
%% @end
%%%-------------------------------------------------------------------

-module(arke_ws_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    {ok, Sup} = arke_ws_sup:start_link(),
    start_server(),
    {ok, Sup}.

stop(_State) ->
    ok.

%% internal functions

start_server() ->
    Port = 21314,
    Dispatch = cowboy_router:compile(
                 [{'_',
                   [{"/ping", arke_ws_ping_handler, #{}}]
                  }]),
    {ok, _} = cowboy:start_clear(http, [{num_acceptors, 10}, {port, Port}],
                                 #{env => #{dispatch => Dispatch}}).
