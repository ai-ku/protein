#!/usr/bin/perl -w
# Compute hermite expectations for single modes

use strict;
require "hermite.pl";
my $Nh = 17;			# max degree of hermite
my $Nt;				# number of time steps
my $Nm;				# number of modes (dimensions)

warn "Reading mode data from stdin...\n";
my @Xtm;			# mode data
while(<>) {
    my @x = split;
    $Nm = scalar(@x) if not defined $Nm;
    die unless scalar(@x) == $Nm;
    push @Xtm, \@x;
    $Nt++;
}

warn "Read $Nt time steps with $Nm modes.\n";

warn "Computing xm^n expectations...\n";
my @Xmn;			# expectations of xm^n
for (my $m = 0; $m < $Nm; $m++) {
    for (my $n = 0; $n <= $Nh; $n++) {
	my $sum = 0;
	for (my $t = 0; $t < $Nt; $t++) {
	    $sum += expt($Xtm[$t][$m], $n);
	}
	$Xmn[$m][$n] = $sum / $Nt;
    }
}

warn "Computing hermite polynomials...\n";
for (my $h = 0; $h <= $Nh; $h++) { # h = degree of hermite
    my $H = hermite($h);
    for (my $m = 0; $m < $Nm; $m++) { # m = index of mode
	my $sum = 0;
	for (my $n = 0; $n <= $#{$H}; $n++) { # n = index of polynomial
	    $sum += $H->[$n] * $Xmn[$m][$n];
	}
	print "$h\t$m\t$sum\n";
    }
}
