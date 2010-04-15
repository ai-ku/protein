set style data lines
set xlabel "modes"
set terminal pdf fsize 9
set output "f1logp.pdf"
plot "f1analyze.out" using 1:2 title "f1 logL" with lines
set output "f1negp.pdf"
plot "f1analyze.out" using 1:3 title "f1 negative" with lines
