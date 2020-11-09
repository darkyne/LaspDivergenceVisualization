Set_to_analyse="Saved_4"

cd $Set_to_analyse

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
	
	
	echo "mean is $convergence_mean"
	echo "convergence mean time: $convergence_mean " >> Results/${d%/*}.txt
	echo "standard deviation is $convergence_ecart"
	echo "convergence time standart deviation: $convergence_ecart" >> Results/${d%/*}.txt
	echo "median is $convergence_median"
	echo "convergence time median: $convergence_median" >> Results/${d%/*}.txt
	
	echo "initial size of the CRDT (with $initialNumberOfElements elements): $initialSize" >> Results/${d%/*}.txt
	echo "final size of the CRDT (with $finalNumberOfElements elements): $finalSize" >> Results/${d%/*}.txt
	
	echo "mean number of messages/sec : $message_mean " >> Results/${d%/*}.txt
	echo "number of messages/sec standart deviation: $message_ecart" >> Results/${d%/*}.txt
	echo "number of messages/sec median: $message_median" >> Results/${d%/*}.txt
	
	echo "=================="
	
done
