set   autoscale                        # scale axes automatically
unset log                              # remove any log-scaling
unset label                            # remove any previous labels
set xtic ('10' 0.25, '100' 2.25, '1000' 4.25)                          # set xtics automatically
set ytic auto                          # set ytics automatically
set title "Different CRDT operation (10 nodes)"
set xlabel "Number of elements added or removed by each node"
set ylabel "Convergence Time (ms)"
set xrange [0:10]
set yrange [5000:20000]
set label "12131" at 0.1,12131
set label "11630" at 0.6,11630
set label "13201" at 2.1,13201
set label "11699" at 2.6,11699
set label "13545" at 4.1,13545
set label "12019" at 4.6,12019
plot "file.txt" using 1:2:3 with yerrorbars
