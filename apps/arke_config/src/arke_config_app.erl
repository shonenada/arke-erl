%%%-------------------------------------------------------------------
%% @doc arke_config public API
%% @end
%%%-------------------------------------------------------------------

-module(arke_config_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    {ok, Sup} = arke_config_sup:start_link(),
    setup_configs(),
    {ok, Sup}.

stop(_State) ->
    ok.

%% internal functions

setup_configs() ->
    stillir:set_config(arke_cluster, [
                                      {nodes, "ARKE_NODES", [{default, ""}]}
                       ]).
