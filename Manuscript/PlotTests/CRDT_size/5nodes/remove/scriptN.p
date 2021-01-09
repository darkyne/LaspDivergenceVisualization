set   autoscale                        # scale axes automatically
unset log                              # remove any log-scaling
unset label                            # remove any previous labels
set xtic ('10' 1, '100' 2, '1000' 3)                          # set xtics automatically
set ytic auto                          # set ytics automatically
set title "Different CRDT size (5 nodes)"
set xlabel "Number of elements removed by each node"
set ylabel "Number of messages per sec on the entire cluster"
set xrange [0:100]
set yrange [0:500]
set label "12.085" at 1.1,12.085
set label "13.45" at 2.1,13.45
set label "13.42" at 3.1,13.42
plot "fileN.txt" using 1:2:3 with yerrorbars
