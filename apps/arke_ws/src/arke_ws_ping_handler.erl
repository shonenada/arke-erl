-module(arke_ws_ping_handler).

-export([init/2]).

init(Req, Opts) ->
    StatusCode = 200,
    Headers = #{<<"Content-Type">> => <<"plain/text">>},
    Body = <<"pong">>,
    {ok, cowboy_req:reply(StatusCode, Headers, Body, Req), Opts}.
