set   autoscale                        # scale axes automatically
unset log                              # remove any log-scaling
unset label                            # remove any previous labels
set xtic ('10' 0.25, '100' 2.25, '1000' 4.25)                          # set xtics automatically
set ytic auto                          # set ytics automatically
set title "Partition impact on one node (5 nodes)"
set xlabel "Number of elements added by each node"
set ylabel "Convergence Time (ms)"
set xrange [0:10]
set yrange [5000:20000]
set label "8639" at 0.1,8639
set label "8679" at 0.6,8679
set label "8792" at 2.1,8792
set label "8817" at 2.6,8817
set label "8675" at 4.1,8675
set label "8747" at 4.6,8747
plot "file.txt" using 1:2:3 with yerrorbars
