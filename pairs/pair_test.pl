#!/usr/bin/perl -w

# Computes log likelihood for standard normal distribution with up to
# second order hermite corrections.

use strict;
use Getopt::Std;
use Data::Dumper;
$Data::Dumper::Indent = 0;
require "logf.pl";
my $fh = select(STDOUT); $| = 1; select($fh);

sub die_usage { die "Usage: pair_test.pl [-k mode1 -l mode2] -1 foo.one -2 foo.two < foo.dat\n"};
sub mywarn { my $d = `date`; chop($d); warn "$d: $_[0]"; }

# Note: opt_k, opt_l are zero based.
our($opt_1, $opt_2, $opt_v, $opt_k, $opt_l);
getopts('1:2:k:l:');
die_usage() if (not defined $opt_1 or not defined $opt_2);
my $DBG = 0;

my $Xtm;			# data matrix
my $Nt = 0;			# number of time snapshots (determined by data from stdin)
my $Nm = 0;			# number of dimensions (modes) (determined by data from stdin)
my $Nh = 0;			# max hermite degree (determined by exp files)
my $E1;				# first order expectations
my $E2;				# second order expectations

mywarn "Reading mode data from stdin...\n";
my @data;
while(<>) {
    push @data, [split];
}
$Xtm = \@data;
($Nm, $Nt) = (scalar(@{$data[0]}), scalar(@data));
mywarn "Read $Nt time steps with $Nm modes.\n";

mywarn "Reading expectation data...\n" if defined $opt_1;
my $nh;
($E1, $nh) = loadE1($opt_1) if defined $opt_1;
$Nh = $nh if $nh > $Nh;
($E2, $nh) = loadE2($opt_2) if defined $opt_2;
$Nh = $nh if $nh > $Nh;
mywarn "Read expectations with max degree = $Nh\n";


if (not defined $opt_k or not defined $opt_l) {
    mywarn "Compute and print -<logf2>\n";
    my $logf2;
    my $logf2sum;
    for (my $t = 0; $t < $Nt; $t++) {
	my $xt = $Xtm->[$t];
	$logf2 = logf2($xt, $Nh, $E1, $E2); # BUG: logf2 could return undef if train/test different
	$logf2sum += $logf2;
	mywarn "$t\t$logf2\n";
    }
    printf("0\t0\t%g\n", -$logf2sum / $Nt);

} else {

    mywarn "Compute and print -<logf2kl> for the $opt_k, $opt_l pair (zero based)\n";
    my $logf2pair;
    my $logf2pairsum;
    for (my $t = 0; $t < $Nt; $t++) {
	my $xt = $Xtm->[$t];
	$logf2pair = logf2pair($xt, $Nh, $E1, $E2, $opt_k, $opt_l);
	$logf2pairsum += $logf2pair;
	mywarn "$t\t$logf2pair\n";
    }
    printf("%d\t%d\t%g\n", $opt_k, $opt_l, -$logf2pairsum / $Nt);
}

mywarn "done\n";


sub hsum2pair {
    my ($x, $Nh, $E1, $E2, $m1, $m2) = @_;
    if ($m1 < $m2) { my $tmp = $m1; $m1 = $m2; $m2 = $tmp; }
    my $xm1 = $x->[$m1];
    my $xm2 = $x->[$m2];
    my $msum = 0;
    for (my $h1 = 1; $h1 < $Nh; $h1++) {
	for (my $h2 = 1; $h2 <= $Nh-$h1; $h2++) {
	    next if ($h1 == 1 and $h2 == 1);
	    die "Undefined E2->{$h1,$h2,$m1,$m2}\n" if not defined $E2->{$h1,$h2,$m1,$m2};
	    die "Undefined E1->{$h1,$m1}\n" if not defined $E1->{$h1,$m1};
	    die "Undefined E1->{$h2,$m2}\n" if not defined $E1->{$h2,$m2};
	    my $e2 = $E2->{$h1,$h2,$m1,$m2};
	    my $e1 = $E1->{$h1, $m1} * $E1->{$h2, $m2};
	    my $term = ($e2 - $e1) *
		(hpoly($h1, $xm1) / fact($h1)) *
		(hpoly($h2, $xm2) / fact($h2));
	    print "HSUM5\t$m1\t$m2\t$h1\t$h2\t$term\n" if $DBG;
	    $msum += $term;
	}
    }
    print "HSUM6\t$m1\t$m2\t$msum\n" if $opt_v;
    return $msum;
}

sub logf2pair {
    my ($x, 			# data vector
	$Nh, 			# max degree of hermite
	$E1, 			# first degree expectations
	$E2,			# second degree expectations
	$m1, $m2		# mode pair to be excluded
	) = @_;
    my $f0 = f0($x);
    my $f2 = f2($x, $Nh, $E1, $E2);
    my $hsum = hsum2pair($x, $Nh, $E1, $E2, $m1, $m2);
    my $f2pair = $f2 - $f0 * $hsum;
    die "Negative log: m1=$m1 m2=$m2 f2=$f2 hsum=$hsum f2-hsum=$f2pair\n"
	if $f2pair <= 0;
    return log($f2pair);
}

