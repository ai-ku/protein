#!/usr/bin/perl -w

# Computes log likelihood for standard normal distribution with up to
# second order hermite corrections.

use strict;
use Getopt::Std;
use Data::Dumper;
$Data::Dumper::Indent = 0;
require "logf.pl";

our($opt_1, $opt_2, $opt_v);
getopts('1:2:v');

my $Nh = 0;			# max hermite degree (determined by exp files)
my $Nt = 0;			# number of time snapshots (determined by data from stdin)
my $Np = 0;			# number of instances with positive probability
my $Nz = 0;			# number of instances with non-positive probability
my $Nd = 0;			# number of dimensions
my $E1;				# first order expectations
my $E2;				# second order expectations

warn "Reading expectation data...\n" if defined $opt_1;
my $nh;
($E1, $nh) = loadE1($opt_1) if defined $opt_1;
$Nh = $nh if $nh > $Nh;
($E2, $nh) = loadE2($opt_2) if defined $opt_2;
$Nh = $nh if $nh > $Nh;

warn "Computing likelihood...\n";

my $logL = 0;			# log likelihood

while(<>) {
    my $x = [split];
    if ($Nd == 0) {
	$Nd = scalar(@$x);
    } elsif ($Nd != scalar(@$x)) {
	die "Wrong number of dimensions";
    }
    print "POINT\t$Nt\n" if $opt_v;
    $Nt++;
    my $logp = 
	(defined $opt_2) ? logf2($x, $Nh, $E1, $E2) :
	(defined $opt_1) ? logf1($x, $Nh, $E1) :
	logf0($x);
    if (defined $logp) {
	warn "t=$Nt\tlogp=$logp\n";
	$logL += $logp;
	$Np++;
	print "LOGP\t$logp\t$logL\n" if $opt_v;
    } else {
	warn "t=$Nt\tlogp=undef\n";
	$Nz++;
	print "LOGP\tundef\t$logL\n" if $opt_v;
    }
}

my $avgL = $logL/$Np;
my $avgL2 = $avgL/$Nd;
print "$Nt instances, $Np positive probabilities (avg logP=$avgL2), $Nz negative probabilities\n";


