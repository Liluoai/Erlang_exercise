%%%-------------------------------------------------------------------
%%% @author Liluoai
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. 十二月 2016 17:57
%%%-------------------------------------------------------------------
-module(test_process).
-author("Liluoai").

%% API
-export([single/0, tcpserver/1,tcpclient/1, multi/0]).

single() ->
  Start = erlang:timestamp(),
  Pid = self(),
  loop(fun() -> tcpclient(Pid) end, 10),
  if_finish(9),
  Finish = erlang:timestamp(),
  Cost = (element(1, Finish) - element(1, Start)) * 1000000 + (element(2, Finish) - element(2, Start)) + (element(3, Finish) - element(3, Start)) /1000000,
  io:format("cost:~p", [Cost]).

multi() ->
  Start = erlang:timestamp(),
  Pid = self(),
  loop(fun() -> spawn(test_process, tcpclient, [Pid]) end, 10),
  if_finish(9),
  Finish = erlang:timestamp(),
  Cost = (element(1, Finish) - element(1, Start)) * 1000000 + (element(2, Finish) - element(2, Start)) + (element(3, Finish) - element(3, Start)) /1000000,
  io:format("cost:~p", [Cost]).

loop(F, N) ->
  case N >=2 of
    true ->
      F(),
      loop(F, N-1);
    false ->
      ok
  end.

tcpclient(Pid) ->
  io:format("here"),
  spawn(test_process, tcpserver, [self()]),
  receive
    {response} ->
      Pid!{finish}
  end.


tcpserver(TcpClient_pid) ->
  receive
    wait -> suspend
  after
    1000 -> start
  end,
  TcpClient_pid!{response}.

if_finish(N) ->
  case N >=2 of
    true ->
      receive
        {finish} ->
          if_finish(N-1)
      end;
    false ->
      ok
  end.
  

