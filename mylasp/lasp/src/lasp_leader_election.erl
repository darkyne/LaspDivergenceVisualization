
-module(lasp_leader_election).
-author("Gregory Creupelandt <gregory.creupelandt@student.uclouvain.be>").

-export([checkLeader/1
         ]).


checkLeader(Period) -> %Returns the leader Id. If current leader infos are older than Period, it selects a new leader (potentially the same one as before if it's still connected).

	MyId=list_to_integer( lists:nth(2,string:split(lists:nth(1,string:split(atom_to_list(erlang:node()),"@")), "e")) ),
	%Get current leader info
	{ok, RawLeaderInfo}=lasp:query({<<"leader">>, state_awset}),
	ListLeaderInfo=sets:to_list(RawLeaderInfo), 

	case length(ListLeaderInfo) of
	1 -> %There is one leader, check it is not too old
		io:format("I detected previous leader ~n"),
		{LeaderId, TimeStamp}=lists:nth(1,ListLeaderInfo),

		case (compareTime(TimeStamp) < Period) of
		true -> % Leader does not change
			NewLeaderId=LeaderId;

		false -> % Leader has to change
			NewLeaderId=selectNewLeader(MyId),
		end;
			
	0 -> %There is no leader, check for new one
		io:format("I detected no previous leader... ~n"),
		NewLeaderId=selectNewLeader(MyId);

	_ -> %There are multiple leaders. Should not occur! Remove all its content and select new leader.
		lasp:update({<<"leader">>, state_awset}, {rmv_all, ListLeaderInfo}, self()),
		NewLeaderId=selectNewLeader(MyId)
	end,
	case (MyId==NewLeaderId) of
	true ->
		NewTimeStamp=erlang:system_time(1000),
		lasp:update({<<"leader">>, state_awset}, {add, {MyId, NewTimeStamp}}, self());
	false ->
		ok
	end,
	NewLeaderId.

selectNewLeader(MyId) -> %Select a new leader, push it to leader crdt and return leader id.

	{ok, Connected}=partisan_pluggable_peer_service_manager:connections(),

	case dict:size(Connected) of
	0 -> %I am alone (or under partition), no need to push new leader on crdt. Consider myself as leader.
		LeaderId=list_to_integer( lists:nth(2,string:split(lists:nth(1,string:split(atom_to_list(erlang:node()),"@")), "e")) ); 

	_ -> %I am in a cluster with a least one other node
		LeaderId=selectSmaller(MyId)
	end,
	LeaderId.
	
	

selectSmaller(MyId) ->
	{ok, Connected}=partisan_pluggable_peer_service_manager:connections(),
	Keys=dict:fetch_keys(Connected),
	SortedKeys=lists:sort(fun(A,B) -> maps:get(name,A) =< maps:get(name,B) end, Keys),
	SmallerNode=lists:nth(1,SortedKeys),
	SmallerName=maps:get(name,SmallerNode),
	SmallerId=list_to_integer( lists:nth(2,string:split(lists:nth(1,string:split(atom_to_list(SmallerName),"@")), "e")) ),
	case (MyId < SmallerId) of
	true -> MyId;
	false -> SmallerId
	end.
	



compareTime(TimeStamp) ->
	CurrentTime=erlang:system_time(1000),
	CurrentTime-TimeStamp.

%addMyself(Connected) ->
%Completed = partisan_peer_service_connections:store(node_myself(), node_myself_bind(), Connected),
%Completed.
	
%node_myself() ->
  %  #{name => erlang:node(), listen_addrs => [node_myself_listen_addr()]}.

%node_myself_listen_addr() ->
 %   #{ip => {127, 0, 0, 1}, port => 80}.

%node_myself_bind() ->
  %  {node_myself_listen_addr(), undefined, self()}.

