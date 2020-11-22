
echo "Launching a basic node"
cd ../..

Node=$(sed -n 1p Memoire/AppsToLaunch/IpAddress.txt)
Ip=$(cut -d "@" -f2- <<< "$Node")


cp Memoire/AppsToLaunch/Basic_node/lasp_app.erl src/lasp_app.erl
rebar3 shell --name node1@$Ip
