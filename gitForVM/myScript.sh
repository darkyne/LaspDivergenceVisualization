#!/bin/bash

decalage=0 #decalage=pi_booting_time - pc_booting_time = 8.32
initialNode=1
localNodes=5
iterations=50
experiments=10
duration=60

#on PC:
sourcePath=~/Documents/MEMOIRE/LaspDivergenceVisualization/lasp/Memoire/AppsToLaunch/measure
sourcePath2=/lasp_app.erl
destinationPath=~/Documents/MEMOIRE/LaspDivergenceVisualization/lasp/src
ipAddress=192.168.1.39

#on Pi:
#sourcePath=~/Documents/MEMOIRE_LASP/lasp/SavedApps/measure
#sourcePath2=/lasp_app.erl
#destinationPath=~/Documents/MEMOIRE_LASP/lasp/src
#ipAddress=192.168.1.62

echo "launching the script"
sleep $decalage #Wait initial decallage related to raspberry pi slow nodes booting


for k in $(seq 1 1 "$experiments")  #number of different expriments
do
	#Load next experiment
	sleep 1
	cp $sourcePath$k$sourcePath2 $destinationPath
	sleep 1
	
	for j in $(seq 1 1 "$iterations") #number of iterations
	do

		for i in $(seq "$initialNode" 1 "$localNodes") #number of local nodes
		do
			xterm -hold -e "rebar3 shell --name node$i@$ipAddress" &
		done
		sleep $duration
		killall xterm
		sleep 1
	done

	echo "experiment$k finished"

done


