%%%-------------------------------------------------------------------
%%% File    : home_controller.erl
%%% Author  : Ari Lerner
%%% Description : 
%%%
%%% Created :  Fri Nov 13 11:43:49 PST 2009
%%%-------------------------------------------------------------------

-module (home_controller).
-include ("http.hrl").
-export ([get/2, post/2, put/2, delete/2]).

get(_, _Data) -> 
  ?JSON_MSG("beehive", ["apps", "nodes", "bees", "stats", "users"]).

post(_Path, _Data) -> error("unhandled").
put(_Path, _Data) -> error("unhandled").
delete(_Path, _Data) -> error("unhandled").

error(Msg) ->
  {struct, [{error, misc_utils:to_bin(Msg)}]}.