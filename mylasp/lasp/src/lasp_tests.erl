-module(lasp_tests).
-author("Gregory Creupelandt <gregory.creupelandt@student.uclouvain.be>").

-export([simpleAwset/0]).

simpleAwset() ->
	lasp:update({<<"test_awset">>, state_awset}, {add, "5"}, self()).
