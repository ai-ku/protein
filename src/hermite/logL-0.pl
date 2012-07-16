#!/usr/bin/perl -w
# Compute log likelihood for standard normal distribution

use strict;
use Data::Dumper;
$Data::Dumper::Indent = 0;

my $Nm = 132;			# number of modes
my $Nt = 501;			# number of time snapshots
my @M;				# mode data

for (my $m = 1; $m <= $Nm; $m++) { # m = index of mode
    open(FP, "Raw/hermite$m.dat") or die $!;
    my @data = <FP>;
    die unless 501 == @data;
    $M[$m] = \@data;
    close(FP);
}

my $logL = 0;
my $pi = 2*atan2(1,0);
my $logZ = (-$Nm/2) * log(2*$pi); # normalization constant (log)

for (my $t = 0; $t < $Nt; $t++) {
    my $sumsq = 0;
    for (my $m = 1; $m <= $Nm; $m++) {
	my $rt = $M[$m][$t];
	$sumsq += $rt*$rt;
    }
    $logL += $logZ + (-$sumsq/2);
}

printf("logL=%g\n", ($logL/$Nt));
