#!/bin/bash

#Set5 20nodes, 6experiments, 50iterations, 60sec duration

#This Script launchs 20nodes that will add elements and measure convergence time, CRDT memory size and number of messages received
#You may need to modify IpAddress, put it to 127.0.0.1 for local tests.s

decalage=0 #decalage=pi_booting_time - pc_booting_time = 8.32
initialNode=1
localNodes=20
iterations=50
experiments=4
duration=60

#For local tets:
#ipAddress=127.0.0.1

#on PC:
ipAddress=192.168.1.39

#on Pi:
#ipAddress=192.168.1.62

sourcePath=Memoire/AppsToLaunch/Set5/measure
sourcePath2=/lasp_app.erl
destinationPath=src

#============================================================================================
#============================================================================================
#==============================	REMOVE PREVIOUS MEASURES ===================================
#============================================================================================
#============================================================================================

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


echo "LAUNCHING THE NEW EXPERIMENTS SET"
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
		rm Memoire/Mesures/Network/*.*
	done

	echo "experiment$k finished"

done


#============================================================================================
#============================================================================================
#==============================	ANALYSE OUTPUTS =============================================
#============================================================================================
#============================================================================================
echo "ANALYSING THE OUTPUTS"

cd Memoire/Mesures

mkdir Results

for d in Exp*/; #for every experiment in the set
do 
	echo "Analysing ${d%/*}"
	echo "Results for ${d%/*}" > Results/${d%/*}.txt
	
	#lLOAD DATA
	cd ${d%/*}
	declare -a convergence_array
	declare -a message_array
	MEGA=1000
	index=0
	for file in *.txt
	do
		localvar1=$(sed -n 33p $file)
		localvar2=$(sed -n 37p $file)
		localvar2=$(bc -l <<<"${localvar2}*${MEGA}")
		localvar2=${localvar2%.*}
		convergence_array[$index]=$localvar1
		message_array[$index]=$localvar2
		index=$index+1
	done
	
	initialSize=$(sed -n 27p $file)
	finalSize=$(sed -n 31p $file)
	
	initialNumberOfElements=$(sed -n 21p $file)
	finalNumberOfElements=$(sed -n 29p $file)
	
	cd ..
	#DATA ARE LOADED in convergence_array, 
	
	
	
	#CONVERGENCE_TIME
	printf "%s\n" "${convergence_array[@]}" > Results/temp${d%/*}.txt
	convergence_mean=$(datamash -W mean 1 < Results/temp${d%/*}.txt)
	convergence_ecart=$(datamash -W sstdev 1 < Results/temp${d%/*}.txt)
	convergence_median=$(datamash -W median 1 < Results/temp${d%/*}.txt)
	rm Results/temp*.*
	
	#MESSAGES/SEC
	div=1000
	printf "%s\n" "${message_array[@]}" > Results/temp${d%/*}.txt
	message_mean=$(datamash -W mean 1 < Results/temp${d%/*}.txt)
	message_mean=${message_mean%,*}
	message_mean=$(bc <<< "scale=3;$message_mean/$div") 

	message_ecart=$(datamash -W sstdev 1 < Results/temp${d%/*}.txt)
	message_ecart=${message_ecart%,*}
	message_ecart=$(bc <<< "scale=3;$message_ecart/$div") 
	
	message_median=$(datamash -W median 1 < Results/temp${d%/*}.txt)
	message_median=${message_median%,*}
	message_median=$(bc <<< "scale=3;$message_median/$div") 
	
	rm Results/temp*.*
	
	
	echo "convergence mean time is $convergence_mean"
	echo "convergence mean time: $convergence_mean " >> Results/${d%/*}.txt
	echo "convergence time standart deviation: $convergence_ecart" >> Results/${d%/*}.txt
	echo "convergence time median: $convergence_median" >> Results/${d%/*}.txt
	
	echo "initial size of the CRDT (with $initialNumberOfElements elements): $initialSize" >> Results/${d%/*}.txt
	echo "final size of the CRDT (with $finalNumberOfElements elements): $finalSize" >> Results/${d%/*}.txt
	
	echo "mean number of messages/sec : $message_mean " >> Results/${d%/*}.txt
	echo "number of messages/sec standart deviation: $message_ecart" >> Results/${d%/*}.txt
	echo "number of messages/sec median: $message_median" >> Results/${d%/*}.txt
	
	echo "=================="
	
done
#put back to main lasp directory
cd ..
cd ..


