#!/bin/bash

#Set7 5nodes, adding/removing every 10sec

#This Script launchs 5 that will add and remove elements then dump to a file the current CRDT.


decalage=0 #decalage=pi_booting_time - pc_booting_time = 8.32
initialNode=1
localNodes=5
experiments=5
duration=30

#For local tets:
#ipAddress=127.0.0.1

#on PC:
ipAddress=192.168.1.39

#on Pi:
#ipAddress=192.168.1.62

sourcePath=Memoire/AppsToLaunch/Set7/measure
sourcePath2=/lasp_app.erl
destinationPath=src

#============================================================================================
#============================================================================================
#==============================	REMOVE PREVIOUS MEASURES ===================================
#============================================================================================
#============================================================================================
cd ../.. #Go to main lasp directory

echo "deleting previous measures"
rm Memoire/Mesures/Exp1/*.txt
rm Memoire/Mesures/Exp2/*.txt
rm Memoire/Mesures/Exp3/*.txt
rm Memoire/Mesures/Exp4/*.txt
rm Memoire/Mesures/Exp5/*.txt
rm Memoire/Mesures/Exp6/*.txt
rm Memoire/Mesures/Exp7/*.txt
rm Memoire/Mesures/Exp8/*.txt
rm Memoire/Mesures/Exp9/*.txt
rm Memoire/Mesures/Exp10/*.txt

rm Memoire/Mesures/Network/*.txt

#============================================================================================
#============================================================================================
#==============================	LAUNCH EXPERIMENTS==========================================
#============================================================================================
#============================================================================================

Node=$(sed -n 1p Memoire/AppsToLaunch/IpAddress.txt)
Ip=$(cut -d "@" -f2- <<< "$Node")

echo "LAUNCHING THE NEW EXPERIMENTS SET"
sleep $decalage #Wait initial decallage related to raspberry pi slow nodes booting


for k in $(seq 1 1 "$experiments")  #number of different expriments
do
	#Load next experiment
	sleep 1
	cp $sourcePath$k$sourcePath2 $destinationPath
	sleep 1
	
	for i in $(seq "$initialNode" 1 "$localNodes") #number of local nodes
	do
		xterm -hold -e "rebar3 shell --name node$i@$Ip" &
	done
	sleep $duration
	killall xterm
	sleep 1
	#Do something with the network file before removing it, like counting the number of messages compared to the entire duration (based on first and list TIME in the dump file or something like that)
	for file in Memoire/Mesures/Network/*.txt
	do
		messages=$(wc -l $file)
		NumberOfMessages="${messages%% Memoire*}"
		Node=${file#*Network/}
		echo "Number of messages received: $NumberOfMessages" > Memoire/Mesures/Exp$k/Network_$Node
		echo "Experiment duration: $duration" >> Memoire/Mesures/Exp$k/Network_$Node
	done
	
	#rm Memoire/Mesures/Network/*.txt
	echo "experiment$k finished"
done

