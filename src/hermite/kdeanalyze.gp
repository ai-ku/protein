set style data lines
set xlabel "modes"
set terminal pdf mono dashed fsize 12
set output "kdelogp.pdf"
set ylabel "kde logL"
set yrange [-188:]
set style data lines
plot "kde0.out" using 2:3 title '0', "kde1.out" using 2:3 title '1000', "kde2.out" using 2:3 title '2000', "kde3.out" using 2:3 title '3000', "kde8.out" using 2:3 title '7971'
