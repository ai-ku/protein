#!/usr/bin/perl -w
# Compute hermite expectations for single modes

use strict;
use Data::Dumper;
$Data::Dumper::Indent = 0;

my $Nm = 132;			# number of modes
my $Nh = 17;			# max degree of hermite
my @E;				# expectations
my @M;				# mode data

for (my $m = 1; $m <= $Nm; $m++) { # m = index of mode
    open(FP, "Raw/hermite$m.dat") or die $!;
    my @data = <FP>;
    $M[$m] = \@data;
    close(FP);
}

for (my $h = 0; $h <= $Nh; $h++) { # h = degree of hermite
    my $H = hermite($h);
    for (my $m = 1; $m <= $Nm; $m++) { # m = index of mode
	my $sum = 0;
	for (my $i = 0; $i <= $#{$H}; $i++) { # i = index of polynomial
	    $sum += $H->[$i] * expectation($m, $i);
	}
	print "$h\t$m\t$sum\n";
    }
}

sub expectation {
    my ($m, $i) = @_;
    if (not defined $E[$m][$i]) {
	my $sum = 0;
	$sum += expt($_, $i) for @{$M[$m]};
	$E[$m][$i] = $sum / scalar(@{$M[$m]});
    }
    return $E[$m][$i];
}

sub hermite {
    # H0(x) = 1, H1(x) = x, H[p+1](x) = x Hp(x) - p H[p-1](x)

    my ($h) = @_;		# degree of hermite
    my $H = [];			# polynomial coefficient array

    if ($h < 0) {
	die;
    } elsif ($h == 0) {
	$H = [1];
    } elsif ($h == 1) {
	$H = [0, 1];
    } else {
	my $H1 = hermite($h - 1);
	my $H2 = hermite($h - 2);
	unshift @$H1, 0;	# multiply by x
	$_ *= (1 - $h) for @$H2;
	for (my $i = 0; $i <= $#{$H1}; $i++) {
	    $H->[$i] = $H1->[$i] + ($H2->[$i] or 0);
	}
    }
    return $H;
}

sub expt {
    my ($x, $n) = @_;
    my $xx = ($x >= 0 ? $x : -$x);
    my $ans = exp($n * log($xx));
    $ans = -$ans if (($x < 0) and ($n % 2));
    return $ans;
}
