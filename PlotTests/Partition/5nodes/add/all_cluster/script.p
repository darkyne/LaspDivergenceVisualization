set   autoscale                        # scale axes automatically
unset log                              # remove any log-scaling
unset label                            # remove any previous labels
set xtic ('10' 0.25, '100' 2.25, '1000' 4.25)                          # set xtics automatically
set ytic auto                          # set ytics automatically
set title "Partition (5 nodes)"
set xlabel "Number of elements added by each node"
set ylabel "Convergence Time (ms)"
set xrange [0:10]
set yrange [5000:20000]
set label "8639" at 0.1,8639
set label "8687" at 0.6,8687
set label "8792" at 2.1,8792
set label "8829" at 2.6,8829
set label "8675" at 4.1,8675
set label "8736" at 4.6,8736
plot "file.txt" using 1:2:3 with yerrorbars
