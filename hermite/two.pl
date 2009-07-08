#!/usr/bin/perl -w
# Compute hermite expectations for mode pairs

use strict;
use Data::Dumper;
$Data::Dumper::Indent = 0;

my $Nm = 132;			# number of modes
my $Nh = 17;			# max degree of hermite
my @M;				# mode data
my %E;				# expectations

for (my $m = 1; $m <= $Nm; $m++) { # m = index of mode
    open(FP, "Raw/hermite$m.dat") or die $!;
    my @data = <FP>;
    $M[$m] = \@data;
    close(FP);
}

for (my $h1 = 0; $h1 <= $Nh; $h1++) { # h1 = degree of first hermite
    my $H1 = hermite($h1);
    for (my $h2 = 0; $h2 <= $Nh-$h1; $h2++) { # h2 = degree of second hermite
	my $H2 = hermite($h2);
	print STDERR "$h1\t$h2\n";
	for (my $m1 = 1; $m1 <= $Nm; $m1++) { # m1 = index of first mode
	    for (my $m2 = 1; $m2 <= $Nm; $m2++) { # m2 = index of second mode
		my $sum = 0;
		for (my $i1 = 0; $i1 <= $#{$H1}; $i1++) { # index into first polynomial
		    next if $H1->[$i1] == 0;
		    for (my $i2 = 0; $i2 <= $#{$H2}; $i2++) { # index into second polynomial
			next if $H2->[$i2] == 0;
			$sum += $H1->[$i1] * $H2->[$i2] * expectation($m1, $i1, $m2, $i2);
		    }
		}
		print "$h1\t$h2\t$m1\t$m2\t$sum\n";
	    }
	}
    }
}

sub expectation {
    my ($m1, $i1, $m2, $i2) = @_;
    my $key = "$m1,$i1,$m2,$i2";
    if (not defined $E{$key}) {
	my $sum = 0;
	my $len = @{$M[$m1]};
	for (my $i = 0; $i < $len; $i++) {
	    my $x1 = $M[$m1][$i];
	    my $x2 = $M[$m2][$i];
	    $sum += expt($x1, $i1) * expt($x2, $i2);
	}
	$E{$key} = $sum / $len;
    }
    return $E{$key};
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
