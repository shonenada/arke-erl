-module(arke_ws_proxy).

-export([init/2, terminate/3]).
-export([websocket_init/1, websocket_handle/2, websocket_info/2]).

-record(state, {
          service :: binary(),
          session_pid :: pid(),
          upstream :: string()
         }).

init(Req, _Opts) ->
    Service = cowboy_req:binding(service, Req),
    {ok, Upstream} = find_upstream(Service),
    {cowboy_websocket, Req,
     #state{
        service = Service,
        upstream = Upstream
       }}.

websocket_init(_State) ->
    process_flag(trap_exit, true),
    {ok, _State}.

websocket_handle({text, Data} = _Frame, _State) ->
    io:format("~p", [Data]),
    {ok, _State}.

websocket_info({'DOWN', _, process, _Pid, _}, _State) ->
    {stop, _State}.

terminate(Reason, _Req, _State) ->
    io:format("~s", Reason),
    ok.

find_upstream(Stream) ->
    case Stream of
        <<"nginx">> ->
            {ok, "http://127.0.0.1:80"};
         _ ->
            {error, not_found}
    end.
