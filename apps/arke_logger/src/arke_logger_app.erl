%%%-------------------------------------------------------------------
%% @doc arke_logger public API
%% @end
%%%-------------------------------------------------------------------

-module(arke_logger_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    arke_logger_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
