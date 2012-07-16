set style data lines
set xlabel "modes"
set terminal pdf mono dashed fsize 12
set output "f2logp.pdf"
set ylabel "f2 logL"
plot "f2analyze.out" using 1:2 notitle with lines
set output "f2negp.pdf"
set ylabel "f2 negative"
plot "f2analyze.out" using 1:($3/996) notitle with lines
