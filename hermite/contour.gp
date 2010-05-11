set xrange [-3:3]
set yrange [-3:3]
set zrange [0:]
unset surface
set contour
set cntrparam levels incremental 0,.025,.2
set table 'f0contour.dat'
splot 'f0hist12.out'
unset table
set table 'f1contour.dat'
splot 'f1hist12.out'
unset table
set table 'f2contour.dat'
splot 'f2hist12.out'
unset table
set table 'kdecontour.dat'
splot 'kdecontour.out'
unset table
set terminal pdf enhanced mono fsize 16 size 5,5
set size square
#set xlabel 'mode1'
#set ylabel 'mode2'
set xtics 3
set ytics 3
set xlabel '{/Symbol D}r_1'
set ylabel '{/Symbol D}r_2'

set output 'f0contour.pdf'
plot 'f0contour.dat' with lines title 'f_0', '8967b.tst.dat' using 1:2 notitle with points

set output 'f1contour.pdf'
plot 'f1contour.dat' with lines title 'f_1', '8967b.tst.dat' using 1:2 notitle with points

set output 'f2contour.pdf'
plot 'f2contour.dat' with lines title 'f_2', '8967b.tst.dat' using 1:2 notitle with points

set output 'kdecontour.pdf'
plot 'kdecontour.dat' with lines title 'KDE', '8967b.tst.dat' using 1:2 notitle with points
