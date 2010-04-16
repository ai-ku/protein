set style data lines
set terminal pdf mono dashed fsize 9
set output "f1histogram.pdf"
plot "f1histogram.out" using 1:2 title "f0" lt 2, "f1histogram.out" using 1:3 title "f1" lt -1, "f1histogram.out" using 1:4 title "mode1" with impulses lt 1
