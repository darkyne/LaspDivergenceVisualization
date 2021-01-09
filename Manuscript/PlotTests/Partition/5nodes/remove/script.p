set   autoscale                        # scale axes automatically
unset log                              # remove any log-scaling
unset label                            # remove any previous labels
set xtic ('10' 0.25, '100' 2.25, '1000' 4.25)                          # set xtics automatically
set ytic auto                          # set ytics automatically
set title "Different CRDT operation (5 nodes)"
set xlabel "Number of elements added or removed by each node"
set ylabel "Convergence Time (ms)"
set xrange [0:10]
set yrange [5000:20000]
set label "7687" at 0.1,7687
set label "7698" at 0.6,7698
set label "7812" at 2.1,7812
set label "7824" at 2.6,7824
set label "8113" at 4.1,8113
set label "8154" at 4.6,8154
plot "file.txt" using 1:2:3 with yerrorbars