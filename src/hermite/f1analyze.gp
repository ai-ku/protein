set style data lines
set xlabel "modes"
set terminal pdf mono dashed fsize 12
set output "f1logp.pdf"
set ylabel "f1 logL"
plot "f1analyze.out" using 1:2 notitle with lines
set output "f1negp.pdf"
set ylabel "f1 negative"
plot "f1analyze.out" using 1:($3/996) notitle with lines
