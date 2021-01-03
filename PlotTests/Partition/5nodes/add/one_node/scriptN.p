set   autoscale                        # scale axes automatically
unset log                              # remove any log-scaling
unset label                            # remove any previous labels
set xtic ('10' 0.25, '100' 2.25, '1000' 4.25)                           # set xtics automatically
set ytic auto                          # set ytics automatically
set title "One node under partition (5 nodes cluster)"
set xlabel "Number of elements added by each node"
set ylabel "Number of messages per sec on the entire cluster"
set xrange [0:100]
set yrange [0:500]
set label "10.945" at 0.1,10.945
set label "11.01" at 0.6,11.01
set label "11.18" at 2.1,11.18
set label "11.04" at 2.6,11.04
set label "11.19" at 4.1,11.19
set label "11.40" at 4.6,11.40
plot "fileN.txt" using 1:2:3 with yerrorbars
