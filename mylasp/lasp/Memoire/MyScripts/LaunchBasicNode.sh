echo "Launching a basic node"
cd ../..
cp Basic_node/lasp_app.erl src/lasp_app.erl
rebar3 shell --name node1@127.0.0.1
