set   autoscale                        # scale axes automatically
unset log                              # remove any log-scaling
unset label                            # remove any previous labels
set xtic ('10' 1, '50' 2, '100' 3, '500' 4, '1000' 5, '5000' 6, '10000' 7)                         # set xtics automatically
set ytic auto                          # set ytics automatically
set title "Different CRDT size (5 nodes)"
set xlabel "Number of elements added by each node"
set ylabel "Number of messages per sec on the entire cluster"
set xrange [0:10]
set yrange [0:800]
set label "680" at 1.1,680
set label "192" at 2.1,192
set label "144" at 3.1,144
set label "120" at 4.1,120
set label "85" at 5.1,85
set label "30" at 6.1,30
set label "12" at 7.1,12
plot "fileN.txt" using 1:2:3 with yerrorbars
