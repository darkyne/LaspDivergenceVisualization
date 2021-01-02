set   autoscale                        # scale axes automatically
unset log                              # remove any log-scaling
unset label                            # remove any previous labels
set xtic ('10' 1, '100' 2, '1000' 3)                          # set xtics automatically
set ytic auto                          # set ytics automatically
set title "Different CRDT size (5 nodes)"
set xlabel "Number of elements added by each node"
set ylabel "Convergence Time (ms)"
set xrange [0:4]
set yrange [5000:20000]
set label "8639" at 1.1,8639
set label "8792" at 2.1,8792
set label "8875" at 3.1,8875
plot "file.txt" using 1:2:3 with yerrorbars
