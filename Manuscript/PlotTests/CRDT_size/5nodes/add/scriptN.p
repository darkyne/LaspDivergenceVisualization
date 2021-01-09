set   autoscale                        # scale axes automatically
unset log                              # remove any log-scaling
unset label                            # remove any previous labels
set xtic ('10' 1, '100' 2, '1000' 3)                          # set xtics automatically
set ytic auto                          # set ytics automatically
set title "Different CRDT size (5 nodes)"
set xlabel "Number of elements added by each node"
set ylabel "Number of messages per sec on the entire cluster"
set xrange [0:100]
set yrange [0:500]
set label "10.945" at 1.1,10.945
set label "11.18" at 2.1,11.18 
set label "11.19" at 3.1,11.19
plot "fileN.txt" using 1:2:3 with yerrorbars
