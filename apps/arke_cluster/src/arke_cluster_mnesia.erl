-module(arke_cluster_mnesia).

-include("arke_cluster.hrl").

-export([start_new/0, join/1, ensure_started/0]).

-define(TIMEOUT, 3000).

start_new() ->
    mnesia:stop(),
    mnesia:create_schema([node()]),
    mnesia:start().

join(Node) ->
    mnesia:stop(),
    mnesia:delete_schema([node()]),
    mnesia:start(),
    case mnesia:change_config(extra_db_nodes, [Node]) of
        {ok, [Node]} ->
            mnesia:add_table_copy(schema, node(), ram_copies),
            Tables = mnesia:system_info(tables),
            [mnesia:add_table_copy(T, node(), ram_copies) || T <- Tables],
            mnesia:wait_for_tables(Tables, ?TIMEOUT);
        _ ->
            {error}
    end.

ensure_started() ->
    {ok, RawNode} = application:get_env(arke_cluster, nodes),
    Nodes = lists:map(fun(E) -> binary_to_atom(E, utf8) end, re:split(RawNode, ",")),
    case get_acrive_node(Nodes -- [node()]) of
        {ok, Node} ->
            ?INFO("join cluster"),
            join(Node),
            {ok, Node};
        {error, empty} ->
            ?INFO("start new cluster"),
            start_new(),
            {ok, new}
    end.

get_acrive_node([]) ->
    {error, empty};
get_acrive_node([Node | Rest]) ->
    case net_adm:ping(Node) of 
        pong ->
            {ok, Node};
        pang ->
            get_acrive_node(Rest)
    end.
