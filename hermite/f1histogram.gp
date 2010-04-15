set terminal pdf fsize 9
set output "f1histogram.pdf"
plot "src/f1histogram.out" using 1:2 title "f0" with lines, "src/f1histogram.out" using 1:3 title "f1" with lines, "src/f1histogram.out" using 1:4 title "mode1" with impulses
