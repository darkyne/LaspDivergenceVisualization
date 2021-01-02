set   autoscale                        # scale axes automatically
unset log                              # remove any log-scaling
unset label                            # remove any previous labels
set xtic ('Local' 1, 'Same wireless network' 2, 'Remote network' 3)                          # set xtics automatically
set ytic auto                          # set ytics automatically
set title "Different cluster size (nodes add 10 elements each)"
set xlabel "Nodes distance"
set ylabel "Convergence time (ms)"
set xrange [0:4]
set yrange [5000:20000]
set label "8639" at 1.1,8639
set label "8655" at 2.1,8655
set label "8705" at 3.1,8705
plot "fileadd10.txt" using 1:2:3 with yerrorbars
