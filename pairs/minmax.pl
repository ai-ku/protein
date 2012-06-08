#!/usr/bin/perl -w
use strict;
my @hi;
my @lo;
my @thi;
my @tlo;

while(<>) {
    my @a = split;
    for (my $i = 0; $i <= $#a; $i++) {
	if (not defined $lo[$i] or
	    $a[$i] < $lo[$i]) {
	    $lo[$i] = $a[$i];
	    $tlo[$i] = $.;
	}
	if (not defined $hi[$i] or
	    $a[$i] > $hi[$i]) {
	    $hi[$i] = $a[$i];
	    $thi[$i] = $.;
	}
    }
}

for (my $i = 0; $i <= $#lo; $i++) {
    print "$i\t$lo[$i]\t$tlo[$i]\t$hi[$i]\t$thi[$i]\n";
}
