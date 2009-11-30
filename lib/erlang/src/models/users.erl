%%%-------------------------------------------------------------------
%%% File    : users.erl
%%% Author  : Ari Lerner
%%% Description : 
%%%
%%% Created :  Sat Nov 28 21:28:31 PST 2009
%%%-------------------------------------------------------------------

-module (users).

-include ("beehive.hrl").
-include_lib("stdlib/include/qlc.hrl").

-export ([
  add_root_user/0,
  find_by_email/1,
  find_all_by_email/1,
  all/0,
  exist/1,
  create/1,
  update/1,
  delete/1, 
  create_new_token_for/1, create_new_token_for/2,
  new/1
]).

find_by_email(Hostemail) ->
  case find_all_by_email(Hostemail) of
    [B|_] -> B;
    _ -> []
  end.

find_all_by_email(Name) -> 
  db:read({user, Name}).

% Does this user exist?
exist(Name) ->
  case find_by_email(Name) of
    [] -> false;
    _ -> true
  end.

% Insert a new user
create(User) when is_record(User, user) ->
  case exist(User#user.email) of
    true -> ?NOTIFY({user, updated, User});
    false -> ?NOTIFY({user, created, User})
  end,
  db:write(User),
  User;
create(NewProps) ->
  create(new(NewProps)).

update(NewProps) ->
  create(new(NewProps)).

delete(User) when is_record(User, user) -> db:delete_object(User);
delete(Name) ->
  db:delete_object(#user{email=Name, _='_'}).

all() ->
  db:find(qlc:q([ B || B <- mnesia:table(user) ])).

create_new_token_for(User) when is_record(User, user) ->
  NewToken = md5:hex(lists:flatten([
    User#user.email,
    misc_utils:to_list(date_util:now_to_seconds())
  ])),
  create(User#user{token = NewToken}).

create_new_token_for(Email, Password) ->
  case find_by_email(Email) of
    [] -> error;
    User ->
      case User#user.password =:= Password of
        false -> 
          User#user{token = "error"};
        true ->
          create_new_token_for(User)
      end
  end.
  

% Add the initial root user
% email: root@getbeehive.com
% password: 098f6bcd4621d373cade4e832627b4f6
add_root_user() ->
  create(new([
    {email, "root@getbeehive.com"},
    {password, md5:hex("test")}
  ])).

new(NewProps) ->
  PropList = ?rec_info(user, #user{}),
  FilteredProplist1 = misc_utils:filter_proplist(PropList, NewProps, []),
  FilteredProplist2 = misc_utils:new_or_previous_value(FilteredProplist1, PropList, []),
  FilteredProplist = validate_user_proplists(FilteredProplist2),
  list_to_tuple([user|[proplists:get_value(X, FilteredProplist) || X <- record_info(fields, user)]]).

validate_user_proplists(PropList) ->
  lists:map(fun({Key, Val}) ->
    case Key of
      updated_at -> {Key, date_util:now_to_seconds()};
      _ -> {Key, Val}
    end
  end, PropList).