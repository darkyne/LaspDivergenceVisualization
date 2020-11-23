
-module(lasp_leader_election).
-author("Gregory Creupelandt <gregory.creupelandt@student.uclouvain.be>").

-export([checkLeader/1,
		checkLeaderLoop/2
         ]).


checkLeader(Period) -> %Returns the leader Id. If current leader infos are older than Period, it selects a new leader (potentially the same one as before if it's still connected).

	MyId=list_to_integer( lists:nth(2,string:split(lists:nth(1,string:split(atom_to_list(erlang:node()),"@")), "e")) ),
	%Get current leader info
	{ok, RawLeaderInfo}=lasp:query({<<"leader">>, state_awset}),
	ListLeaderInfo=sets:to_list(RawLeaderInfo), 

	%Get current cluster infos
	{ok, Connected}=partisan_pluggable_peer_service_manager:connections(),

	case length(ListLeaderInfo) of
	1 -> %There is one leader, check it is not too old
		{LeaderId, TimeStamp}=lists:nth(1,ListLeaderInfo),
		{PotentialNewLeaderId, Cluster_size}=selectNewLeader(MyId, Connected),

		case {compareTime(TimeStamp) < Period, LeaderId == PotentialNewLeaderId} of
		{true,true} -> % Leader does not change
			NewLeaderId=LeaderId;

		{_,_} -> % Leader has to change
			NewLeaderId=PotentialNewLeaderId
		end;
			
	0 -> %There is no leader, check for new one
		%io:format("I detected no previous leader... ~n"),
		{NewLeaderId, Cluster_size}=selectNewLeader(MyId, Connected);

	_ -> %There are multiple leaders. Should not occur! Remove all its content and select new leader.
		lasp:update({<<"leader">>, state_awset}, {rmv_all, ListLeaderInfo}, self()),
		{NewLeaderId, Cluster_size} =selectNewLeader(MyId, Connected)
	end,
	case (MyId==NewLeaderId) of
	true ->
		lasp:update({<<"leader">>, state_awset}, {rmv_all, ListLeaderInfo}, self()),
		NewTimeStamp=erlang:system_time(1000),
		lasp:update({<<"leader">>, state_awset}, {add, {MyId, NewTimeStamp}}, self());
	false ->
		ok
	end,
	{NewLeaderId, Cluster_size}.



checkLeaderLoop(TimeOut, Period) ->
	StartTime = erlang:system_time(1000),
	%{LeaderId,_} = checkLeader(TimeOut),
	%io:format("My leader is: ~p ~n", [LeaderId]),
	EndTime = erlang:system_time(1000),
	ElapsedTime=EndTime - StartTime,
	timer:sleep(max(0, Period-ElapsedTime)),
	checkLeaderLoop(TimeOut, Period).
	

selectNewLeader(MyId, Connected) -> %Select a new leader, push it to leader crdt and return leader id.


	case dict:size(Connected) of
	0 -> %I am alone (or under partition), no need to push new leader on crdt. Consider myself as leader.
		%io:format("I'm alone (or justed booted) ! ~n"),
		LeaderId=list_to_integer( lists:nth(2,string:split(lists:nth(1,string:split(atom_to_list(erlang:node()),"@")), "e")) ),
		Cluster_size=0;
	_ -> %I am in a cluster with a least one other node
		{LeaderId, Cluster_size}=selectSmaller(MyId)
	end,
	{LeaderId,Cluster_size}.
	
	

selectSmaller(MyId) ->
	{ok, Connected}=partisan_pluggable_peer_service_manager:connections(),
	Keys=dict:fetch_keys(Connected),
	%io:format("KEYS ~p ~n", [Keys]),
	NameList = lists:map(fun(A) -> maps:get(name,A) end ,Keys),
	SortedKeys = lists:usort(NameList),

	%io:format("NAME LIST: ~p ~n", [NameList]),
	%SortedKeys=lists:usort(fun(A,B) -> maps:get(name,A) =< maps:get(name,B) end, Keys),
	
	SmallerNode=lists:nth(1,SortedKeys),
	SmallerId=list_to_integer( lists:nth(2,string:split(lists:nth(1,string:split(atom_to_list(SmallerNode),"@")), "e")) ),
	case (MyId < SmallerId) of
	true -> {MyId, length(SortedKeys)};
	false -> {SmallerId, length(SortedKeys)}
	end.
	



compareTime(TimeStamp) ->
	CurrentTime=erlang:system_time(1000),
	CurrentTime-TimeStamp.


