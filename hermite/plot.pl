#!/usr/bin/perl -w
# Prepares data for gnuplot
# Usage: plot.pl [-h0 | -h1 | -h2] [-m1 | -m1,2]

use strict;
use Getopt::Std;
require "logf.pl";

our ($opt_h, $opt_m);
getopt('hm');
my ($m1, $m2) = split(/,/, $opt_m);

my $Nm = 132;			# number of modes (dimensions)
my $xmin = -4;
my $xmax = 4;
my $xdel = 0.2;

my $x = [(undef) x (1+$Nm)];

if (not defined $m2) {
    for (my $xm = $xmin; $xm <= $xmax; $xm += $xdel) {
	$x->[$m1] = $xm;
	my $logf = 
	    ($opt_h == 0) ? logf0($x) :
	    ($opt_h == 1) ? logf1($x) :
	    ($opt_h == 2) ? logf2($x) :
	    die "h can be 0, 1, or 2.";
	print "$xm\t$logf\n";
    }

} else {
    for (my $xm1 = $xmin; $xm1 <= $xmax; $xm1 += $xdel) {
	$x->[$m1] = $xm1;
	for (my $xm2 = $xmin; $xm2 <= $xmax; $xm2 += $xdel) {
	    $x->[$m2] = $xm2;
	    my $logf = 
		($opt_h == 0) ? logf0($x) :
		($opt_h == 1) ? logf1($x) :
		($opt_h == 2) ? logf2($x) :
		die "h can be 0, 1, or 2.";
	    print "$xm1\t$xm2\t$logf\n";
	}
    }
}
