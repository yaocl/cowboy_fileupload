-module(upload_handler).
-behaviour(cowboy_http_handler).
-export([init/3, handle/2, terminate/3]).

init({_Transport, http}, Req, []) ->
	{ok, Req, {}}.


%%
%% Result =[{[{<<"content-type">>,<<"application/octet-stream">>},
%%		{<<"content-disposition">>,
%%		<<"form-data; name=\"file1\"; filename=\"test.txt\"">>}],
%%		<<"file content\r\n\r\n">>}].
%%

%% Result= [{[{<<"content-disposition">>,<<"form-data; name=\"desc2\"">>}],
%%          <<"desc2">>},
%%         {[{<<"content-type">>,<<"text/plain">>},
%%           {<<"content-disposition">>,
%%            <<"form-data; name=\"file2\"; filename=\"userlist2.txt\"">>}],
%%          <<"filecontent\r\n">>}]

%% Result= [{[{<<"content-disposition">>,<<"form-data; name=\"desc3_1\"">>}],
%%          <<"desc1">>},
%%         {[{<<"content-type">>,<<"text/plain">>},
%%           {<<"content-disposition">>,
%%            <<"form-data; name=\"file3_1\"; filename=\"userlist1.txt\"">>}],
%%         <<"filecontent\r\n">>},
%%         {[{<<"content-disposition">>,<<"form-data; name=\"desc3_2\"">>}],
%%          <<"desc2">>},
%%         {[{<<"content-type">>,<<"text/plain">>},
%%           {<<"content-disposition">>,
%%            <<"form-data; name=\"file3_2\"; filename=\"userlist2.txt\"">>}],
%%          <<"filecontent\r\n">>}]
handle(Req, State) ->
	{Result, Req2} = acc_multipart(Req, []),
	io:format( "Result= ~p~n", [Result] ),
	{ok, Req3} = cowboy_req:reply(200, [
		{<<"content-type">>, <<"text/plain; charset=UTF-8">>}
	], <<"OK">>, Req2),
	%%writeToFile(term_to_binary(Result)),
	{ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
	ok.

%% acc_multipart(Req, Acc) ->
%%	case cowboy_req:part(Req) of
%%		{ok, Headers, Req2} ->
%%			{ok, Body, Req3} = cowboy_req:part_body(Req2),
%%			acc_multipart(Req3, [{Headers, Body}|Acc]);
%%		{done, Req2} ->
%%			{lists:reverse(Acc), Req2}
%%	end.
acc_multipart(Req, Acc) ->
	case cowboy_req:part(Req) of
		{ok, Headers, Req2} ->
			[Req4, Body] = case cow_multipart:form_data(Headers) of
				{data, _FieldName} ->
					{ok, MyBody, Req3} = cowboy_req:part_body(Req2),
					[Req3, MyBody];
				{file, _FieldName, Filename, CType, _CTransferEncoding} ->
					io:format("stream_file filename=~p content_type=~p~n", [Filename, CType]),
					{ok, IoDevice} = file:open( Filename, [raw, write, binary]),
					Req5=stream_file(Req2, IoDevice),
					file:close(IoDevice),
					[Req5, <<"skip printing file content">>]
				end,
			acc_multipart(Req4, [{Headers, Body}|Acc]);
		{done, Req2} ->
			{lists:reverse(Acc), Req2}
	end.

stream_file(Req, IoDevice) ->
	case cowboy_req:part_body(Req) of
		{ok, Body, Req2} ->
			io:format("part_body ok~n", []),
			file:write(IoDevice, Body),
			Req2;
		{more, Body, Req2} ->
			io:format("part_body more~n", []),
			file:write(IoDevice, Body),
			stream_file(Req2, IoDevice)
	end.

%%writeToFile(Result) ->
%%	{ok, IoDevice} = file:open("out.bin", [raw, write, binary]),
%%		file:write(IoDevice, Result),
%%		file:close(IoDevice), ok.
