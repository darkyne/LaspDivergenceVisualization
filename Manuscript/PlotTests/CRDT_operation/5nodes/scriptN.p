set   autoscale                        # scale axes automatically
unset log                              # remove any log-scaling
unset label                            # remove any previous labels
set xtic ('10' 0.25, '100' 2.25, '1000' 4.25)                           # set xtics automatically
set ytic auto                          # set ytics automatically
set title "Different CRDT operation (5 nodes)"
set xlabel "Number of elements added/removed by each node"
set ylabel "Number of messages per sec on the entire cluster"
set xrange [0:100]
set yrange [0:500]
set label "10.945" at 0.1,10.945
set label "12.085" at 0.6,12.085
set label "11.18" at 2.1,11.18
set label "13.45" at 2.6,13.45
set label "11.19" at 4.1,11.19
set label "13.42" at 4.6,13.42
plot "fileN.txt" using 1:2:3 with yerrorbars
