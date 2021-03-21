-module(arke_ws_proxy).

-export([init/2, terminate/3]).
-export([websocket_init/1, websocket_handle/2, websocket_info/2]).

-record(state, {
          service :: binary(),
          session_pid :: pid(),
          upstream :: tuple()
         }).

init(Req, Opts) ->
    Service = cowboy_req:binding(service, Req),
    case find_upstream(Service) of
        {ok, Upstream} ->
            {cowboy_websocket, Req,
             #state{
                service = Service,
                upstream = Upstream
           }};
        {error, not_found} ->
            StatusCode = 404,
            Headers = #{<<"Content-Type">> => <<"plain/text">>},
            Body = <<"Not Found">>,
            {ok, cowboy_req:reply(StatusCode, Headers, Body, Req), Opts}
    end.

websocket_init(_State) ->
    process_flag(trap_exit, true),
    {ok, _State}.

websocket_handle({text, Data} = _Frame, #state{upstream = Upstream} = State) ->
    {Host, Port} = Upstream,
    {ok, Socket} = gen_tcp:connect(Host, Port, [{active, false}]),
    ok = gen_tcp:send(Socket, <<Data/binary, <<"\r\n\r\n">>/binary>>),  %% FIXME
    {ok, B} =  do_recv(Socket, []),
    self() ! {text_data, B},
    gen_tcp:close(Socket),
    {ok, State};
websocket_handle(_Frame, State) ->
    {ok, State}.

websocket_info({text_data, Data}, State) ->
    io:format("text: ~p~n", [Data]),
    {reply, {text, Data}, State};
websocket_info({tcp, _From, Data}, State) ->
    io:format("tcp: ~p~p~n", [_From, Data]),
    {reply, {text, Data}, State};
websocket_info({'DOWN', _, process, _Pid, _}, _State) ->
    {stop, _State};
websocket_info(_Raw, State) ->
    io:format("info: ~p~n", [_Raw]),
    {ok, State}.

terminate(Reason, _Req, _State) ->
    io:format("~p~n", [Reason]),
    ok.

find_upstream(Stream) ->
    case Stream of
        <<"echo">> ->
            {ok, {"localhost", 1234}};
         _ ->
            {error, not_found}
    end.

do_recv(Sock, Bs) ->
    case gen_tcp:recv(Sock, 0) of
        {ok, B} ->
            do_recv(Sock, [Bs, B]);
        {error, closed} ->
            {ok, list_to_binary(Bs)}
    end.
