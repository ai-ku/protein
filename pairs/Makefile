all:

hermite.tgz: README Makefile hermite.pl one.pl two.pl logf.pl logf_test.pl 
	tar cvzf $@ $^

f0contour.dat f1contour.dat f2contour.dat kdecontour.dat f0contour.pdf f1contour.pdf f2contour.pdf kdecontour.pdf: contour.gp f0hist12.out f1hist12.out f2hist12.out kdecontour.out
	gnuplot contour.gp

kdecontour.out: kdecontour.r
	./kdecontour.r | perl -lne 'if(/^\"\d/){split;shift(@_);print "" if $$y!=$$_[1]; $$y=$$_[1];print(join(" ",@_));}' > $@

f0hist12.out: plot.pl
	./plot.pl -m1,2 > $@

f1hist12.out: plot.pl
	./plot.pl -1 8967b.trn.one -m1,2 > $@

f2hist12.out: plot.pl
	./plot.pl -1 8967b.trn.one -2 8967b.trn.two -m1,2 > $@

f1histogram.pdf: f1histogram.gp f1histogram.out
	gnuplot f1histogram.gp

f1histogram.out: f1histogram.pl
	./f1histogram.pl -1 8967b.trn.one -m1 8967b.tst.dat > f1histogram.out

f2logp.pdf f2negp.pdf: f2analyze.gp f2analyze.out
	gnuplot f2analyze.gp

f2analyze.out: ./f1analyze.pl f2.out
	$^ > $@

f1logp.pdf f1negp.pdf: f1analyze.gp f1analyze.out
	gnuplot f1analyze.gp

f1analyze.out: ./f1analyze.pl f1.out
	$^ > $@

f1.out: ./f1.sh
	$^ > $@

f2.out: ./f2.sh
	$^ > $@

mode01.pdf mode05.pdf mode10.pdf mode50.pdf: timeplots.gp 8967b.dat
	gnuplot timeplots.gp

%.one: %.dat one.pl hermite.pl
	one.pl -h 17 $*.dat > $@

%.two: %.dat two.pl hermite.pl
	two.pl -h 17 $*.dat > $@

%.f0: %.dat logf_test.pl logf.pl hermite.pl
	logf_test.pl -v $*.dat

%.f1: %.dat %.one logf_test.pl logf.pl hermite.pl
	logf_test.pl -v -1 $*.one $*.dat

%.f2: %.dat %.one %.two logf_test.pl logf.pl hermite.pl
	logf_test.pl -v -1 $*.one -2 $*.two $*.dat

.PRECIOUS: %.one %.two
