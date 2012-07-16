set style data lines
set xrange [8000:8500]
set yrange [-3:3]
set terminal pdf mono fsize 7 size 1.6,1.12 

set xtics 250
set ytics 3
set style data lines
set key samplen 0 bottom left

set output "mode01.pdf"
set xlabel 'time'
set ylabel 'delta r'
plot "8967b.dat" using 1 title 'mode 1'

set output "mode05.pdf"
unset ylabel
plot "8967b.dat" using 5 title 'mode 5'

set output "mode10.pdf"
plot "8967b.dat" using 10 title 'mode 10'

set output "mode50.pdf"
plot "8967b.dat" using 50 title 'mode 50'

