#!/usr/bin/perl -w
# Compute hermite expectations for mode pairs

use strict;
use PDL;
use PDL::NiceSlice;
require "hermite.pl";

my $Nh = 17;			# max degree of hermite
my $Nt;				# number of time steps
my $Nm;				# number of modes (dimensions)
my $Xmt;			# data matrix

warn "Reading mode data from stdin...\n";
my @data;
while(<>) {
    push @data, pdl(split);
}
$Xmt = pdl(@data);
($Nm, $Nt) = dims($Xmt);
warn "Read $Nt time steps with $Nm modes.\n";

warn "Computing xm1^n1 * xm2^n2 expectations...\n";
my %E2;
for (my $m1 = 0; $m1 < $Nm; $m1++) { # m1 = index of first mode
    my $xm1 = $Xmt($m1,:);
    for (my $m2 = 0; $m2 < $m1; $m2++) { # m2 = index of second mode
	my $xm2 = $Xmt($m2,:);
	warn "$m1\t$m2\n";
	for (my $n1 = 0; $n1 < $Nh; $n1++) { # n1 = power of first mode
	    for (my $n2 = 0; $n2 <= $Nh-$n1; $n2++) { # n2 = power of second mode
		$E2{$m1,$n1,$m2,$n2} = avg(($xm1 ** $n1) * ($xm2 ** $n2));
	    }
	}
    }
}

warn "Computing hermite polynomials...\n";
for (my $h1 = 1; $h1 < $Nh; $h1++) { # h1 = degree of first hermite
    my $H1 = hermite($h1);
    for (my $h2 = 1; $h2 <= $Nh-$h1; $h2++) { # h2 = degree of second hermite
	next if ($h1 == 1 and $h2 == 1);
	my $H2 = hermite($h2);
	warn "$h1\t$h2\n";
	for (my $m1 = 0; $m1 < $Nm; $m1++) { # m1 = index of first mode
	    for (my $m2 = 0; $m2 < $m1; $m2++) { # m2 = index of second mode
		my $sum = 0;
		for (my $n1 = 0; $n1 <= $#{$H1}; $n1++) { # index into first polynomial
		    next if $H1->[$n1] == 0;
		    for (my $n2 = 0; $n2 <= $#{$H2}; $n2++) { # index into second polynomial
			next if $H2->[$n2] == 0;
			$sum += $H1->[$n1] * $H2->[$n2] * $E2{$m1,$n1,$m2,$n2};
		    }
		}
		print "$h1\t$h2\t$m1\t$m2\t$sum\n";
	    }
	}
    }
}

