# Computes log likelihood for standard normal distribution with up to
# second order hermite corrections.
# logf0: standard normal
# logf1: with first order corrections
# logf2: with second order corrections
#
# Any undef entries in the input variable are to be integrated out.

use strict;
require "hermite.pl";

my $minhsum = 0.001;		# for fixing negative hsums
my $pi = 2*atan2(1,0);		# pi = 3.14159265358979
my $log2pi = log(2*$pi);


sub logf0 {
    my ($x) = @_;		# data vector
    my ($sumsq, $xdims) = sumsq($x);
    my $logz = -($xdims/2)*$log2pi;
    my $logf = $logz + (-$sumsq / 2);
    return $logf;
}

sub logf1 {
    my ($x, 			# data vector
	$Nh, 			# max degree of hermite
	$E1) = @_;		# expectation hash
    my $hsum = (1 + hsum1($x, $Nh, $E1));
    if ($hsum < $minhsum) {
	warn "Fixing hsum $hsum -> $minhsum\n";
	$hsum = $minhsum;
    }
    return logf0($x) + log($hsum);
}

sub logf2 {
    my ($x, 			# data vector
	$Nh, 			# max degree of hermite
	$E1, 			# first degree expectations
	$E2) = @_;		# second degree expectations
    my $hsum = (1 + hsum1($x, $Nh, $E1) + hsum2($x, $Nh, $E2));
    if ($hsum < $minhsum) {
	warn "Fixing hsum $hsum -> $minhsum\n";
	$hsum = $minhsum;
    }
    return logf0($x) + log($hsum);
}

sub sumsq {
    my ($x) = @_;
    my $Nm = scalar(@$x);
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
    my ($x, $Nh, $E1) = @_;
    my $Nm = scalar(@$x);
    my $hsum = 0;
    for (my $m = 0; $m < $Nm; $m++) {
	my $xm = $x->[$m];
	next if not defined $xm;
	for (my $h = 3; $h <= $Nh; $h++) {
	    my $expectation = $E1->{$h,$m};
	    die "No exp for $h,$m"
		if not defined $expectation;
	    my $term = $expectation * hpoly($h, $xm) / fact($h);
	    $hsum += $term;
	}
    }
    return $hsum;
}

sub hsum2 {
    my ($x, $Nh, $E2) = @_;
    my $Nm = scalar(@$x);
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
		    my $expectation = $E2->{$h1,$h2,$m1,$m2};
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

1;
