export PATH := ../hermite:${PATH}
export PERL5LIB := ../hermite:${PERL5LIB}
NDIM=2184
NSAMPLE=3000

all:

sampledist: sampledist.c
	gcc -std=gnu99 -O2 sampledist.c -lm -lgsl -lgslcblas -o sampledist

f1gen_dr.dat: f1gen.pl
	f1gen.pl -1 1VOM_10_dr.one -n${NSAMPLE} > $@

f0gen_dr.dat:
	perl -MMath::Random -e 'for (1..${NSAMPLE}){print join("\t", random_normal(${NDIM}))."\n";}' > $@

# The above two files were converted into dR by Onur.
# dR files have 730 x coordinates followed by 730 y coordinates etc.

# The following computes the sum of x, y, z variances of each residue

%_dR.var: residue_variance.pl %_dR.dat
	$^ > $@

f1-f0.kl: sampledist.pl f1gen_dR.dat f0gen_dR.dat
	$^ > $@

md-f0.kl: sampledist.pl 1VOM_10_dR.dat f0gen_dR.dat
	$^ > $@

md-f1.kl: sampledist.pl 1VOM_10_dR.dat f1gen_dR.dat
	$^ > $@


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

%.f1hist: %.one %.dat
	f1histogram.pl -1 $*.one -m1 $*.dat > $@

f2logp.pdf f2negp.pdf: f2analyze.gp f2analyze.out
	gnuplot f2analyze.gp

f2analyze.out: ./f1analyze.pl f2.out
	$^ > $@

f1logp.pdf f1negp.pdf: f1analyze.gp f1analyze.out
	gnuplot f1analyze.gp

f1analyze.out: ./f1analyze.pl f1.out
	$^ > $@

%.one: %.dat
	one.pl -h 25 $*.dat > $@

%.two: %.dat
	two.pl -h 25 $*.dat > $@

%.f0.err: %.dat
	logf_test.pl $< 2> $@

%.f0: %.f0.err
	perl -ne 'print if s/.*logp=//' $< > $@

%.f1.err: %.dat %.one
	logf_test.pl -1 $*.one $*.dat 2> $@

%.f1: %.f1.err
	perl -ne 'print if s/.*logp=//' $< > $@

%.f2.err: %.dat %.one %.two
	logf_test.pl -1 $*.one -2 $*.two $*.dat 2> $@

%.f2: %.f2.err
	perl -ne 'print if s/.*logp=//' $< > $@

f0-sample.dat: 
	perl -MMath::Random -e 'for (1..${NSAMPLE}){print join("\t", random_normal(${NDIM}))."\n";}' > $@
	ln -s 8759.one f0-sample.one; touch f0-sample.one
	ln -s 8759.two f0-sample.two; touch f0-sample.two

%.wdat01: %.f0 %.f1 %.dat
	join.pl $^ | perl -lane 'next if $$F[0] eq "undef" or $$F[1] eq "undef"; print join("\t", exp($$F[1]-$$F[0]), @F[2..$$#F]);' > $@

%.hist01: %.wdat01
	whist.pl $< > $@

%.cntr01: %.wdat01
	whist2d.pl $< > $@

.PRECIOUS: %.one %.two %.f0.err %.f1.err %.f2.err %.wdat01
