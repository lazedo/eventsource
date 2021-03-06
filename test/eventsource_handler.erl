%% Reuse at will.

-module(eventsource_handler).

-behaviour(cowboy_loop_handler).

-export([init/3, info/3, terminate/3]).


init({_Transport, http}, Req, Messages) ->
	{ok, Req2} = eventsource:init(Req),
	[self() ! Msg || Msg <- Messages],
	{loop, Req2, undefined}.

info({send, Msg}, Req, State) ->
	eventsource:send(Msg, Req),
	{loop, Req, State};
info(last_event_id, Req, State) ->
	{LastEventId, Req2} = eventsource:last_event_id(Req),
	Event = {event, [{data, LastEventId}]},
	ok = eventsource:send(Event, Req2),
	{loop, Req2, State};
info(quit, Req, State) ->
	{ok, Req, State}.

terminate(_, _, _) ->
	ok.
