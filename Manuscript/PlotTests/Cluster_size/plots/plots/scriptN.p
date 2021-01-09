set   autoscale                        # scale axes automatically
unset log                              # remove any log-scaling
unset label                            # remove any previous labels
set xtic ('5' 1, '10' 2, '20' 3)                          # set xtics automatically
set ytic auto                          # set ytics automatically
set title "Different cluster size (nodes add 100 elements each)"
set xlabel "Cluster Size (# nodes)"
set ylabel "Number of messages per sec"
set xrange [0:10]
set yrange [0:500]
set label "13.45" at 1.1,13.45
set label "76.05" at 2.1,76.05
set label "167.6" at 3.1,167.6
plot "fileadd10Network.txt" using 1:2:3 with yerrorbars
