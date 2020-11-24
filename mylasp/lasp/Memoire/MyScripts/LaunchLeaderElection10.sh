
echo "Launching 10 simple node running leader election as main task (for demonstration)"
cd ../..
duration=300 #5min

Node=$(sed -n 1p Memoire/AppsToLaunch/IpAddress.txt)
Ip=$(cut -d "@" -f2- <<< "$Node")


cp Memoire/AppsToLaunch/LeaderElection/lasp_app.erl src/lasp_app.erl



for i in $(seq 1 1 10)  #number of nodes
do
	xterm -hold -e "rebar3 shell --name node$i@$Ip" &
done
sleep $duration
killall xterm
