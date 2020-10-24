%% -------------------------------------------------------------------
%%
%% Copyright (c) 2014 SyncFree Consortium.  All Rights Reserved.
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

-module(lasp_app).

-behaviour(application).

-include("lasp.hrl").

%% Application callbacks
-export([start/2, stop/1]).


%% ===================================================================
%% Application callbacks
%% ===================================================================


%% start non modified version:
start(_StartType, _StartArgs) ->
    case lasp_sup:start_link() of
        {ok, Pid} ->
			launchExperiment(1, 'node1@127.0.0.1', <<"set1">>, state_awset, "state_awset", 10, 10, 100, true),
			%launchExperiment(ExperimentNumber, NodeToJoin, CRDT_Id, CRDT_Type, CRDT_Type_String, TotalNumberOfNodes, SendingSpeed, NumberOfValues, GeneratingUnderPartition)
		    {ok, Pid};

        {error, Reason} ->
            {error, Reason}
    end.
    
%% @doc Stop the lasp application.
stop(_State) ->
    ok.




%Launch an experiment for the current node
% IN:
%Specify a number for the experiment (used to write the result file)
%Specify the node to join to create the cluster
%Specify a CRDT_ID (format as <<"setX">>)
%Specify a CRDT_Type (ex: state_orset)
%Specify the CRDT_Type as a string (ex: "state_orset", it's used to write the result file)
%Specify the Total Number of Nodes taking part of the experiment
%Specify the Sending Speed (as the number of ms between each send, considering one node), 0 means the fastest possible
%Specify the Number of Values each node will have to generate and send on the CRDT
%Specify (with a boolean) if you want the node to join the cluster then generate and send values. Or rather generate and send values on the isolated CRDT (as if it was under partition) then join.
% OUT:
%The node will generate the number of values and send them, trying to achieve the specified Sending Speed.
%It will join the cluster before or after sending the values based on GeneratingUnderPartition
%The time required to generate and send the values, the time required after the generation to reach convergence and all the paramters are written to a file
%The file name will be in the folder /lasp/Memoire/Mesures with the name Exp+ExperimentNumber+_Node+TheActualNodeId
launchExperiment(ExperimentNumber, NodeToJoin, CRDT_Id, CRDT_Type, CRDT_Type_String, TotalNumberOfNodes, SendingSpeed, NumberOfValues, GeneratingUnderPartition) -> 
	%Little setup
	Id = list_to_integer( lists:nth(2,string:split(lists:nth(1,string:split(atom_to_list(erlang:node()),"@")), "e")) ),
	Threshold = (TotalNumberOfNodes*NumberOfValues),
	case (GeneratingUnderPartition) of
	false -> 
		lasp_peer_service:join(NodeToJoin),
		io:format("Clustering is done ~n");
	true ->
		ok
	end,


	lasp:declare({CRDT_Id, CRDT_Type}, CRDT_Type),
	SendingTime = generateValues(CRDT_Id, NumberOfValues, 10*NumberOfValues, SendingSpeed,Id*10*NumberOfValues, CRDT_Type),

	case (GeneratingUnderPartition) of
	true -> 
		lasp_peer_service:join(NodeToJoin),
		io:format("Clustering is done ~n");
	false ->
		ok
	end,

	%Start timer
	InitialTimer = erlang:system_time(1000),	
	lasp:read({CRDT_Id, CRDT_Type}, {cardinality, Threshold}),	
	ConvergedTimer = erlang:system_time(1000),
	%End timer

	%Write to file
	EllapsedTime = ConvergedTimer - InitialTimer,
	io:format("Correct number of values in the set reached! (~p values) ~n ", [Threshold]),
	io:format("It took ~p milliseconds ~n", [EllapsedTime]),
	generateFile(ExperimentNumber, Id, NodeToJoin, CRDT_Type_String, TotalNumberOfNodes, SendingSpeed, NumberOfValues, Threshold, EllapsedTime, GeneratingUnderPartition, SendingTime),
	timer:sleep(1000). %Pause after finished experiment




%Generate the file to save measurements
generateFile (ExperimentNumber, Id, NodeToJoin, CRDT_Type_String, TotalNumberOfNodes, SendingSpeed, NumberOfValues, Threshold, EllapsedTime, GeneratingUnderPartition, SendingTime) ->

	{ok, File} = file:open("Memoire/Mesures/Exp"++integer_to_list(ExperimentNumber)++"_Node"++integer_to_list(Id), [write]),
	case (GeneratingUnderPartition) of
	true ->
		Partition = "true";
	false ->
		Partition = "false"
	end,
	ExperimentName = "Launching " ++integer_to_list(TotalNumberOfNodes) ++ " nodes at the same time, each generating a total of "
							   ++integer_to_list(NumberOfValues)++ " values at the speed of one every "++integer_to_list(SendingSpeed) 
							   ++ " ms (while under partition = " ++ Partition ++ ") " ++" then start timer and wait until all the values converged",
	io:format(File, "~s~n", [ExperimentName]),
	io:format(File, "~s~n", [""]), 
	io:format(File, "~s~n", ["============"]), 
	io:format(File, "~s~n", ["Parameters :"]),
	io:format(File, "~s~n", ["============"]), 
	io:format(File, "~s~n", ["Node Id:"]),
	io:format(File, "~s~n", [integer_to_list(Id)]),
	io:format(File, "~s~n", ["Node to join cluster: "]),
	io:format(File, "~s~n", [NodeToJoin]),
	io:format(File, "~s~n", ["Generating values under partition: "]),
	io:format(File, "~s~n", [GeneratingUnderPartition]),
	io:format(File, "~s~n", ["Type of CRDT: "]),
	io:format(File, "~s~n", [CRDT_Type_String]),
	io:format(File, "~s~n", ["Number of nodes: "]),
	io:format(File, "~s~n", [integer_to_list(TotalNumberOfNodes)]),
	io:format(File, "~s~n", ["Number of values generated by each node: "]),
	io:format(File, "~s~n", [integer_to_list(NumberOfValues)]),
	io:format(File, "~s~n", ["Theoretical time (ms) between each value sending, for each node: "]),
	io:format(File, "~s~n", [integer_to_list(SendingSpeed)]),
	io:format(File, "~s~n", ["Time (ms) required (for this node) to generate and send all the values: "]),
	io:format(File, "~s~n", [integer_to_list(SendingTime)]),
	io:format(File, "~s~n", ["Total final number of values in the CRDT: "]),
	io:format(File, "~s~n", [integer_to_list(Threshold)]),
	io:format(File, "~s~n", ["Ellapsed time (ms) after values generation to get the total " ++ integer_to_list(Threshold) ++ " values:"]),
	io:format(File, "~s~n", [integer_to_list(EllapsedTime)]),
	io:format(File, "~s~n", [""]),
	io:format(File, "~s~n", ["======================================================================================="]),
	io:format(File, "~s~n", ["======================================================================================="]),
	io:format(File, "~s~n", [""]),
	file:close(File).
	

	


%%Generate fake values for crdt
%%Limit is the number of values to generate
%% Maxvalue is the maximum value acceptable
%% Period is the time in ms between each value generation
%% Example: generateValues (10, 100, 1000) will generate a total of 10 values (numbers between 0 and 100) at speed of 1/sec

generateValues(CRDT_Id, Limit, MaxValue, Period, Margin, CRDT_Type) ->
	io:format("Generating ~p values ~n", [Limit]),
	Values = generateValues_helper1([0], Limit, MaxValue, Margin, 1),	
	io:format("Adding these elements ~p ", [Values]),
	io:format("at speed of one every ~p milliseconds ~n", [Period]),
	StartSending = erlang:system_time(1000),
	generateValues_helper2(CRDT_Id, Values, Period, 2, Limit, CRDT_Type), %start counter at 2 to avoid sending the initial 0
	EndSending = erlang:system_time(1000),
	RequiredTimeToSendDatas = EndSending - StartSending,
	RequiredTimeToSendDatas.


%Helper1 to generate values (used to generate them locally)
generateValues_helper1 (Values, Limit, MaxValue, Margin, Counter) ->
	if (Counter =< Limit) -> %+1 because of initial value 0
		NewValue = rand:uniform(MaxValue)+Margin,
		case lists:member(NewValue, Values) of
		true ->
			generateValues_helper1(Values, Limit, MaxValue, Margin, Counter);
		false ->
			NewValues = Values++ [NewValue],
			generateValues_helper1(NewValues, Limit, MaxValue, Margin, Counter+1)
		end;
			
	true -> 
		Values
	end.

%Helper2 to generate values (used to send them)
generateValues_helper2(CRDT_Id, ValuesArray, PeriodMs, Counter, Limit, CRDT_Type) ->
	if (Counter =< Limit+1) ->
		CurrentValue = lists:nth(Counter, ValuesArray),
		lasp:update({CRDT_Id, CRDT_Type}, {add, CurrentValue}, self()),
		timer:sleep(PeriodMs),
		generateValues_helper2(CRDT_Id, ValuesArray, PeriodMs, Counter+1, Limit, CRDT_Type);
	true -> 
	io:format("Finished adding values to CRDT ~n")
	end.


