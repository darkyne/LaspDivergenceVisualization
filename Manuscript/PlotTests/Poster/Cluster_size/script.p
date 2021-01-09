set   autoscale                        # scale axes automatically
unset log                              # remove any log-scaling
unset label                            # remove any previous labels
set xtic ('5' 1, '10' 2, '20' 3)                          # set xtics automatically
set ytic auto                          # set ytics automatically
set title "Different cluster size (CRDT of 1000 elements)"
set xlabel "Cluster Size (# nodes)"
set ylabel "Convergence time (ms)"
set xrange [0:4]
set yrange [5000:20000]
set label "8336" at 1.1,8336
set label "13706" at 2.1,13706
set label "17495" at 3.1,17495
plot "file.txt" using 1:2:3 with yerrorbars and labels
