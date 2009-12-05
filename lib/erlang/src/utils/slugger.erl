%%%-------------------------------------------------------------------
%%% File    : slugger.erl
%%% Author  : Ari Lerner
%%% Description : 
%%%
%%% Created :  Fri Dec  4 17:15:58 PST 2009
%%%-------------------------------------------------------------------

-module (slugger).
-export ([
  send/3,
  send/2,
  get/3,
  save/2
]).

% Send every node the file
send(Filename, As) ->
  case rpc:multicall(code, is_loaded, [?MODULE]) of
    {file, _} -> ok;
    _ ->
      {Mod, Bin, File} = code:get_object_code(?MODULE), 
      rpc:multicall(code, load_binary, [Mod, File, Bin])
  end,
  {ok, B} = prim_file:read_file(Filename),
  rpc:multicall(?MODULE, save, [B, As]).

% Send the filename to the node as
send(Node, Filename, As) ->
  case rpc:call(Node, code, is_loaded, [?MODULE]) of
    {file, _} -> ok;
    _ ->
      {Mod, Bin, File} = code:get_object_code(?MODULE), 
      rpc:call(Node, code, load_binary, [Mod, File, Bin])
  end,
  {ok, B} = prim_file:read_file(Filename),
  rpc:call(Node, ?MODULE, save, [B, As]).

get(Node, Filename, To) ->
  rpc:call(Node, ?MODULE, send, [node(), Filename, To]).

% Save the file contents to
save(Contents, To) ->
  FullFilePath = case filelib:is_dir(To) of
    true -> ok;
    false ->
      FullPath = filename:join([filename:absname(""), To]),
      filelib:ensure_dir(FullPath),
      FullPath
  end,
  prim_file:write_file(FullFilePath, Contents).