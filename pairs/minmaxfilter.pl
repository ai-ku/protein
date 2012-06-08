#!/usr/bin/perl -w
use strict;

my $limit = shift;
$limit = 4 if not defined $limit;

sub min { my $min; for (@_) { if (not defined $min or $_ < $min) { $min = $_; } } return $min; }
sub max { my $max; for (@_) { if (not defined $max or $_ > $max) { $max = $_; } } return $max; }

while(<>) {
    my @a = split;
    my $min = min(@a);
    next if $min < -$limit;
    my $max = max(@a);
    next if $max > $limit;
    print;
}
