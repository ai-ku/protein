#!/usr/bin/perl -w
use strict;
use PDL;

my $n;
my $sum;
my $sumsq;

while(<>) {
    my $x = pdl(split);
    $n++;
    $sum += $x;
    $sumsq += $x*$x;
}

my $var = $sumsq / $n - ($sum * $sum) / ($n * $n);

my $dims = nelem($var) / 3;
for (my $i = 0; $i < $dims; $i++) {
    my $ivar = at($var, $i) + at($var, $i+$dims) + at($var, $i+2*$dims);
    print "$ivar\n";
}
