# Computes log likelihood for standard normal distribution with up to
# second order hermite corrections.
# logf0: standard normal
# logf1: with first order corrections
# logf2: with second order corrections
#
# Any undef entries in the input variable are to be integrated out.

use strict;
require "hermite.pl";

my $Nh = 17;			# max degree of hermite
my $Nm = 132;			# number of modes (dimensions)
my @M;				# mode data
my @E;				# expectations
my %E2;				# second order expectations
my $minhsum = 0.001;		# for fixing negative hsums

my $pi = 2*atan2(1,0);		# pi = 3.1416
my $log2pi = log(2*$pi);
# my $logZ = (-$Nm/2) * log(2*$pi); # normalization constant (log)

sub logf0 {
    my ($x) = @_;
    my ($sumsq, $xdims) = sumsq($x);
    my $logz = -($xdims/2)*$log2pi;
    my $logf = $logz + (-$sumsq / 2);
    return $logf;
}

sub logf1 {
    my ($x) = @_;
    my $hsum = (1 + hsum1($x));
    if ($hsum < $minhsum) {
	$hsum = $minhsum;
	warn "Fixing hsum $hsum -> $minhsum\n";
    }
    return logf0($x) + log($hsum);
}

sub logf2 {
    my ($x) = @_;
    my $hsum = (1 + hsum1($x) + hsum2($x));
    if ($hsum < $minhsum) {
	$hsum = $minhsum;
	warn "Fixing hsum $hsum -> $minhsum\n";
    }
    return logf0($x) + log($hsum);
}

sub sumsq {
    my ($x) = @_;
    my $sumsq = 0;
    my $xdims = 0;
    for (my $m = 0; $m < $Nm; $m++) {
	my $xm = $x->[$m];
	next if not defined $xm;
	$sumsq += $xm*$xm;
	$xdims++;
    }
    return ($sumsq, $xdims);
}

sub hsum1 {
    loadE() if not @E;
    my ($x) = @_;
    my $hsum = 0;
    for (my $m = 0; $m < $Nm; $m++) {
	my $xm = $x->[$m];
	next if not defined $xm;
	for (my $h = 3; $h <= $Nh; $h++) {
	    my $expectation = $E[$h][$m];
	    die "No exp for $h,$m"
		if not defined $expectation;
	    my $term = $expectation * hpoly($h, $xm) / fact($h);
	    $hsum += $term;
	}
    }
    return $hsum;
}

sub hsum2 {
    loadE2() if not %E2;
    my ($x) = @_;
    my $hsum = 0;
    for (my $m1 = 0; $m1 < $Nm; $m1++) {
	my $xm1 = $x->[$m1];
	next if not defined $xm1;
	for (my $m2 = 0; $m2 < $m1; $m2++) {
	    my $xm2 = $x->[$m2];
	    next if not defined $xm2;
	    for (my $h1 = 1; $h1 < $Nh; $h1++) {
		for (my $h2 = 1; $h2 <= $Nh-$h1; $h2++) {
		    next if ($h1 == 1 and $h2 == 1);
		    my $expectation = $E2{$h1,$h2,$m1,$m2};
		    die "No exp for $h1,$h2,$m1,$m2"
			if not defined $expectation;
		    my $term = $expectation *
			(hpoly($h1, $xm1) / fact($h1)) *
			(hpoly($h2, $xm2) / fact($h2));
		    $hsum += $term;
		}
	    }
	}
    }
    return $hsum;
}

sub loadE {
    warn "Reading first order expectations...\n";
    open(FP, "one.out") or die $!;
    while(<FP>) {
	my ($h, $m, $e) = split;
	$E[$h][$m] = $e;
    }
    close(FP);
}

sub loadE2 {
    warn "Reading second order expectations...\n";
    open(FP, "zcat two.out.gz|") or die $!;
    while(<FP>) {
	my ($h1, $h2, $m1, $m2, $e) = split;
	$E2{$h1,$h2,$m1,$m2} = $e;
    }
    close(FP);
}

1;
