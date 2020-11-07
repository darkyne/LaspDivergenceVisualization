%% -------------------------------------------------------------------
%%
%% Copyright (c) 2015 Helium Systems, Inc.  All Rights Reserved.
%% Copyright (c) 2016 Christopher Meiklejohn.  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------

-module(partisan_peer_service_console).

-export([members/1]).

-include("partisan.hrl").

members([]) ->
    Manager = partisan_peer_service:manager(),
    {ok, Members} = Manager:members(),
    print_members(Members).

print_members(Members) ->
    _ = io:format("~29..=s Cluster Membership ~30..=s~n", ["", ""]),
    _ = io:format("Connected Nodes:~n~n", []),
    _ = [io:format("~p~n", [Node]) || Node <- Members],
    _ = io:format("~79..=s~n", [""]),
    ok.
