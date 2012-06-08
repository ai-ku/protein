#!/usr/bin/perl -w

# Outputs regular f2 and modified (for each mod pair) f2 for each data point

use strict;
use Getopt::Std;
use Data::Dumper;
$Data::Dumper::Indent = 0;
require "logf.pl";
my $fh = select(STDOUT); $| = 1; select($fh);

sub die_usage { die "Usage: all-pairs.pl -1 foo.one -2 foo.two < foo.dat\n"};
sub mywarn { my $d = `date`; chop($d); warn "$d: $_[0]"; }

our($opt_1, $opt_2);
getopts('1:2:');
die_usage() if (not defined $opt_1 or not defined $opt_2);
my $DBG = 0;

my $Xtm;			# data matrix (read from stdin)
my $Nt = 0;			# number of time snapshots (determined by data from stdin)
my $Nm = 0;			# number of dimensions (modes) (determined by data from stdin)
my $Nh = 0;			# max hermite degree (determined by exp files)
my $E1;				# first order expectations (read from the -1 option)
my $E2;				# second order expectations (read from the -2 option)

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

for (my $t = 0; $t <= $#{$Xtm}; $t++) {
    logf2pair($t);
}

sub logf2pair {
    my ($t) = @_;
    my $x = $Xtm->[$t];
    my $logf0 = logf0($x);
    my $hsum1 = hsum1($x, $Nh, $E1);
    
    # f2 = f0 * [ 1 + hsum1 + hsum2 ]
    # f0 and hsum1 are fixed.
    # hsum2 is modified based on pair to be taken out.

    # thus we represent hdiff as a matrix whose i,j'th entry is the
    # difference for the i,j'th mode pair.  All indices 0 based.

    my $hsum2 = 0;
    my @hdiff = ();
    for (my $m1 = 0; $m1 < $Nm; $m1++) {
	my $xm1 = $x->[$m1];
	die if not defined $xm1;
	for (my $m2 = 0; $m2 < $m1; $m2++) {
	    my $xm2 = $x->[$m2];
	    die if not defined $xm2;
	    for (my $h1 = 1; $h1 < $Nh; $h1++) {
		for (my $h2 = 1; $h2 <= $Nh-$h1; $h2++) {
		    next if ($h1 == 1 and $h2 == 1);
		    die "No exp for $h1,$h2,$m1,$m2"
			if not defined $E2->{$h1,$h2,$m1,$m2}
		    or not defined $E1->{$h1,$m1}
		    or not defined $E1->{$h2,$m2};

		    my $e2 = $E2->{$h1,$h2,$m1,$m2};
		    my $e1 = $E1->{$h1,$m1} * $E1->{$h2,$m2};
		    my $term = 
			(hpoly($h1, $xm1) / fact($h1)) *
			(hpoly($h2, $xm2) / fact($h2));
		    $hsum2 += $e2 * $term;
		    $hdiff[$m1][$m2] += ($e1 - $e2) * $term;
		}
	    }
	}
    }

    my $hsum = 1 + $hsum1 + $hsum2;
    my $logf2 = ($hsum > 0) ? ($logf0 + log($hsum)) : 'NaN';
    print join("\t", $t, 0, 0, $logf2)."\n";

    for (my $m1 = 0; $m1 < $Nm; $m1++) {
	for (my $m2 = 0; $m2 < $m1; $m2++) {
	    $hsum = 1 + $hsum1 + $hsum2 + $hdiff[$m1][$m2];
	    $logf2 = ($hsum > 0) ? ($logf0 + log($hsum)) : 'NaN';
	    print join("\t", $t, $m1, $m2, $logf2)."\n";
	}
    }
}

