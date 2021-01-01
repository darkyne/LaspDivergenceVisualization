set   autoscale                        # scale axes automatically
unset log                              # remove any log-scaling
unset label                            # remove any previous labels
set xtic ('100' 1, '1000' 2, '10000' 3)                          # set xtics automatically
set ytic auto                          # set ytics automatically
set title "Convergence time (10 nodes) for different CRDT size"
set xlabel "Size (# elements)"
set ylabel "Convergence time (ms)"
set xrange [0:4]
set yrange [5000:15000]
set label "12440" at 1.1,12440
set label "13706" at 2.1,13706
set label "14764" at 3.1,14764
plot "file.txt" using 1:2:3 with yerrorbars and labels
