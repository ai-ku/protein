#!/usr/bin/perl -w

# Computes log likelihood for standard normal distribution with up to
# second order hermite corrections.

use strict;
use Getopt::Std;
use Data::Dumper;
$Data::Dumper::Indent = 0;
require "logf.pl";

our $opt_h = 0;
getopt('h');
die "h can be 0, 1, or 2.\n" if $opt_h !~ /^[012]$/;

my $Nm = 132;			# number of modes
my $Nt = 501;			# number of time snapshots
my @M;				# mode data
my %warn;

warn "Reading mode data...\n";

for (my $m = 1; $m <= $Nm; $m++) { # m = index of mode
    open(FP, "Raw/hermite$m.dat") or die $!;
    my @data = <FP>;
    close(FP);
    die unless $Nt == @data;
    for (my $t = 0; $t < $Nt; $t++) {
	$M[$t][$m] = $data[$t];
    }
}

warn "Computing likelihood...\n";

my $logL = 0;			# log likelihood

for (my $t = 0; $t < $Nt; $t++) {
    my $x = $M[$t];
    my $logp = 
	($opt_h == 0) ? logf0($x) :
	($opt_h == 1) ? logf1($x) :
	($opt_h == 2) ? logf2($x) :
	die "h can be 0, 1, or 2.";

#     my $hsum = $hsum0 + $hsum1 + $hsum2;
#     if ($hsum <= 0) {
# 	$warn{negative_hsum}++;
# 	warn "Fixing hsum $hsum -> 0.001\n";
# 	$hsum = 0.001;   # DOES THIS MAKE SENSE
#     }
#     my $logp = $logZ + (-$sumsq / 2) + log($hsum);
#     warn "t=$t\tsumsq=$sumsq\thsum=$hsum\tlogp=$logp\n";
    warn "t=$t\tlogp=$logp\n";
    $logL += $logp;
}

if (%warn) {
    warn "Warnings:\n";
    for my $msg (sort keys %warn) {
	warn "$msg:\t$warn{$msg}\n";
    }
}

printf("logL/Nt=%g\n", ($logL/$Nt));
