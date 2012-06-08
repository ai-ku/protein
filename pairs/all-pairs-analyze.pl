#!/usr/bin/perl -w
# Get output of all-pairs.pl and sort -<logf2kl> by k,l pair

use strict;

my ($avg, $cnt);
while(<>) {
    my ($t, $m1, $m2, $logf2) = split;
    next if $logf2 eq 'NaN';
    $avg->{"$m1\t$m2"} += $logf2;
    $cnt->{"$m1\t$m2"} ++;
}

$avg->{$_} /= -$cnt->{$_} for keys(%$avg);

for my $pair (sort { $avg->{$a} <=> $avg->{$b} } keys(%$avg)) {
    print "$avg->{$pair}\t$pair\n";
}
