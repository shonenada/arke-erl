-module(arke_ws_proxy).

-export([init/2, terminate/3]).
-export([websocket_init/1, websocket_handle/2, websocket_info/2]).

-record(state, {
          service :: binary(),
          session_pid :: pid()
         }).

init(Req, _Opts) ->
    {cowboy_websocket, Req,
     #state{
        service = cowboy_req:binding(service, Req)
       }}.

websocket_init(_State) ->
    process_flag(trap_exit, true),
    {ok, _State}.

websocket_handle({text, Data} = Frame, _State) ->
    io:format("~p", [Data]),
    {ok, _State}.

websocket_info({'DOWN', _, process, Pid, _}, _State) ->
    {stop, _State}.

terminate(Reason, _Req, _State) ->
    io:format("~s", Reason),
    ok.
