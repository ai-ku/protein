#!/usr/bin/perl -w
# Generates f1 samples using rejection sampling

use strict;
use Getopt::Std;
use Math::Random;
require 'logf.pl';
my $FMAX = 0.7;
my $XMIN = -3.0;
my $XMAX = 3.0;

our($opt_1, $opt_n);
getopts('1:n:');

my ($E1, $Nh, $Nm) = loadE1($opt_1);
warn "Nh=$Nh Nm=$Nm\n";

my @x = (undef) x $Nm;
my @h = (1) x $Nm;
for (my $t = 0; $t < $opt_n; $t++) {
    for (my $m = 0; $m < $Nm; $m++) {
	my $ntry = 0;
	while (1) {
	    $ntry++;
	    $x[$m] = random_normal();
	    my $y = gaussian($x[$m]);
	    my $yh = $y * $h[$m];
	    my $f = f1(\@x, $Nh, $E1);
	    
	    if ($f > $yh) {
		$h[$m] = $f / $y;
		next;
	    }
	    if (rand($yh) < $f) {
		# print "$x[$m]\t$f\t$ntry\n";
		print "\t" if $m > 0;
		print $x[$m];
		last;
	    }
	}	    
	$x[$m] = undef;
    }
    print "\n";
}

sub gaussian {
    my ($x) = @_;
    my $z = 0.39894228; # 1/sqrt(2 pi)
    return $z * exp(-0.5*$x*$x);
}

=pod
	    $x[$m] = rand($XMAX - $XMIN) + $XMIN;
	    my $fx = f1(\@x, $Nh, $E1);
	    die "m=$m xm=$x[$m] fx=$fx > $FMAX" if $fx > $FMAX;
	    $ntry++;
	    if (rand($FMAX) < $fx) {
		# print "\t" if $m > 0;
		# print $x[$m];
		print "$x[$m]\t$fx\t$ntry\n";
		last;
	    }		
=cut

