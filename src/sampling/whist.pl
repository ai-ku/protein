#!/usr/bin/perl -w
# Draw a weighted histogram based on importance sampling

use strict;
my $BINS=50;
my ($min, $max, @data, @weight);
while(<>) {
    my ($w, $d) = split;
    die if not defined $w;
    if ($d eq '') { $d = $w; $w = 1; }
    push @data, $d;
    push @weight, $w;
    $min = $d if not defined $min or $d < $min;
    $max = $d if not defined $max or $d > $max;
}

my $step = ($max - $min) / $BINS;
my @hist;
for (my $i = 0; $i <= $#data; $i++) {
    my $d = $data[$i];
    my $w = $weight[$i];
    my $bucket = int(($d - $min) / $step);
    $hist[$bucket] += $w;
}

for (my $i = 0; $i <= $#hist; $i++) {
    my $position = $min + $i * $step;
    my $height = $hist[$i];
    $height = 0 if not defined $height;
    print "$position\t$height\n";
}
