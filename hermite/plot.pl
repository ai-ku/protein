#!/usr/bin/perl -w
# Prepares data for gnuplot
# Usage: plot.pl [-1 file | -2 file] [-m1 | -m1,2]

use strict;
use Getopt::Std;
require "logf.pl";

our ($opt_1, $opt_2, $opt_m);
getopt('12m');
my ($m1, $m2) = split(/,/, $opt_m);

warn "Reading expectation data...\n" if defined $opt_1;
my ($Nh, $nh, $E1, $E2);
$Nh = $nh = 0;			# max hermite degree
($E1, $nh) = loadE1($opt_1) if defined $opt_1;
$Nh = $nh if $nh > $Nh;
($E2, $nh) = loadE2($opt_2) if defined $opt_2;
$Nh = $nh if $nh > $Nh;

my $Nm = 132;			# number of modes (dimensions)
my $xmin = -4;
my $xmax = 4;
my $xdel = 0.2;

my $x = [(undef) x (1+$Nm)];

if (not defined $m2) {
    for (my $xm = $xmin; $xm <= $xmax; $xm += $xdel) {
	$x->[$m1] = $xm;
	my $f = 
	    (defined $opt_2) ? f2($x, $Nh, $E1, $E2) :
	    (defined $opt_1) ? f1($x, $Nh, $E1) :
	    f0($x);
	print "$xm\t$f\n";
    }

} else {
    for (my $xm2 = $xmin; $xm2 <= $xmax; $xm2 += $xdel) {
	$x->[$m2] = $xm2;
	for (my $xm1 = $xmin; $xm1 <= $xmax; $xm1 += $xdel) {
	    $x->[$m1] = $xm1;
	    my $f = 
		(defined $opt_2) ? f2($x, $Nh, $E1, $E2) :
		(defined $opt_1) ? f1($x, $Nh, $E1) :
		f0($x);
	    print "$xm1\t$xm2\t$f\n";
	}
	print "\n";
    }
}
