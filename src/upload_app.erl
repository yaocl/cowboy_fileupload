-module(upload_app).
-behaviour(application).

-export([start/2, stop/1]).

start(_Type, _Args) ->
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/", cowboy_static, {priv_file, upload, "index.html"}},
			{"/upload", upload_handler, []}
		]}
	]),
	{ok, _} = cowboy:start_http(http, 100, [{port, 8000}], [
		{env, [{dispatch, Dispatch}]}
	]),
	upload_sup:start_link().

stop(_State) ->
	ok.
