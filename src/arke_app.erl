%%%-------------------------------------------------------------------
%% @doc arke public API
%% @end
%%%-------------------------------------------------------------------

-module(arke_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    arke_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
