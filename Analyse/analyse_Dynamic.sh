Set_to_analyse="Saved_7"

cd $Set_to_analyse

rm Exp1/Exp1.ext
rm Exp2/Exp2.txt
rm Exp3/Exp3.txt
rm Exp4/Exp4.txt
rm Exp5/Exp5.txt

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
							currentLine=$(sed "${lineNumber}q;d" $file)
						done
						foundTime=${currentLine#*TIME }
						requiredTime=$((foundTime-time))
						echo "$file for element $newElement convergence time:$requiredTime" >> ${d%/*}.txt
					else
						echo "element $newElement: experiment stopped before it converged."
					fi
				fi
			
			done
			echo "" >> ${d%/*}.txt
		fi
	done < "$input"
	cd ..
	
 #TODO Il reste à partcourir les fichiers Exp.txt pour calculer moyenne/écart type etc.
	
done
