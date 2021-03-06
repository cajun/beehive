%%%-------------------------------------------------------------------
%%% File    : users_controller.erl
%%% Author  : Ari Lerner
%%% Description : 
%%%
%%% Created :  Sat Nov 28 23:03:51 PST 2009
%%%-------------------------------------------------------------------

-module (users_controller).

-include ("beehive.hrl").
-include ("http.hrl").
-export ([get/2, post/2, put/2, delete/2]).

get(_, _Data) -> 
  All = users:all(),
  {struct, ?BINIFY([{
    "users",
    lists:map(fun(A) ->
      {A#user.email, ?BINIFY([{"level", A#user.level}])}
    end, All)
  }])}.

post([Name, "keys", "new"], Data) ->
  auth_utils:run_if_admin(fun(_) ->
    case proplists:get_value(key, Data) of
      undefined -> error("No key defined");
      Key ->
        case users:find_by_email(Name) of
          User when is_record(User, user) ->
            case users:create(User#user{key = Key}) of
              User when is_record(User, user) -> 
                {struct, ?BINIFY([{"user", User#user.email}, {"key", "added key"}])};
              _Else -> 
                error("There was an error adding bee")
            end;
          _E ->
            error("Error finding user")
        end
      end
    end, Data);
  
post(["new"], Data) ->
  auth_utils:run_if_admin(fun(_) ->
    case users:create(Data) of
      User when is_record(User, user) -> 
        {struct, ?BINIFY([{"user", misc_utils:to_bin(User#user.email)}])};
      E -> 
        io:format("Error: ~p~n", [E]),
        error("There was an error adding bee")
    end
  end, Data);
      
post(Path, _Data) -> 
  io:format("Path: ~p~n", [Path]),
  error("unhandled").
put(_Path, _Data) -> "unhandled".

delete([], Data) ->
  auth_utils:run_if_admin(fun(_) ->
    case proplists:is_defined(email, Data) of
      false -> misc_utils:to_bin("No email given");
      true ->
        Email = proplists:get_value(email, Data),
        users:delete(Email)
    end
  end, Data);
delete(_Path, _Data) -> "unhandled".

error(Msg) ->
  {struct, [{error, misc_utils:to_bin(Msg)}]}.