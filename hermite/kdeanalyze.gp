set style data lines
set xlabel "modes"
set terminal pdf mono dashed fsize 12
set output "kdelogp.pdf"
set ylabel "kde logL"
plot "kdeanalyze.out" using 1:2 notitle with lines
