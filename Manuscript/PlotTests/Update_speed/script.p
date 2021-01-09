set   autoscale                        # scale axes automatically
unset log                              # remove any log-scaling
unset label                            # remove any previous labels
set xtic ('0' 0, '5' 5, '10' 10, '15' 15, '20' 20, '25' 25, '30' 30, '35' 35, '40' 40, '45' 45)                          # set xtics automatically
set ytic auto                          # set ytics automatically
set title "Elements continuously added (at 2/sec) with 5 nodes"
set xlabel "Number of the added element"
set ylabel "Convergence Time (ms)"
set xrange [0:50]
set yrange [5000:20000]
set label "8651" at -1.5,8651
set label "465" at 15.5,465
set label "10335" at 14.1,10335
set label "481" at 35.5,481
set label "10291" at 34,10291
plot "file.txt" using 1:2:3 with yerrorbars
