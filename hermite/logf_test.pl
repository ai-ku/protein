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
my $E1;				# first order expectations
my $E2;				# second order expectations

warn "Reading expectation data...\n" if defined $opt_1;
loadE1() if defined $opt_1 or defined $opt_2;
loadE2() if defined $opt_2;

warn "Computing likelihood...\n";

my $logL = 0;			# log likelihood

while(<>) {
    my $x = [split];
    print "POINT\t$Nt\n" if $opt_v;
    my $logp = 
	(defined $opt_2) ? logf2($x, $Nh, $E1, $E2) :
	(defined $opt_1) ? logf1($x, $Nh, $E1) :
	logf0($x);
    warn "t=$Nt\tlogp=$logp\n";
    $logL += $logp;
    print "LOGP\t$logp\t$logL\n" if $opt_v;
    $Nt++;
}

printf("logL/Nt=%g\n", ($logL/$Nt));


sub loadE1 {
    die "Please specify first order expectation file with [-1 filename]\n"
	if not defined $opt_1;
    warn "Reading first order expectations from $opt_1...\n";
    open(FP, $opt_1) or die $!;
    while(<FP>) {
	my ($h, $m, $e) = split;
	$E1->{$h,$m} = $e;
	$Nh = $h if $h > $Nh;
    }
    close(FP);
}

sub loadE2 {
    die "Please specify second order expectation file with [-2 filename]\n"
	if not defined $opt_2;
    warn "Reading second order expectations from $opt_2...\n";
    open(FP, $opt_2) or die $!;
    while(<FP>) {
	my ($h1, $h2, $m1, $m2, $e) = split;
	$E2->{$h1,$h2,$m1,$m2} = $e;
	$Nh = $h1 if $h1 > $Nh;
	$Nh = $h2 if $h2 > $Nh;
    }
    close(FP);
}
