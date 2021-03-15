%%%-------------------------------------------------------------------
%% @doc arke_cluster public API
%% @end
%%%-------------------------------------------------------------------

-module(arke_cluster_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    arke_cluster_mnesia:ensure_started(),
    arke_cluster_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
