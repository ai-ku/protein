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
set terminal pdf mono fsize 12 size 5,5
set size square
set xlabel 'mode1'
set ylabel 'mode2'
set output 'f0contour.pdf'
plot 'f0contour.dat' title 'f0' with lines, '8967b.tst.dat' using 1:2 title 'data' with points
set output 'f1contour.pdf'
plot 'f1contour.dat' title 'f1' with lines, '8967b.tst.dat' using 1:2 title 'data' with points
set output 'f2contour.pdf'
plot 'f2contour.dat' title 'f2' with lines, '8967b.tst.dat' using 1:2 title 'data' with points
set output 'kdecontour.pdf'
plot 'kdecontour.dat' title 'kde' with lines, '8967b.tst.dat' using 1:2 title 'data' with points
