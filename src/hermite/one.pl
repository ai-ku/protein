#!/usr/bin/perl -w
# Compute hermite expectations for single modes

use strict;
use Getopt::Std;
use PDL;
use PDL::NiceSlice;
require "hermite.pl";

my $Nh_default = 17;
my $Nh;				# max degree of hermite
my $Nt;				# number of time steps
my $Nm;				# number of modes (dimensions)
my $Xmt;			# data matrix

our($opt_h);
getopt('h');
$Nh = (defined $opt_h ? $opt_h : $Nh_default);
warn "Maximum hermite degree = $Nh\n";

warn "Reading mode data from stdin...\n";
my @data;
while(<>) {
    push @data, pdl(split);
}
$Xmt = pdl(@data);
($Nm, $Nt) = dims($Xmt);
warn "Read $Nt time steps with $Nm modes.\n";

warn "Computing xm^n expectations...\n";
my @Xmn;			# expectations of xm^n
for (my $m = 0; $m < $Nm; $m++) {
    for (my $n = 0; $n <= $Nh; $n++) {
	$Xmn[$m][$n] = avg($Xmt($m,:) ** $n);
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
