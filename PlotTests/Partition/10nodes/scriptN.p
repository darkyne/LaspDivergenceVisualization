set   autoscale                        # scale axes automatically
unset log                              # remove any log-scaling
unset label                            # remove any previous labels
set xtic ('10' 0.25, '100' 2.25, '1000' 4.25)                           # set xtics automatically
set ytic auto                          # set ytics automatically
set title "Different CRDT operation (10 nodes)"
set xlabel "Number of elements added/removed by each node"
set ylabel "Number of messages per sec on the entire cluster"
set xrange [0:50]
set yrange [0:500]
set label "54.56" at 0.1,54.56
set label "69.27" at 0.6,69.27
set label "63.4" at 2.1,63.4
set label "76.05" at 2.6,76.05
set label "57.55" at 4.1,57.55
set label "75.91" at 4.6,75.91
plot "fileN.txt" using 1:2:3 with yerrorbars
