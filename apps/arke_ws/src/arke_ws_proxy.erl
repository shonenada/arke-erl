-module(arke_ws_proxy).

-export([init/2, terminate/3]).
-export([websocket_init/1, websocket_handle/2, websocket_info/2]).

-record(state, {
          service :: binary(),
          session_pid :: pid(),
          upstream :: tuple()
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

websocket_handle({text, Data} = _Frame, #state{upstream = Upstream} = State) ->
    {Host, Port} = Upstream,
    {ok, Socket} = gen_tcp:connect(Host, Port, [binary, {mode, binary}, {packet, 0} ]),
    ok = gen_tcp:send(Socket, <<Data/binary, <<"\n">>/binary>>),
    do_recv(Socket),
    {ok, State}.

websocket_info({data, Data}, State) ->
    {reply, Data, State};
websocket_info({'DOWN', _, process, _Pid, _}, _State) ->
    {stop, _State}.

terminate(Reason, _Req, _State) ->
    io:format("~p~n", [Reason]),
    ok.

find_upstream(Stream) ->
    case Stream of
        <<"nginx">> ->
            {ok, {"localhost", 1234}};
         _ ->
            {error, not_found}
    end.

do_recv(Socket) ->
    receive
        {tcp, Socket, Data} ->
            gen_server:cast(self(), {data, Data}),
            gen_tcp:close(Socket)
    end.
