set style data lines
set terminal pdf mono dashed fsize 8 size 3.2,2.24
set output "f1histogram.pdf"
set xtics 2
set ytics 0.25
set yrange [-0.01:]
set xlabel 'delta r1'
set ylabel 'frequency'
plot "f1histogram.out" using 1:4 title "mode1" with impulses lt 1 lw -1, "f1histogram.out" using 1:2 title "f0" lt 3 lw 5, "f1histogram.out" using 1:3 title "f1" lt 2 lw 5
