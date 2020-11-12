#!/bin/bash

#Set7 5nodes, adding/removing every 10sec

#This Script launchs 5 that will add and remove elements then dump to a file the current CRDT.


decalage=0 #decalage=pi_booting_time - pc_booting_time = 8.32
initialNode=1
localNodes=10
experiments=5
duration=120

#For local tets:
#ipAddress=127.0.0.1

#on PC:
ipAddress=192.168.1.39

#on Pi:
#ipAddress=192.168.1.62

sourcePath=Memoire/AppsToLaunch/Set8/measure
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
	for file in Memoire/Mesures/Network/*.txt
	do
		messages=$(wc -l $file)
		NumberOfMessages="${messages%% Memoire*}"
		NumberOfMessagesPerSec=$(bc <<< "scale=3;$NumberOfMessages/$duration") 
		Node=${file#*Network/}
		echo "Number of messages received/sec:$NumberOfMessagesPerSec" > Memoire/Mesures/Exp$k/Network_$Node
		echo "Experiment duration:$duration" >> Memoire/Mesures/Exp$k/Network_$Node
		echo "Total number of messages:$NumberOfMessages" >> Memoire/Mesures/Exp$k/Network_$Node
	done
	
	rm Memoire/Mesures/Network/*.txt
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
	echo "============================="
	echo "Analysing ${d%/*}"
	echo "============================="
	
	echo "Results for ${d%/*}" > Results/${d%/*}.txt
	cd ${d%/*}
	input="Node1.txt"
	while IFS= read -r line
	do
		if [[ $line == TIME* ]]
		then 
			
			time=${line#*TIME }
			read line1
			newElement=${line1#*ELEMENT }
			read line2
			removedElement=${line2#*ELEMENT }
			read line3
			size=${line3#*Size }
			
			echo ""
			echo "Computing convergence time for element $newElement"
			
			for file in Node*.txt
			do
				if  [ $file != "Node1.txt" ] #don't look inside node1 file
				then
					if  grep -q -w -n -m 1 "$newElement" $file
					then 
						foundLine=$(grep -w -n -m 1 "$newElement" $file)
						lineNumber=${foundLine%:*}
						currentLine=$(sed "${lineNumber}q;d" $file)
						while [[ $currentLine != TIME* ]] 
						do
							let "--lineNumber"
							currentLine=$(sed -n "${lineNumber}p" $file)
						done
						foundTime=${currentLine#*TIME }
						requiredTime=$((foundTime-time))
						echo "$file for element $newElement convergence time:$requiredTime" >> ${d%/*}.txt
					else
						echo "element $newElement: experiment stopped before it converged."
					fi
				fi
			
			done
		fi
	done < "$input"
	
	MEGA=1000
	for networkfile in Network_Node*.txt
	do
		MessageLine=$(sed -n 1p $networkfile)
		NumberOfMessages=${MessageLine#*sec:}
		NumberOfMessages=$(bc -l <<<"${NumberOfMessages}*${MEGA}")
		NumberOfMessages=${NumberOfMessages%.*}
		echo $NumberOfMessages >> Network_Result.txt		
	done
	
	div=1000
	message_mean=$(datamash -W mean 1 < Network_Result.txt)
	message_mean=${message_mean%,*}
	message_mean=$(bc <<< "scale=3;$message_mean/$div") 
	
	message_ecart=$(datamash -W sstdev 1 < Network_Result.txt)
	message_ecart=${message_ecart%,*}
	message_ecart=$(bc <<< "scale=3;$message_ecart/$div") 
	
	message_median=$(datamash -W median 1 < Network_Result.txt)
	message_median=${message_median%,*}
	message_median=$(bc <<< "scale=3;$message_median/$div") 
	

	
	
	while IFS= read -r line
	do
		converge_time=${line#*:}
		echo $converge_time >> "temp.txt"
	done < ${d%/*}.txt
	convergence_mean=$(datamash -W mean 1 < temp.txt)
	convergence_ecart=$(datamash -W sstdev 1 < temp.txt)
	convergence_median=$(datamash -W median 1 < temp.txt)
	rm temp.txt
	rm ${d%/*}.txt
	cd ..
	echo "convergence mean :$convergence_mean"  >> Results/${d%/*}.txt
	echo "convergence ecart type :$convergence_ecart"  >> Results/${d%/*}.txt
	echo "convergence median :$convergence_median"  >> Results/${d%/*}.txt
	
	echo "messages per sec mean:$message_mean" >> Results/${d%/*}.txt
	echo "messages per sec ecart type:$message_ecart" >> Results/${d%/*}.txt
	echo "messages per sec median:$message_median" >> Results/${d%/*}.txt
	
done




