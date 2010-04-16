set style data lines
set xrange [8000:8500]
set yrange [-3:3]
set xlabel "timestep"
set terminal pdf fsize 12
set output "mode01.pdf"
plot "8967b.dat" using 1 title "mode 1" with lines
set output "mode05.pdf"
plot "8967b.dat" using 5 title "mode 5" with lines
set output "mode10.pdf"
plot "8967b.dat" using 10 title "mode 10" with lines
set output "mode50.pdf"
plot "8967b.dat" using 50 title "mode 50" with lines
