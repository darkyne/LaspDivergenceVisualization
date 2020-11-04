Set_to_analyse="Saved_2"

cd $Set_to_analyse

mkdir Results

for d in Exp*/; #for every experiment in the set
do 
	echo "Analysing ${d%/*}"
	echo "Results for ${d%/*}" > Results/${d%/*}.txt
	
	#lLOAD DATA
	cd ${d%/*}
	declare -a convergence_array
	index=0
	for file in *.txt
	do
		localvar1=0
		localvar1=$(sed -n 31p $file)
	convergence_array[$index]=$localvar1	
	index=$index+1
	done
	cd ..
	#DATA ARE LOADED in convergence_array, 
	
	
	
	#CONVERGENCE_TIME
	#echo "convergence mean time: $convergence_mean " >> Results/${d%/*}.txt
	printf "%s\n" "${convergence_array[@]}" > Results/temp/${d%/*}.txt
	mean=$(datamash -W mean 1 < Results/temp/${d%/*}.txt)
	var=$(datamash -W sstdev 1 < Results/temp/${d%/*}.txt)
	median=$(datamash -W median 1 < Results/temp/${d%/*}.txt)
	echo "mean is $mean"
	echo "standard deviation is $var"
	echo "median is $median"
	echo "=================="
	
done
