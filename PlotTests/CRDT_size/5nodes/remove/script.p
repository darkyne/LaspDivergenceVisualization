set   autoscale                        # scale axes automatically
unset log                              # remove any log-scaling
unset label                            # remove any previous labels
set xtic ('10' 1, '100' 2, '1000' 3)                          # set xtics automatically
set ytic auto                          # set ytics automatically
set title "Different CRDT size (5 nodes)"
set xlabel "Number of elements removed by each node"
set ylabel "Convergence Time (ms)"
set xrange [0:4]
set yrange [5000:20000]
set label "7687" at 1.1,7687
set label "7812" at 2.1,7812
set label "8113" at 3.1,8113
plot "file.txt" using 1:2:3 with yerrorbars
