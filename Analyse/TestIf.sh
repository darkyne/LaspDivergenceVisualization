#!/bin/bash

#Set3 10nodes, 6experiments, 50iterations, 60sec duration

#This Script launchs 10nodes that will add elements and measure convergence time, CRDT memory size and number of messages received
#You may need to modify IpAddress, put it to 127.0.0.1 for local tests.s

decalage=0 #decalage=pi_booting_time - pc_booting_time = 8.32
initialNode=1
localNodes=10
iterations=50
experiments=6
duration=60

#on PC:
ipAddress=192.168.1.39
#on Pi:
#ipAddress=192.168.1.62

sourcePath=Memoire/AppsToLaunch/Set3/measure
sourcePath2=/lasp_app.erl
destinationPath=src




for k in $(seq 1 1 "$experiments")  #number of different expriments
do
	if [ $k = 5 ]
	then
	echo "experiment5"
	fi
	
	echo "experiment$k finished"

done
