# Computes log likelihood for standard normal distribution with up to
# second order hermite corrections.
# logf0: standard normal
# logf1: with first order corrections
# logf2: with second order corrections
#
# Any undef entries in the input variable are to be integrated out.

use strict;
require "hermite.pl";

our ($opt_v);			# verbose option
my $DBG = 0;
my $PI = 2*atan2(1,0);		# pi = 3.14159265358979
my $LOG2PI = log(2*$PI);


sub logf0 {
    my ($x) = @_;		# data vector
    my ($sumsq, $xdims) = sumsq($x);
    my $logz = -($xdims/2)*$LOG2PI;
    my $logf = $logz + (-$sumsq / 2);
    print "LOGF0\t$logf\n" if $opt_v;
    return $logf;
}

sub f0 {
    my ($x) = @_;
    my $logf = logf0($x);
    return exp($logf);
}

sub logf1 {
    my ($x, 			# data vector
	$Nh, 			# max degree of hermite
	$E1) = @_;		# expectation hash
    my $logf0 = logf0($x);
    my $hsum = (1 + hsum1($x, $Nh, $E1));
    print "1+HSUM1\t$hsum\n" if $opt_v;
    return (($hsum > 0) ?
	    ($logf0 + log($hsum)) :
	    undef);
}

sub f1 {
    my ($x, 			# data vector
	$Nh, 			# max degree of hermite
	$E1) = @_;		# expectation hash
    my $f0 = f0($x);
    my $hsum = (1 + hsum1($x, $Nh, $E1));
    return ($f0 * $hsum);
}

sub logf2 {
    my ($x, 			# data vector
	$Nh, 			# max degree of hermite
	$E1, 			# first degree expectations
	$E2) = @_;		# second degree expectations
    my $logf0 = logf0($x);
    my $hsum = (1 + hsum1($x, $Nh, $E1) + hsum2($x, $Nh, $E2));
    print "1+HSUM1+HSUM2\t$hsum\n" if $opt_v;
    return (($hsum > 0) ?
	    ($logf0 + log($hsum)) :
	    undef);
}

sub f2 {
    my ($x, 			# data vector
	$Nh, 			# max degree of hermite
	$E1, 			# first degree expectations
	$E2) = @_;		# second degree expectations
    my $f0 = f0($x);
    my $hsum = (1 + hsum1($x, $Nh, $E1) + hsum2($x, $Nh, $E2));
    return ($f0 * $hsum);
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
    print "SUMSQ\t$sumsq\n" if $opt_v;
    return ($sumsq, $xdims);
}

sub hsum1 {
    my ($x, $Nh, $E1) = @_;
    my $Nm = scalar(@$x);
    my $hsum = 0;
    for (my $m = 0; $m < $Nm; $m++) {
	my $xm = $x->[$m];
	next if not defined $xm;
	my $msum = 0;
	for (my $h = 3; $h <= $Nh; $h++) {
	    my $expectation = $E1->{$h,$m};
	    die "No exp for $h,$m"
		if not defined $expectation;
	    my $term = $expectation * hpoly($h, $xm) / fact($h);
	    $msum += $term;
	}
	print "HSUM1\t$m\t$msum\n" if $opt_v;
	$hsum += $msum;
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
	    my $msum = 0;
	    for (my $h1 = 1; $h1 < $Nh; $h1++) {
		for (my $h2 = 1; $h2 <= $Nh-$h1; $h2++) {
		    next if ($h1 == 1 and $h2 == 1);
		    my $expectation = $E2->{$h1,$h2,$m1,$m2};
		    die "No exp for $h1,$h2,$m1,$m2"
			if not defined $expectation;
		    my $term = $expectation *
			(hpoly($h1, $xm1) / fact($h1)) *
			(hpoly($h2, $xm2) / fact($h2));
		    print "HSUM4\t$m1\t$m2\t$h1\t$h2\t$term\n" if $DBG;
		    $msum += $term;
		}
	    }
	    $hsum += $msum;
	    print "HSUM2\t$m1\t$m2\t$msum\n" if $opt_v;
	}
    }
    return $hsum;
}

sub loadE1 {
    my ($file) = @_;
    my $E1 = {};
    my $Nh = 0;
    warn "Reading first order expectations from $file...\n";
    open(FP, $file) or die $!;
    while(<FP>) {
	my ($h, $m, $e) = split;
	$E1->{$h,$m} = $e;
	$Nh = $h if $h > $Nh;
    }
    close(FP);
    return ($E1, $Nh);
}

sub loadE2 {
    my ($file) = @_;
    my $E2 = {};
    my $Nh = 0;
    warn "Reading second order expectations from $file...\n";
    open(FP, $file) or die $!;
    while(<FP>) {
	my ($h1, $h2, $m1, $m2, $e) = split;
	$E2->{$h1,$h2,$m1,$m2} = $e;
	$Nh = $h1 if $h1 > $Nh;
	$Nh = $h2 if $h2 > $Nh;
    }
    close(FP);
    return ($E2, $Nh);
}

1;
