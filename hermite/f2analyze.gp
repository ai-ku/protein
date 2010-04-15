set style data lines
set xlabel "modes"
set terminal pdf fsize 9
set output "f2logp.pdf"
plot "src/f2analyze.out" using 1:2 title "f2 logL" with lines
set output "f2negp.pdf"
plot "src/f2analyze.out" using 1:3 title "f2 negative" with lines
