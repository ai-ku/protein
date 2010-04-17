#!/usr/bin/perl -w
# analyze the f1 output for top n modes to find the optimum n.
use strict;
my $nmode = 132;
my $logf0 = -187.3/$nmode;
while(<>) {
    my ($nd, $logp, $nneg) = /^(\d+) 996 instances, \d+ positive probabilities \(avg logP=(-\d\.\d+)\), (\d+) negative probabilities$/
	or die;
    my $tot = $nd * $logp + ($nmode - $nd) * $logf0;
    print "$nd\t$tot\t$nneg\n";
}
