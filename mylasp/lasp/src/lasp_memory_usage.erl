
-module(lasp_memory_usage).
-author("Gregory Creupelandt <gregory.creupelandt@student.uclouvain.be>").

-export([memoryMeasure/0
		]).


memoryMeasure() ->

{_,Memory} = erlang:process_info(whereis(lasp_ets_storage_backend), memory),
Memory_KB = Memory / 1024,
Memory_MB = Memory_KB / 1024,
Floated_Memory_MB = float_to_list(Memory_MB,[{decimals,0}]),
io:format("memory usage: ~p MB ~n",[Floated_Memory_MB]),
timer:sleep(1000),
memoryMeasure().
