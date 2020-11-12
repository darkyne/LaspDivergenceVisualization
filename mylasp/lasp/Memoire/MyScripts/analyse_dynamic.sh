

Set_to_analyse="Saved_7"

cd $Set_to_analyse

rm Exp1/Exp1.txt
rm Exp1/temp.txt
rm Exp1/Network_Result.txt

rm Exp2/Exp2.txt
rm Exp2/temp.txt
rm Exp2/Network_Result.txt

rm Exp3/Exp3.txt
rm Exp3/temp.txt
rm Exp3/Network_Result.txt

rm Exp4/Exp4.txt
rm Exp4/temp.txt
rm Exp4/Network_Result.txt

rm Exp5/Exp5.txt
rm Exp5/temp.txt
rm Exp5/Network_Result.txt

rm Results/*.txt

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
	
 #TODO Il reste à partcourir les fichiers Exp.txt pour calculer moyenne/écart type etc.
	
done
