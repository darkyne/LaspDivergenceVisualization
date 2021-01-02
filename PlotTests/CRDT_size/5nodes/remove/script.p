set   autoscale                        # scale axes automatically
unset log                              # remove any log-scaling
unset label                            # remove any previous labels
set xtic ('10' 1.5, '100' 3.5, '1000' 5.5)                          # set xtics automatically
set ytic auto                          # set ytics automatically
set title "Different CRDT size (5 nodes)"
set xlabel "Number of elements added/removed by each node"
set ylabel "Convergence Time (ms)"
set xrange [0:10]
set yrange [5000:20000]
plot "file.txt" using 1:2:3 with yerrorbars
