set   autoscale                        # scale axes automatically
unset log                              # remove any log-scaling
unset label                            # remove any previous labels
set xtic ('10' 1, '50' 2, '100' 3, '500' 4, '1000' 5, '5000' 6, '10000' 7)                          # set xtics automatically
set ytic auto                          # set ytics automatically
set title "Different state interval (5 nodes)"
set xlabel "State interval (ms)"
set ylabel "Convergence Time (ms)"
set xrange [0:10]
set yrange [0:10000]
set label "312" at 1.1,312
set label "451" at 2.1,451
set label "546" at 3.1,546
set label "600" at 4.1,600
set label "857" at 5.1,857
set label "4224" at 6.1,4224
set label "8639" at 7.1,8639
plot "file.txt" using 1:2:3 with yerrorbars
