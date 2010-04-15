#!/usr/bin/perl -w
# Usage: f1histogram.pl -1 file.one -m N < data
# file.one is the expectations, N is the mode number, data is the raw data file
#
# Prepares gnuplot data file with four columns:
# 1. The mode value from -4 to 4
# 2. f0
# 3. f1
# 4. frequency data

use strict;
use Getopt::Std;
require "logf.pl";

our ($opt_1, $opt_m);
getopt('1m');
my $m1 = ($opt_m ? $opt_m : 1);
die if not defined $opt_1;

warn "Reading expectation data...\n" if defined $opt_1;
my ($Nh, $E1);
($E1, $Nh) = loadE1($opt_1) if defined $opt_1;

my $Nm = 132;			# number of modes (dimensions)
my $xmin = -4;
my $xmax = 4;
my $xdel = 0.1;
my $imin = -40;
my $imax = 40;

my @hist;
my $ndata;

while(<>) {
    my @r = split;
    my $r = $r[$m1 - 1];
    my $bucket = ($r - $xmin) / $xdel;
    $bucket = 0 if $bucket < 0;
    $hist[$bucket]++;
    $ndata++;
}

my $x = [(undef) x (1+$Nm)];
my $h = 0;

for (my $i = $imin; $i <= $imax; $i++) {
    my $xm = $i * $xdel;
    $x->[$m1 - 1] = $xm;
    my $f0 = f0($x);
    my $f1 = f1($x, $Nh, $E1);
    $hist[$h] += 0;
    my $fx = $hist[$h] / ($ndata * $xdel);
    print "$xm\t$f0\t$f1\t$fx\n";
    $h++;
}

