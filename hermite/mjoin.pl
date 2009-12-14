#!/usr/bin/perl -w
use strict;

my $Nm = 132;
my @data;

for (my $i = 1; $i <= $Nm; $i++) {
    open(FP, "mode$i.dat") or die $!;
    my @mode = <FP>;
    close(FP);
    s/\s+//g for @mode;
    push @data, \@mode;
}

my $Nt = scalar(@{$data[0]});

for (my $t = 0; $t < $Nt; $t++) {
    for (my $m = 0; $m < $Nm; $m++) {
	print $data[$m][$t];
	print ($m == $Nm-1 ? "\n" : "\t");
    }
}
