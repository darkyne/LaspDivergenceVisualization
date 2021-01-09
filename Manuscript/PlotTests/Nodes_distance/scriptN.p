set   autoscale                        # scale axes automatically
unset log                              # remove any log-scaling
unset label                            # remove any previous labels
set xtic ('Local' 1, 'Same wireless network' 2, 'Remote network' 3)                          # set xtics automatically
set ytic auto                          # set ytics automatically
set title "Different nodes distances (nodes add 10 elements each)"
set xlabel "Nodes distance"
set ylabel "Number of messages per sec on the entire cluster"
set xrange [0:30]
set yrange [0:500]
set label "10.945" at 1.1,10.945
set label "11.055" at 2.1,11.055
set label "11.056" at 3.1,11.056
plot "fileadd10.txt" using 1:2:3 with yerrorbars
