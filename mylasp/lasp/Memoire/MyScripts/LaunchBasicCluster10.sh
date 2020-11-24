
echo "Launching a basic cluster of 10 nodes"
cd ../..
duration=300 #5 min

Node=$(sed -n 1p Memoire/AppsToLaunch/IpAddress.txt)
Ip=$(cut -d "@" -f2- <<< "$Node")


cp Memoire/AppsToLaunch/Basic_cluster/lasp_app.erl src/lasp_app.erl



for i in $(seq 1 1 10)  #number of nodes
do
	xterm -hold -e "rebar3 shell --name node$i@$Ip" &
done
sleep $duration
killall xterm