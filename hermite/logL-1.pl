#!/usr/bin/perl -w
# Compute log likelihood for standard normal distribution

use strict;
use Data::Dumper;
$Data::Dumper::Indent = 0;

my $Nh = 17;			# max degree of hermite
my $Nm = 132;			# number of modes
my $Nt = 501;			# number of time snapshots
my @M;				# mode data
my @E;				# expectations

my @hermite_cache;
my @fact_cache;


warn "Reading mode data...\n";

for (my $m = 1; $m <= $Nm; $m++) { # m = index of mode
    open(FP, "Raw/hermite$m.dat") or die $!;
    my @data = <FP>;
    die unless 501 == @data;
    $M[$m] = \@data;
    close(FP);
}

warn "Reading expectations...\n";

open(FP, "one.out") or die $!;
while(<FP>) {
    my ($h, $m, $e) = split;
    $E[$h][$m] = $e;
}
close(FP);

warn "Computing likelihood...\n";

my $logL = 0;			# log likelihood
my $pi = 2*atan2(1,0);
my $logZ = (-$Nm/2) * log(2*$pi); # normalization constant (log)

for (my $t = 0; $t < $Nt; $t++) {
    my $sumsq = 0;
    my $hsum = 1;		# hermite terms
    for (my $m = 1; $m <= $Nm; $m++) {
	my $rt = $M[$m][$t];
	$sumsq += $rt*$rt;

	for (my $h = 3; $h <= $Nh; $h++) {
	    my $term = 1/fact($h);
	    $term *= $E[$h][$m];
	    $term *= poly(hermite($h), $rt);
	    $hsum += $term;
	}
    }
    warn "t=$t\tsumsq=$sumsq\thsum=$hsum\n";
    next if $hsum <= 0;
    $logL += $logZ + (-$sumsq / 2) + log($hsum);
}

print "$logL\n";



sub hermite {			# returns coefficients of hermite polynomial
    # H0(x) = 1, H1(x) = x, H[p+1](x) = x Hp(x) - p H[p-1](x)

    my ($h) = @_;		# degree of hermite
    my $H = $hermite_cache[$h];

    if (not defined $H) {
	$H = [];		# polynomial coefficient array
	if ($h < 0) {
	    die;
	} elsif ($h == 0) {
	    $H = [1];
	} elsif ($h == 1) {
	    $H = [0, 1];
	} else {
	    my @H1 = @{hermite($h - 1)};
	    my @H2 = @{hermite($h - 2)};
	    unshift @H1, 0;	# multiply by x
	    $_ *= (1 - $h) for @H2;
	    for (my $i = 0; $i <= $#H1; $i++) {
		$H->[$i] = $H1[$i] + ($H2[$i] or 0);
	    }
	}
	$hermite_cache[$h] = $H;
    }
    return $H;
}

sub fact {
    my ($n) = @_;
    my $f = $fact_cache[$n];
    if (not defined $f) {
	if ($n < 0) {
	    die;
	} elsif ($n == 0) {
	    $f = 1;
	} else {
	    $f = $n * fact($n-1);
	}
    }
    return $f;
}

sub poly {
    my ($coeff, $x) = @_;
    my $poly = 0;
    for (my $i = 0; $i <= $#{$coeff}; $i++) {
	$poly += $coeff->[$i] * expt($x, $i);
    }
    return $poly;
}

sub expt {
    my ($x, $n) = @_;
    my $xx = ($x >= 0 ? $x : -$x);
    my $ans = exp($n * log($xx));
    $ans = -$ans if (($x < 0) and ($n % 2));
    return $ans;
}
