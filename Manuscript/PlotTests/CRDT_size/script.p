set   autoscale                        # scale axes automatically
unset log                              # remove any log-scaling
unset label                            # remove any previous labels
set xtic ('5' 1, '10' 2, '20' 3)                          # set xtics automatically
set ytic auto                          # set ytics automatically
set title "Different cluster size (nodes add 10 elements each)"
set xlabel "Cluster Size (# nodes)"
set ylabel "Number of messages per sec"
set xrange [0:4]
set yrange [5000:20000]
set label "10.945" at 1.1,10.945
set label "54.56" at 2.1,54.56
set label "187.12" at 3.1,187.12
plot "file.txt" using 1:2:3 with yerrorbars
