#!/usr/bin/perl -w
# Draw a 2D histogram based on weighted instances

use strict;
my $BINS=30;
my ($xmin, $xmax, $ymin, $ymax, @x, @y, @w);
while(<>) {
    my ($w, $x, $y) = split;
    push @w, $w; push @x, $x; push @y, $y;
    $xmin = $x if not defined $xmin or $x < $xmin;
    $xmax = $x if not defined $xmax or $x > $xmax;
    $ymin = $y if not defined $ymin or $y < $ymin;
    $ymax = $y if not defined $ymax or $y > $ymax;
}

my $xstep = ($xmax - $xmin) / $BINS;
my $ystep = ($ymax - $ymin) / $BINS;

my @hist;
for (my $i = 0; $i <= $#w; $i++) {
    my $ix = int(($x[$i] - $xmin) / $xstep);
    my $iy = int(($y[$i] - $ymin) / $ystep);
    $hist[$ix][$iy] += $w[$i];
}

for (my $j = 0; $j < $BINS; $j++) {
    for (my $i = 0; $i < $BINS; $i++) {
	my $x = $xmin + $i * $xstep;
	my $y = $ymin + $j * $ystep;
	my $h = $hist[$i][$j];
	$h = 0 if not defined $h;
	print "$x\t$y\t$h\n";
    }
    print "\n";
}
