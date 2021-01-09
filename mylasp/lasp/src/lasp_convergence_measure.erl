
-module(lasp_convergence_measure).
-author("Gregory Creupelandt <gregory.creupelandt@student.uclouvain.be>").

-export([launchExperimentAdding/8,
         launchExperimentRemoving/8,
		 simpleAddition/0,
		 messageReceived/0,
		 created/0,
		 launchExperimentDynamic/4,
		 launchContinuousMeasures/3,
		 readThresholdMaxDuration/3,
		 readThresholdMaxDurationSilent/3,
		 getSystemConvergenceInfos/0,
		 getSystemConvergenceTime/0,
		 getSystemRoundTrip/0,
		 getSystemWorstNodeId/0,
		 getSystemNetworkUsage/0,
		 getIndividualConvergenceTimes/0,
		 getConvergenceTime/1,
		 addition_awset_time/0,
		 addition_orset_time/0,
		 addition_gcount_time/0,
		 continuousMeasurementLoop/4,
		 getStateInterval/0,
		 getInternalStateInterval/1,
		 setStateInterval/1,
		 partitionHelper/0
         ]).



%% ===================================================================
%% launchExperimentAdding:
%% ===================================================================


%Launch an "adding" experiment for the current node
% IN:
%Specify a number for the experiment (used to write the result file)
%Specify the node to join to create the cluster
%Specify a CRDT_ID (format as <<"setX">>)
%Specify the Total Number of Nodes taking part of the experiment
%Specify the Sending Speed (as the number of ms between each send, considering one node), 0 means the fastest possible
%Specify the Number of Values each node will have to generate and send on the CRDT
%Specify (with a boolean) if you want the node to join the cluster then generate and send values. Or rather generate 
%and send values on the isolated CRDT (as if it was under partition) then join.
%Specify (with a boolean) if you want all the values to be added at once or gradually via All_At_Once. If set to false,
% it will use SendingSpeed to send gradually the values.
% OUT:
%The node will generate the number of values and send them, trying to achieve the specified Sending Speed.
%It will join the cluster before or after sending the values based on GeneratingUnderPartition
%The time required to generate and send the values, the time required after the generation to reach convergence and all
% the paramters are written to a file
%The file name will be in the folder /lasp/Memoire/Mesures with the name Exp+ExperimentNumber+_Node+NodeId

launchExperimentAdding(ExperimentNumber, NodeToJoin, CRDT_Id, TotalNumberOfNodes, All_At_Once, SendingSpeed,
 NumberOfValues, GeneratingUnderPartition) -> 
	%---------------------------------------	
	%Little setup
	%---------------------------------------
	ExperimentStartTime = erlang:system_time(1000),
	timer:sleep(1000), %start with a little sleep to allow NodeToJoin to be booted in case it is a bit slower than this node
	Id = list_to_integer( lists:nth(2,string:split(lists:nth(1,string:split(atom_to_list(erlang:node()),"@")), "e")) ),
	NetworkPath="Memoire/Mesures/Network/Node"++integer_to_list(Id)++".txt",
	NetworkPath2="Memoire/Mesures/Network/Node"++integer_to_list(Id)++"_Final.txt",
	file:write_file(NetworkPath,"NEW \n",[append]),
	CRDT_Type = state_awset,
	CRDT_Type_String = "state_awset",
	io:format("EXPERIMENT ~p ", [ExperimentNumber]),
	io:format("Node ~p (Adding elements) ~n", [Id]),
	Threshold = (TotalNumberOfNodes*NumberOfValues),
	
	%---------------------------------------	
	%Join cluster before adding values
	%---------------------------------------
	case {GeneratingUnderPartition, erlang:node()==NodeToJoin} of
	{false, false} -> 
		lasp_peer_service:join(NodeToJoin),
		io:format("Clustering is done ~n");
	{true, false} ->
		ok;
	{_,true} -> 
		lasp:declare({CRDT_Id, CRDT_Type}, CRDT_Type)
	end,

	%---------------------------------------	
	%Generate Values
	%---------------------------------------	
	StartSending = erlang:system_time(1000),
	lasp:declare({CRDT_Id, CRDT_Type}, CRDT_Type),
	generateValues(Id, CRDT_Id, CRDT_Type, NumberOfValues, SendingSpeed, All_At_Once),
	Initial_CRDT_Size = erts_debug:flat_size(  lasp:query({CRDT_Id, CRDT_Type})  ),
	io:format("Initial CRDT size: ~p (words) ~n", [Initial_CRDT_Size]),
	EndSending = erlang:system_time(1000),
	SendingTime = EndSending - StartSending,
	%---------------------------------------	
	%Or Join cluster after adding values
	%---------------------------------------
	case {GeneratingUnderPartition, erlang:node()==NodeToJoin} of
	{true, false} -> 
		lasp_peer_service:join(NodeToJoin),
		io:format("Clustering is done ~n");
	{false, false} ->
		ok;
	{_,true} -> ok
	end,

	%---------------------------------------	
	%Start Timer for convergence
	%---------------------------------------
	io:format("Waiting for convergence... ~n"),
	InitialTimer = erlang:system_time(1000),	
	lasp:read({CRDT_Id, CRDT_Type}, {cardinality, Threshold}),	
	ConvergedTimer = erlang:system_time(1000),
	file:copy(NetworkPath, NetworkPath2),
	
	Final_CRDT_Size = erts_debug:flat_size(  lasp:query({CRDT_Id, CRDT_Type})  ),
	io:format("Final CRDT size: ~p (words) ~n", [Final_CRDT_Size]),
	%---------------------------------------	
	%End Timer for convergence
	%---------------------------------------

	%---------------------------------------	
	%Write to file
	%---------------------------------------
	EllapsedTime = ConvergedTimer - InitialTimer,
	io:format("Correct number of elements in the set reached! (~p elements) ~n", [Threshold]),
	io:format("Convergence took ~p milliseconds ~n", [EllapsedTime]),
	io:format("Waiting experiment to finish on every node..."),
	lasp:update({<<"done">>, state_awset}, {add, Id}, self()), %Mark that I finished
	lasp:read({<<"done">>, state_awset}, {cardinality, TotalNumberOfNodes}), %Wait everyone finished
	io:format("OK! Writting output file ~n"),
	ExperimentEndTime = erlang:system_time(1000),
	TotalExperimentTime = ExperimentEndTime - ExperimentStartTime,
	io:format("Total experiment duration : ~p ~n", [TotalExperimentTime]),
	generateFileAdd(ExperimentNumber, Id, NodeToJoin, CRDT_Type_String, TotalNumberOfNodes, SendingSpeed,	NumberOfValues,
	Threshold, EllapsedTime, GeneratingUnderPartition, SendingTime, All_At_Once, Initial_CRDT_Size, Final_CRDT_Size),
	io:format("Done. ~n"),
	io:format("~n"),
	file:delete(NetworkPath),
	timer:sleep(15000), %wait before stopping.
	partisan_peer_service:stop().





%% ===================================================================
%% Helpers for LaunchExperimentAdding
%% ===================================================================


%Generate the file to save measurements
generateFileAdd (ExperimentNumber, Id, NodeToJoin, CRDT_Type_String, TotalNumberOfNodes, SendingSpeed, NumberOfValues,
 Threshold, EllapsedTime, GeneratingUnderPartition, SendingTime, All_At_Once,Initial_CRDT_Size, Final_CRDT_Size) ->
	UniqueValue = integer_to_list(erlang:system_time(1000)),
	Path = "Memoire/Mesures/Exp"++integer_to_list(ExperimentNumber)++"/Node"++integer_to_list(Id)++"_"++UniqueValue++".txt",
	{ok, File} = file:open(Path, [write]),
	case (GeneratingUnderPartition) of
	true ->
		Partition = "true";
	false ->
		Partition = "false"
	end,
	ExperimentName = "Launching " ++integer_to_list(TotalNumberOfNodes) ++ " nodes at the same time, each generating a total of "
							   ++integer_to_list(NumberOfValues)++  " elements (while under partition = " ++ Partition ++ ") " 
								 ++" then start timer and wait until all the elements converged",
	io:format(File, "~s~n", [ExperimentName]),
	io:format(File, "~s~n", [""]), 
	io:format(File, "~s~n", ["============"]), 
	io:format(File, "~s~n", ["Parameters :"]),
	io:format(File, "~s~n", ["============"]), 
	io:format(File, "~s~n", ["Node Id:"]),
	io:format(File, "~s~n", [integer_to_list(Id)]), %Line7
	io:format(File, "~s~n", ["Node to join cluster: "]),
	io:format(File, "~s~n", [NodeToJoin]), %Line9
	io:format(File, "~s~n", ["Generating elements under partition: "]),
	io:format(File, "~s~n", [GeneratingUnderPartition]), %Line11
	io:format(File, "~s~n", ["Type of CRDT: "]),
	io:format(File, "~s~n", [CRDT_Type_String]), %Line13
	io:format(File, "~s~n", ["Number of nodes: "]),
	io:format(File, "~s~n", [integer_to_list(TotalNumberOfNodes)]), %Line15
	io:format(File, "~s~n", ["Number of elements generated by each node: "]),
	io:format(File, "~s~n", [integer_to_list(NumberOfValues)]), %Line17
	io:format(File, "~s~n", ["Sending all at once: "]),
	io:format(File, "~s~n", [All_At_Once]),
	io:format(File, "~s~n", ["Initial number of elements before adding:"]),
	io:format(File, "~s~n", ["0"]),
	io:format(File, "~s~n", ["Theoretical time (ms) between each element sending, for each node, valuable only if not sending all at once: "]),
	io:format(File, "~s~n", [integer_to_list(SendingSpeed)]),
	io:format(File, "~s~n", ["Time (ms) required (for this node) to generate and send all the elements: "]),
	io:format(File, "~s~n", [integer_to_list(SendingTime)]),
	io:format(File, "~s~n", ["Initial size of the CRDT (in term of words) : "]),
	io:format(File, "~s~n", [integer_to_list(Initial_CRDT_Size)]),
	io:format(File, "~s~n", ["Total final number of elements in the CRDT: "]),
	io:format(File, "~s~n", [integer_to_list(Threshold)]),
	io:format(File, "~s~n", ["Final size of the CRDT (in term of words) : "]),
	io:format(File, "~s~n", [integer_to_list(Final_CRDT_Size)]),
	io:format(File, "~s~n", ["Ellapsed time (ms) after elements generation to get the total " ++ integer_to_list(Threshold) ++ " elements:"]),
	io:format(File, "~s~n", [integer_to_list(EllapsedTime)]),


	%Network measure file
	NetworkPath2="Memoire/Mesures/Network/Node"++integer_to_list(Id)++"_Final.txt",
	ReceivedMessages = count_line(NetworkPath2)-1, %-1 because of the initial "NEW"
	io:format("number of received messages ~p ~n", [ReceivedMessages]),
	io:format(File, "~s~n", ["Number of message received before convergence : "]),
	io:format(File, "~s~n", [integer_to_list(ReceivedMessages)]),
	io:format(File, "~s~n", ["Number of message received per second : "]),
	Messages_speed = io_lib:format("~.3f",[((ReceivedMessages*1000)/EllapsedTime)]),
	io:format(File, "~s~n", [Messages_speed]),
	io:format(File, "~s~n", ["======================================================================================="]),
	io:format(File, "~s~n", ["======================================================================================="]),
	io:format(File, "~s~n", [""]),
	file:close(File),
	file:delete(NetworkPath2).
	

	


%%Generate values for crdt
%%Limit is the number of values to generate
%% Maxvalue is the maximum value acceptable
%% Period is the time in ms between each value generation
%% Example: generateValues (10, 100, 1000) will generate a total of 10 values (numbers between 0 and 100) at speed of 1/sec

generateValues(Id, CRDT_Id, CRDT_Type, NumberOfValues, Period, All_At_Once) ->
	io:format("Generating ~p values ~n", [NumberOfValues]),

	Values = lists:seq( (Id-1)*NumberOfValues , (Id*NumberOfValues)-1 ),	
	case (All_At_Once) of
	false ->
		io:format("Adding the ~p generated elements, ", [NumberOfValues]),
		io:format("at speed of one every ~p milliseconds ~n", [Period]);
	true ->
		io:format("Adding the ~p generated elements, ", [NumberOfValues]),
		io:format("all at once ~n")
	end,
	generateValues_helper2(CRDT_Id, Values, Period, 1, NumberOfValues, CRDT_Type, All_At_Once). 
	%start counter at 2 to avoid sending the initial 0
	


%Helper2 to generate values (used to send them)
generateValues_helper2(CRDT_Id, ValuesArray, PeriodMs, Counter, NumberOfValues, CRDT_Type, All_At_Once) ->
	case (All_At_Once) of
	true -> 
		lasp:update({CRDT_Id, CRDT_Type}, {add_all, ValuesArray}, self());
	false ->
		if (Counter =< NumberOfValues) ->
			CurrentValue = lists:nth(Counter, ValuesArray),
			lasp:update({CRDT_Id, CRDT_Type}, {add, CurrentValue}, self()),
			timer:sleep(PeriodMs),
			generateValues_helper2(CRDT_Id, ValuesArray, PeriodMs, Counter+1, NumberOfValues, CRDT_Type, All_At_Once);
		true -> 
			io:format("Finished adding values to CRDT ~n")
		end
	end.



%% ===================================================================
%% launchExperimentRemoving:
%% ===================================================================

launchExperimentRemoving(ExperimentNumber, NodeToJoin, CRDT_Id, TotalNumberOfNodes, All_At_Once, RemovingSpeed, 
NumberOfValues, RemovingUnderPartition) -> 
	%---------------------------------------	
	%Little setup (putting initial elements)
	%---------------------------------------
	ExperimentStartTime = erlang:system_time(1000),
	timer:sleep(1000), %start with a little sleep to allow NodeToJoin to be booted in case it is a bit slower than this node
	Id = list_to_integer( lists:nth(2,string:split(lists:nth(1,string:split(atom_to_list(erlang:node()),"@")), "e")) ),
	NetworkPath="Memoire/Mesures/Network/Node"++integer_to_list(Id)++".txt",
	NetworkPath2="Memoire/Mesures/Network/Node"++integer_to_list(Id)++"_Final.txt",
	file:write_file(NetworkPath,"NEW \n",[append]),
	CRDT_Type = state_awset,
	CRDT_Type_String = "state_awset",
	case (Id) of
	1 -> lasp:declare({CRDT_Id, CRDT_Type}, CRDT_Type);
	_ -> ok
	end,
	timer:sleep(1000),
	io:format("EXPERIMENT ~p ", [ExperimentNumber]),
	io:format("Node ~p (Removing elements) ~n", [Id]),
	Threshold = 0,	
	ValuesArray = lists:seq(0, ((TotalNumberOfNodes*NumberOfValues)-1) ),  
	% Valeurs de 0 à XX9 dont les indices vont de 1 à 1XX
	lasp:update({CRDT_Id, CRDT_Type}, {add_all, ValuesArray}, <<04760>>), 
	%They consider all the initial values are from the same actor, that way they start with exactly the same CRDT
	io:format("Initial ~p values are set ~n", [TotalNumberOfNodes*NumberOfValues]),
	Initial_CRDT_Size = erts_debug:flat_size(  lasp:query({CRDT_Id, CRDT_Type})  ),
	io:format("Initial CRDT size: ~p (words) ~n", [Initial_CRDT_Size]),

	case {RemovingUnderPartition, erlang:node()==NodeToJoin} of
	{false, false} -> 
		lasp_peer_service:join(NodeToJoin),
		io:format("Clustering is done ~n");
	{true, false} ->
		ok;
	{_,true} -> ok
	end,

	%---------------------------------------	
	%Removing values
	%---------------------------------------
	RemovingTime = removeValues(Id, CRDT_Id, CRDT_Type, NumberOfValues, All_At_Once, RemovingSpeed),
	io:format("Removing values took ~p ms ~n", [RemovingTime]),
	%---------------------------------------	
	%Or Join cluster after removing values
	%---------------------------------------
	case {RemovingUnderPartition, erlang:node()==NodeToJoin} of
	{true, false} -> 
		lasp_peer_service:join(NodeToJoin),
		io:format("Clustering is done ~n");
	{false, false} ->
		ok;
	{_,true} -> ok
	end,
	
	%---------------------------------------	
	%Start Timer for convergence
	%---------------------------------------
	io:format("Waiting for convergence... ~n"),
	InitialTimer = erlang:system_time(1000),
	lasp:read({CRDT_Id, CRDT_Type}, {cardinality, -1}),	% argument -1 corresponds to detect it is empty
	%Ajouter une fonction dans state_awset pour cardinalityG et cardinalityS (bigger et smaller)
	EndTimer = erlang:system_time(1000),
	ConvergedTime = EndTimer - InitialTimer,
	file:copy(NetworkPath, NetworkPath2),
	io:format("Correct number of elements in the set reached! (~p elements) ~n", [Threshold]),
	Final_CRDT_Size = erts_debug:flat_size(  lasp:query({CRDT_Id, CRDT_Type})  ),
	io:format("Final CRDT size: ~p (words) ~n", [Final_CRDT_Size]),
	io:format("Convergence took ~p ms ~n", [ConvergedTime]),
	%---------------------------------------	
	%End Timer for convergence
	%---------------------------------------

	%---------------------------------------	
	%Write to file
	%---------------------------------------
	io:format("Waiting experiment to finish on every node..."),
	lasp:update({<<"done">>, state_awset}, {add, Id}, self()), %Mark that I finished
	lasp:read({<<"done">>, state_awset}, {cardinality, TotalNumberOfNodes}), %Wait everyone finished
	io:format("OK! Writting output file ~n"),
	ExperimentEndTime = erlang:system_time(1000),
	TotalExperimentTime = ExperimentEndTime - ExperimentStartTime,
	io:format("Total experiment duration : ~p ~n", [TotalExperimentTime]),
	generateFileRmv (ExperimentNumber, Id, NodeToJoin, CRDT_Type_String, TotalNumberOfNodes, RemovingSpeed, 
	NumberOfValues, Threshold, ConvergedTime, RemovingUnderPartition, RemovingTime, All_At_Once, Initial_CRDT_Size, Final_CRDT_Size),
	io:format("Done. ~n"),
	io:format("~n"),
	file:delete(NetworkPath),
	timer:sleep(15000), %wait before stopping.
	partisan_peer_service:stop().


%% ===================================================================
%% Helpers for LaunchExperimentRemoving
%% ===================================================================

removeValues(Id, CRDT_Id, CRDT_Type, NumberOfValues, All_At_Once, RemovingSpeed) ->
	ValuesToRemove = lists:seq( (Id-1)*NumberOfValues , (Id*NumberOfValues)-1 ),
	io:format("Removing unique ~p elements, ",[NumberOfValues]),
	StartRemovingTime = erlang:system_time(1000),
	case (All_At_Once) of
	true -> 
		io:format("all at once ~n"),
		lasp:update({CRDT_Id, CRDT_Type}, {rmv_all, ValuesToRemove}, self());
	false ->
		io:format("at speed of one every ~p ms ~n", [RemovingSpeed]),
		removeValues_helper(CRDT_Id, CRDT_Type, NumberOfValues, ValuesToRemove, RemovingSpeed, 1)
	end,
	EndRemovingTime = erlang:system_time(1000),
	RemovingTime = EndRemovingTime - StartRemovingTime,
	io:format("Removing elements is done ~n"),
	RemovingTime.


removeValues_helper(CRDT_Id, CRDT_Type, NumberOfValues ,ValuesToRemove, RemovingSpeed, Counter) ->
	if (Counter =< NumberOfValues) ->
		CurrentValue = lists:nth(Counter, ValuesToRemove),
		lasp:update({CRDT_Id, CRDT_Type}, {rmv, CurrentValue}, self()),
		timer:sleep(RemovingSpeed),
		removeValues_helper(CRDT_Id, CRDT_Type, NumberOfValues ,ValuesToRemove, RemovingSpeed, Counter+1);
	true ->
		io:format("Finished removing values to CRDT ~n")
	end.



generateFileRmv (ExperimentNumber, Id, NodeToJoin, CRDT_Type_String, TotalNumberOfNodes, RemovingSpeed,
 NumberOfValues, Threshold, EllapsedTime, RemovingUnderPartition, RemovingTime, All_At_Once, Initial_CRDT_Size, Final_CRDT_Size) ->

	UniqueValue = integer_to_list(erlang:system_time(1000)),
	Path = "Memoire/Mesures/Exp"++integer_to_list(ExperimentNumber)++"/Node"++integer_to_list(Id)++"_"++UniqueValue++".txt",
	{ok, File} = file:open(Path, [write]),
	
	case (RemovingUnderPartition) of
	true ->
		Partition = "true";
	false ->
		Partition = "false"
	end,
	ExperimentName = "Launching " ++integer_to_list(TotalNumberOfNodes) 
									++ " nodes at the same time with a common filled CRDT, each removing a total of "
							   ++integer_to_list(NumberOfValues)++  " elements (while under partition = " ++ Partition ++ ") " 
								 ++" then start timer and wait until it converged",
	io:format(File, "~s~n", [ExperimentName]),
	io:format(File, "~s~n", [""]), 
	io:format(File, "~s~n", ["============"]), 
	io:format(File, "~s~n", ["Parameters :"]),
	io:format(File, "~s~n", ["============"]), 
	io:format(File, "~s~n", ["Node Id:"]),
	io:format(File, "~s~n", [integer_to_list(Id)]), %Line7
	io:format(File, "~s~n", ["Node to join cluster: "]),
	io:format(File, "~s~n", [NodeToJoin]), %Line9
	io:format(File, "~s~n", ["Removing elements under partition: "]),
	io:format(File, "~s~n", [RemovingUnderPartition]), %Line11
	io:format(File, "~s~n", ["Type of CRDT: "]),
	io:format(File, "~s~n", [CRDT_Type_String]), %Line13
	io:format(File, "~s~n", ["Number of nodes: "]),
	io:format(File, "~s~n", [integer_to_list(TotalNumberOfNodes)]), %Line15
	io:format(File, "~s~n", ["Number of elements removed by each node: "]),
	io:format(File, "~s~n", [integer_to_list(NumberOfValues)]), %Line17
	io:format(File, "~s~n", ["Removing all at once: "]),
	io:format(File, "~s~n", [All_At_Once]),
	io:format(File, "~s~n", ["Initial number of elements before removal: "]),
	io:format(File, "~s~n", [integer_to_list(TotalNumberOfNodes*NumberOfValues)]),
	io:format(File, "~s~n", ["Theoretical time (ms) between each element removing, for each node, valuable only if not removing all at once: "]),
	io:format(File, "~s~n", [integer_to_list(RemovingSpeed)]),
	io:format(File, "~s~n", ["Time (ms) required (for this node) to remove all its assigned elements: "]),
	io:format(File, "~s~n", [integer_to_list(RemovingTime)]),
	io:format(File, "~s~n", ["Initial size of the CRDT (in term of words) : "]),
	io:format(File, "~s~n", [integer_to_list(Initial_CRDT_Size)]),
	io:format(File, "~s~n", ["Total final number of elements in the CRDT: "]),
	io:format(File, "~s~n", [integer_to_list(Threshold)]),
	io:format(File, "~s~n", ["Final size of the CRDT (in term of words) when 0 elements left : "]),
	io:format(File, "~s~n", [integer_to_list(Final_CRDT_Size)]),
	io:format(File, "~s~n", ["Ellapsed time (ms) after elements removal to get the total " ++ integer_to_list(Threshold) ++ " elements:"]),
	io:format(File, "~s~n", [integer_to_list(EllapsedTime)]),
	
	%Network measure file
	NetworkPath2="Memoire/Mesures/Network/Node"++integer_to_list(Id)++"_Final.txt",
	ReceivedMessages = count_line(NetworkPath2)-1, %-1 because of the initial "NEW"
	io:format("number of received messages ~p ~n", [ReceivedMessages]),
	io:format(File, "~s~n", ["Number of message received before convergence : "]),
	io:format(File, "~s~n", [integer_to_list(ReceivedMessages)]),
	io:format(File, "~s~n", ["Number of message received per second : "]),
	Messages_speed = io_lib:format("~.3f",[((ReceivedMessages*1000)/EllapsedTime)]),
	io:format(File, "~s~n", [Messages_speed]),
	io:format(File, "~s~n", ["======================================================================================="]),
	io:format(File, "~s~n", ["======================================================================================="]),
	io:format(File, "~s~n", [""]),
	file:close(File),
	file:delete(NetworkPath2).



%% ===================================================================
%% launchExperimentDynamic:
%% ===================================================================

launchExperimentDynamic(ExperimentNumber, NodeToJoin, CRDT_Id, SendingPeriod) ->
	io:format("Experiment ~p ~n",[ExperimentNumber]),
	timer:sleep(1000), %start with a little sleep to allow NodeToJoin to be booted in case it is a bit slower than this node
	Id = list_to_integer( lists:nth(2,string:split(lists:nth(1,string:split(atom_to_list(erlang:node()),"@")), "e")) ),
	lasp_peer_service:join(NodeToJoin),
	MyRange = lists:seq( (Id-1)*10000 , (Id*10000)-1 ), %0-9999, 10000-19999, 20000-29999,... Each node has its own range of 1000
	StartingElements= lists:seq( ((Id-1)*10000)+5000 , (Id*10000)-1 ), 
	lasp:update({CRDT_Id, state_awset}, {add_all, StartingElements}, self() ), %CRDT already contains 5000-9999, 15000-19999, 25000-29999...
	Path = "Memoire/Mesures/Exp"++integer_to_list(ExperimentNumber)++"/Node"++integer_to_list(Id)++".txt",
	{ok, File} = file:open(Path, [write]),
	ExperimentName = "Launching nodes that will add/remove elements at a specific speed. See info file for more details.",
	io:format(File, "~s~n", [ExperimentName]),
	
	%Start=erlang:system_time(1000),
	startLoop(MyRange, 0, CRDT_Id, SendingPeriod, Path).

	


%% ===================================================================
%% Helpers for launchExperimentDynamic:
%% ===================================================================

startLoop(Range,AddIndex, CRDT_Id, SendingPeriod, Path) ->
	StartOperation=erlang:system_time(1000),
	RemoveIndex=(AddIndex+5000) rem 10000,
	ElementToAdd=lists:nth(AddIndex+1, Range), %Start with NextIndex=1 -> it had 500-999 and we add 0
	ElementToRemove=lists:nth(RemoveIndex+1,Range), %Starting example: it had 500-999, we add 0 and remove 500.
	io:format("Added element: ~p ~n", [ElementToAdd]),
	io:format("Removed element: ~p ~n", [ElementToRemove]),
	io:format("~n"),
	lasp:update({CRDT_Id, state_awset}, {add, ElementToAdd}, self()),
	lasp:update({CRDT_Id, state_awset}, {rmv, ElementToRemove}, self()),
	{ok, CurrentContent} = lasp:query({CRDT_Id, state_awset}),
	ReadableCurrentContent = sets:to_list(CurrentContent),
	CurrentTime = erlang:system_time(1000),
	Size = length(ReadableCurrentContent),
	file:write_file(Path,"\n",[append]),
	file:write_file(Path,"NEXT \n",[append]),
	file:write_file(Path,"TIME " ++ integer_to_list(CurrentTime)++"\n",[append]),
	file:write_file(Path,"ADDED ELEMENT " ++ integer_to_list(ElementToAdd)++"\n",[append]),
	file:write_file(Path,"REMOVED ELEMENT " ++ integer_to_list(ElementToRemove)++"\n",[append]),
	file:write_file(Path,"CRDT Size " ++ integer_to_list(Size)++"\n",[append]),
	file:write_file(Path,"CONTENT : \n",[append]),
	file:write_file(Path,io_lib:format("~p.~n", [ReadableCurrentContent]),[append]),
	EndOperation=erlang:system_time(1000),
	OperationDuration=EndOperation-StartOperation,
	timer:sleep(max(SendingPeriod-OperationDuration, 0)),
	startLoop(Range, ((AddIndex+1) rem 10000), CRDT_Id, SendingPeriod, Path).
	


%% ===================================================================
%% launchContinuousMeasures
%% ===================================================================

launchContinuousMeasures(MeasurePeriod, TimeOut, Debug) -> 
%MeasurePeriod should be at minimum state_interal*4 

	Default_interval = 10000,
	State_interval = lasp_convergence_measure:getInternalStateInterval(Default_interval),
	BestInterval = 4*State_interval,
	
	case (MeasurePeriod < BestInterval) of
		true ->
			RealInterval = BestInterval; % if measurePeriod too small, put to ideal interval
		false ->
			Reminder = MeasurePeriod rem BestInterval,
			Offset = State_interval - Reminder,
			RealInterval = MeasurePeriod + Offset 
			% if measurePeriod bigger than ideal interval, aff an offset to reach an integer number of state_interval
	end,
	
	case Debug of 
	true ->
		io:format("Continuous Measures Started in Talkative mode ~n");
	false ->
		io:format("Continuous Measures Started in Silent mode ~n")
	end,

	Id=list_to_integer( lists:nth(2,string:split(lists:nth(1,string:split(atom_to_list(erlang:node()),"@")), "e")) ),
	NetworkPath="Memoire/Mesures/Network/Node"++integer_to_list(Id)++".txt",
	file:delete(NetworkPath),
	Self = self(),
			_Pid = spawn (fun() -> 
						continuousMeasurementLoop(Id, RealInterval, TimeOut, Debug),
						Self ! {self(), ok} end),
	_Pid.



continuousMeasurementLoop(Id,MeasurePeriod, TimeOut, Debug) ->
	LoopStartTime = erlang:system_time(1000),
	{LeaderId, Cluster_size}=lasp_leader_election:checkLeader(20000), %MeasurePeriod must be at least 4*realConvergenceTime
	case Debug of 
	true ->
		io:format("============================ ~n"),
		io:format("NEW MEASURE ROUND ~n"),
		io:format("============================ ~n"),
		io:format("My leader is: ~p ~n", [LeaderId]);
	false ->
		ok
	end,

	case {LeaderId==Id, Cluster_size>0} of
	{true,true} -> %I am LEADER
			
			%Leader starts by removing TimeStamps in case previous leader crashed and did not remove them.
			{ok , RawPreviousTimeStamps} = lasp:query({<<"basic_task">>, state_awset}),
			PreviousTimeStamps = sets:to_list(RawPreviousTimeStamps),
			lasp:update({<<"basic_task">>, state_awset}, {rmv_all, PreviousTimeStamps}, self()), 
			%Remove in case some node crashed and did not remove its TimeStamp

			%Measure Phase
			StartTime=erlang:system_time(1000),
			lasp:update({<<"leader_task">>, state_awset}, {add, Id}, self()), %I add my Id
			case Debug of 
			true ->
				io:format("[LEADER] Wait for ~p nodes to answer... ", [Cluster_size]);
			false ->
				ok
			end,
			readThresholdMaxDuration({<<"basic_task">>, state_awset}, {cardinality, Cluster_size},TimeOut), 
			%I wait everyone answered. Skip after TimeOut ms waiting
			case Debug of 
			true ->
				io:format("OK! ~n");
			false ->
				ok
			end,	

			%Compute Phase
			RoundTripTime = erlang:system_time(1000)-StartTime,
			{ok, TimeStampSet}=lasp:query({<<"basic_task">>, state_awset}),
			{WorstConvergenceTime, IndividualConvergenceTimes, RatioMsg} = computeWorstConvergenceTime(TimeStampSet, StartTime),
			NewConvergenceInfos = #{roundTripTime => RoundTripTime, worstConvergenceTime => WorstConvergenceTime, 
			individualConvergenceTimes => IndividualConvergenceTimes, networkUsage => RatioMsg},
			PreviousConvergenceTime=getSystemConvergenceInfos(),
			lasp:update({<<"system_convergence">>, state_awset}, {rmv, PreviousConvergenceTime}, self()),
			lasp:update({<<"system_convergence">>, state_awset}, {add, NewConvergenceInfos}, self()),
			case Debug of 
			true ->
				io:format("[LEADER] New convergence infos : ~p ~n", [NewConvergenceInfos]);
			false ->
				ok
			end,
			%Reset Phase
			timer:sleep(1000),
			{ok, PotentialLeadersId}=lasp:query({<<"leader_task">>, state_awset}), %Useful to remove potential previous leader Id if he crashed. 
			ListPotentialLeadersId=sets:to_list(PotentialLeadersId), %Thus we remove ListOfPotentialLeadersId and not simply my own Id.

			lasp:update({<<"leader_task">>, state_awset}, {rmv_all, ListPotentialLeadersId}, self()), %I remove my Id (reset for next measure)
			readThresholdMaxDuration({<<"basic_task">>, state_awset}, {cardinality, -1}, TimeOut), 
			%I wait everyone removed its TimeStamp (reset for next measure). Skip after TimeOut msec waiting
																								 
			{ok , RawPreviousTimeStamps2} = lasp:query({<<"basic_task">>, state_awset}),
			PreviousTimeStamps2 = sets:to_list(RawPreviousTimeStamps2),
			lasp:update({<<"basic_task">>, state_awset}, {rmv_all, PreviousTimeStamps2}, self()), 
			%Remove in case some node crashed and did not remove its TimeStamp
			case Debug of 
			true ->
				io:format("[LEADER] Reset is done ! ~n");
			false ->
				ok
			end,

			LoopEndTime=erlang:system_time(1000),
			LoopDuration=LoopEndTime-LoopStartTime,
			timer:sleep(max(MeasurePeriod-LoopDuration, 0));
			
			

	{false,true} ->%I am NOT-LEADER

			%Measure Phase
			case Debug of 
			true ->
				io:format("[BASIC] Waiting for leader measure signal... ");
			false ->
				ok
			end,
			StartWaiting = erlang:system_time(1000),
			%io:format("put strings to try to figure out when read is timing out"),
			readThresholdMaxDuration({<<"leader_task">>, state_awset}, {cardinality, 1},TimeOut), %I wait to detect leader added his Id
			case Debug of 
			true ->
				io:format("OK ! ~n");
				%Timer = erlang:system_time(1000),
				%io:format("at ~p", [Timer]); % TO REMOVE
			false ->
				ok
			end,
			TimeStamp=erlang:system_time(1000),
			WaitedTime = TimeStamp - StartWaiting,
			Basic_MessageRatio = computeNetworkUsage(Id, WaitedTime),
			%lasp:update({<<"basic_task">>, state_awset}, {add, {Id, TimeStamp}}, self()), %I add my {Id, TimeStamp}
			lasp:update({<<"basic_task">>, state_awset}, {add, {Id, TimeStamp, Basic_MessageRatio}}, self()), %WHY THIS LINE MAKES IT TIME OUT??
			%Reset Phase

			readThresholdMaxDuration({<<"leader_task">>, state_awset}, {cardinality, -1},TimeOut), %I wait to detect leader removed his Id (reset for next measure)
			case Debug of
			true ->
				io:format("[BASIC] Reset is done ! ~n");
			false ->
				ok
			end,
			lasp:update({<<"basic_task">>, state_awset}, {rmv, {Id, TimeStamp, Basic_MessageRatio}}, self()); %I remove my {Id, TimeStamp} (reset for next measure)

	{_,false} -> %Cluster is empty, I am alone
			case Debug of
			true ->
				io:format("I am alone (or just booted) ~n");
			false ->
				ok
			end,
			timer:sleep(500), %Will check for new leader every 500ms
			ok
	end,
	continuousMeasurementLoop(Id, MeasurePeriod, TimeOut, Debug).


computeWorstConvergenceTime(TimeStampSet, StartTime) ->
	TimeStampList=sets:to_list(TimeStampSet),
	case length(TimeStampList) of
	0 ->
		WorstConvergenceTime=nan,
		OrderedConvergenceTimes = [],
		MessagesRatio=nan;
	_ -> 
		ConvergenceTimes = lists:map(fun({A,B,_}) -> #{id => A, convergenceTime => B-StartTime} end, TimeStampList),
		OrderedConvergenceTimes = lists:sort( fun(A,B) -> maps:get(convergenceTime, A) =< maps:get(convergenceTime, B) end, ConvergenceTimes),
		WorstConvergenceTime = lists:nth(length(OrderedConvergenceTimes), OrderedConvergenceTimes),
		MessagesNumbers = lists:map(fun({_,_,C}) -> C end, TimeStampList),
		Sum = lists:sum(MessagesNumbers),
		MessagesRatio = Sum
	end,
	{WorstConvergenceTime, OrderedConvergenceTimes, MessagesRatio}.




getSystemConvergenceInfos() ->
	{ok, RawConvergenceInfo} = lasp:query({<<"system_convergence">>, state_awset}),
	ConvergenceInfoList=sets:to_list(RawConvergenceInfo),
	case length(ConvergenceInfoList) of
	1 ->
		ConvergenceInfo = lists:nth(1, ConvergenceInfoList);
	_ ->
		ConvergenceInfo = nomeasure
	end,
	ConvergenceInfo.

getSystemConvergenceTime() ->
	{ok, RawInfos} = lasp:query({<<"system_convergence">>, state_awset}),
	InfosList = sets:to_list(RawInfos),
	case length(InfosList) of
	1 ->
		Infos = lists:nth(1, InfosList),
		ConvergenceTime = maps:get(convergenceTime , maps:get(worstConvergenceTime, Infos));
	_ ->
		ConvergenceTime = noValue
	end,
	ConvergenceTime.


getSystemWorstNodeId() ->
	{ok, RawInfos} = lasp:query({<<"system_convergence">>, state_awset}),
	InfosList = sets:to_list(RawInfos),
	case length(InfosList) of
	1 ->
		Infos = lists:nth(1, InfosList),
		Node = maps:get(id ,maps:get(worstConvergenceTime, Infos));
	_ ->
		Node = noValue
	end,
	Node.


getSystemRoundTrip() ->
	{ok, RawInfos} = lasp:query({<<"system_convergence">>, state_awset}),
	InfosList = sets:to_list(RawInfos),
	case length(InfosList) of
	1 ->
		Infos = lists:nth(1, InfosList),
		RoundTrip = maps:get(roundTripTime, Infos);
	_ ->
		RoundTrip = noValue
	end,
	RoundTrip.

getIndividualConvergenceTimes() ->
	{ok, RawInfos} = lasp:query({<<"system_convergence">>, state_awset}),
	InfosList = sets:to_list(RawInfos),
	case length(InfosList) of
	1 ->
		Infos = lists:nth(1, InfosList),
		IndividualTimes = maps:get(individualConvergenceTimes, Infos);
	_ ->
		IndividualTimes = noValue
	end,
	IndividualTimes.

getSystemNetworkUsage() ->
	{ok, RawInfos} = lasp:query({<<"system_convergence">>, state_awset}),
	InfosList = sets:to_list(RawInfos),
	case length(InfosList) of
	1 ->
		Infos = lists:nth(1, InfosList),
		NetworkUsage = maps:get(networkUsage, Infos);
	_ ->
		NetworkUsage = noValue
	end,
	NetworkUsage.

getConvergenceTime(Id) -> %VERIFIER QUON NA PAS UN TRUC VIDE
	{LeaderId, _ }=lasp_leader_election:checkLeader(20000),
	case (Id==LeaderId) of
	true -> 
			MyConvergenceTime = getSystemConvergenceTime(); %I am leader, there is no specific measure for myself. I take the worst case instead.
	false ->
			IndividualConvergenceTimes = getIndividualConvergenceTimes(),
			case IndividualConvergenceTimes of
			noValue -> 
				MyConvergenceTime = noValue;
			_ ->
				MyIndividualConvergenceInfoList = lists:filter(fun(A) -> maps:get(id, A)==Id end, IndividualConvergenceTimes),
				case length(MyIndividualConvergenceInfoList) of
				0 -> 
					MyConvergenceTime = noValue;
				_ ->
					MyIndividualConvergenceInfo = lists:nth(1, MyIndividualConvergenceInfoList),
					MyConvergenceTime = maps:get(convergenceTime, MyIndividualConvergenceInfo)
				end
			end
	end,
	MyConvergenceTime.
			



readThresholdMaxDuration(CRDT_Id, Threshold, MaxDuration) ->
	Self = self(),
	_Pid = spawn (fun() -> 
						lasp:read(CRDT_Id, Threshold),
						Self ! {self(), ok} end),
	receive
		{_PidSpawned, ok} -> ok
	after
		MaxDuration -> 
			io:format("time out! ~n"),
			erlang:exit(_Pid, kill)
	end.

readThresholdMaxDurationSilent(CRDT_Id, Threshold, MaxDuration) ->
	Self = self(),
	_Pid = spawn (fun() -> 
						lasp:read(CRDT_Id, Threshold),
						Self ! {self(), ok} end),
	receive
		{_PidSpawned, ok} -> ok
	after
		MaxDuration -> 
			erlang:exit(_Pid, kill)
	end.

computeNetworkUsage(Id, Period) ->
	NetworkPath="Memoire/Mesures/Network/Node"++integer_to_list(Id)++".txt",
	ReceivedMessages = count_line(NetworkPath),
	MessagesPerSec = round( (ReceivedMessages*1000) / Period),
	file:delete(NetworkPath),
	MessagesPerSec.

setStateInterval(NewInterval) ->
	{ok, Interval_query} = lasp:query({<<"state_interval">>, state_awset}),
	Interval_list = sets:to_list(Interval_query),
	lasp:update({<<"state_interval">>, state_awset}, {rmv_all, Interval_list}, self()),
	lasp:update({<<"state_interval">>, state_awset}, {add, NewInterval}, self()),
	io:format("state sending interval set to: ~p ms. ~n", [NewInterval]).

getInternalStateInterval(Default_interval) ->
	case (readThresholdMaxDurationSilent({<<"state_interval">>, state_awset}, {cardinality, 1},1)) of 
	%ReadwithMaxDuration of 1ms for booting to select default value instead
	ok -> Interval = getStateIntervalHelper(Default_interval);
	true -> Interval = Default_interval
	end,
	Interval.

getStateInterval() ->
	{ok, Interval_query} = lasp:query({<<"state_interval">>, state_awset}),
	Interval_list = sets:to_list(Interval_query),
	case length(Interval_list) of
	1 ->
		Interval = lists:nth(1, Interval_list);
	_ ->
		Interval = default
	end,
	Interval.

getStateIntervalHelper(Default_interval) ->

	{ok, Interval_query} = lasp:query({<<"state_interval">>, state_awset}),
	Interval_list = sets:to_list(Interval_query),
	case length(Interval_list) of
	1 ->
		Interval = lists:nth(1, Interval_list);
	_ ->
		Interval=Default_interval
	end,
	Interval.



%% ===================================================================
%% Other small tests:
%% ===================================================================

addition_awset_time() ->
	lasp:declare({<<"special_awset_measure">>, state_awset}, state_awset),
	Start = erlang:system_time(1000),
	fprof:trace(start),
	lasp:update({<<"special_awset_measure">>, state_awset}, {add , 5}, self()),
	fprof:trace(stop),
	EndAdd = erlang:system_time(1000),
	Duration = EndAdd - Start,
	io:format("Computation duration to add a simple little element to an empty awset: ~p ms. ~n", [Duration]).



addition_orset_time() ->
	lasp:declare({<<"special_orset_measure">>, state_orset}, state_orset),
	Start = erlang:system_time(1000),
	lasp:update({<<"special_orset_measure">>, state_orset}, {add , 5}, self()),
	Duration = erlang:system_time(1000) - Start,
	io:format("Computation duration to add a simple little element to an empty orset: ~p ms. ~n", [Duration]).

addition_gcount_time() ->
	lasp:declare({"<<special_gcounter_measure>>", state_gcounter}, state_gcounter),
	Start = erlang:system_time(1000),
	lasp:update({"<<special_gcounter_measure>>", state_gcounter}, increment, self()),
	Duration = erlang:system_time(1000) - Start,
	io:format("Computation duration to increment a starting gcounter: ~p ms. ~n", [Duration]).


simpleAddition() ->
 
	case (erlang:node()=='node1@127.0.0.1') of
	false ->
		lasp_peer_service:join('node1@127.0.0.1'),
		io:format("Clustering is done ~n");
	true ->
		lasp:declare({<<"set99">>, state_awset}, state_awset)
	end,
	Id = list_to_integer( lists:nth(2,string:split(lists:nth(1,string:split(atom_to_list(erlang:node()),"@")), "e")) ),
	Values = lists:seq(1000*Id, (1000*Id)+1000),
	lasp:update({<<"set99">>, state_awset}, {add_all, Values}, self()),
	io:format("I added 1000 elements ~n"),
	lasp:read({<<"set99">>, state_awset}, {cardinality, 5000}).
	

partitionHelper() ->

timer:sleep(5000),
lasp_peer_service:join('node1@127.0.0.1'),
StartTime=erlang:system_time(1000),
lasp:read({<<"partition">>, state_awset}, {cardinality, 1}),
Duration=erlang:system_time(1000) - StartTime,
io:format("Duration to catchup with the cluster: ~p ~n", [Duration]).


%This is called by the partisan when the node receives a message!
%I must make it able to modify a global variable (related to this file)
%That way I will be available to print information about it in the output file.
messageReceived() ->
	Id = list_to_integer( lists:nth(2,string:split(lists:nth(1,string:split(atom_to_list(erlang:node()),"@")), "e")) ),
	Path="Memoire/Mesures/Network/Node"++integer_to_list(Id)++".txt",
	Phrase = "Message received \n",
	file:write_file(Path,Phrase,[append]).


created() ->
	io:format("PARTISAN CREATED ! ~n").


count_line(Filename) ->
    case file:open(Filename, [read]) of
        {ok, IoDevice} ->
            Count = count_line(IoDevice, 0),
            file:close(IoDevice),
            Count;
        {error, Reason} ->
            io:format("~s open error  reason:~s~n", [Filename, Reason]),
            ng
    end.

count_line(IoDevice, Count) ->
    case file:read_line(IoDevice) of
        {ok, _} -> count_line(IoDevice, Count+1);
        eof     -> Count
    end.

wait_threshold(UnixTimeThreshold) ->
	Current = erlang:system_time(1000),
	case (Current < UnixTimeThreshold) of
		true -> wait_threshold(UnixTimeThreshold);
		false -> ok
	end.

