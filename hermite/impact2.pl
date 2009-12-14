#!/usr/bin/perl -w
use strict;

my $DBG = 1;
my $PI = 2*atan2(1,0);
my $Nm = 132;
my $Nt = 0;
my ($pt, $sumsq, $logf0, $h1, $hsum1, $h2, $hsum2, $hsum, $lsum, $lcnt, $lavg, $xsum, $xcnt);

while(<>) {
    if (/^POINT\t(\S+)/) {
	$Nt++;
	$pt = $1;
	$hsum1 = $hsum2 = 0;
	$h1 = {};
	$h2 = {};
    } elsif (/^SUMSQ\t(\S+)/) {
	$sumsq = $1;
    } elsif (/^LOGF0\t(\S+)/) {
	my $a = $1;
	$logf0 = -($Nm/2)*log(2*$PI) - 0.5 * $sumsq;
	warn "sumsq=$sumsq logf0=$a should be $logf0\n" unless equal($a, $logf0);
    } elsif (my ($mode, $term) = /^HSUM1\t(\S+)\t(\S+)/) {
	$h1->{$mode} = $term;
	$hsum1 += $term;
    } elsif (my ($m1, $m2, $term2) = /^HSUM2\t(\S+)\t(\S+)\t(\S+)/) {
	$h2->{$m1,$m2} = $term2;
	$hsum2 += $term2;
    } elsif (my ($hsum12) = /^1\+HSUM1\+HSUM2\t(\S+)/) {
	$hsum = 1.0 + $hsum1 + $hsum2;
	warn "1+hsum1+hsum2 = $hsum12 should be $hsum\n" unless equal($hsum12, $hsum);
    } elsif (my ($logf2, $logf_sum) = /^LOGP\t(\S+)\t(\S+)/) {
	if ($hsum > 0) {
	    my $a = $logf0 + log($hsum);
	    warn "logf2 = $logf2 should be $a\n" unless equal($a, $logf2);
	    $lsum += $a;
	    $lcnt++;
	    # warn "logf_sum = $logf_sum should be $lsum\n" unless equal($lsum, $logf_sum);
	    for (my $m1 = 0; $m1 < $Nm; $m1++) {
		for (my $m2 = 0; $m2 < $m1; $m2++) {
		    my $x = $hsum - $h2->{$m1,$m2};
		    if ($x > 0) {
			$xsum->{$m1,$m2} += log($hsum) - log($x);
			$xcnt->{$m1,$m2}++;
			warn(join("\t", $pt, $m1, $m2, log($hsum), log($x), (log($hsum)-log($x)), $xsum->{$m1,$m2})."\n")
			    if ($DBG and $m1 == 131 and $m2 == 24);
		    }
		}
	    }
	}
    } elsif (my ($logf_avg) = /^logL\/Nt=(\S+)/) {
	$lavg = $lsum / $lcnt;
	# warn "logf_avg=$logf_avg should be $avg\n" unless equal($logf_avg, $avg);
    }
}

warn (($Nt-$lcnt)." points returned negative probabilities\n");
warn "logL/Nt = $lsum / $lcnt = $lavg\n";

for (my $m1 = 0; $m1 < $Nm; $m1++) {
    for (my $m2 = 0; $m2 < $m1; $m2++) {
	my $d = $xsum->{$m1,$m2} / $xcnt->{$m1,$m2};
	my $c = $xcnt->{$m1,$m2};
	print "$m1\t$m2\t$d\t$c\n";
    }
}


# equal(NUM1, NUM2, ACCURACY) : returns true if NUM1 and NUM2 are
# equal to ACCURACY number of decimal places

sub equal {
    my ($A, $B, $dp) = @_;
    $dp = 10 if not defined $dp;
    return sprintf("%.${dp}g", $A) eq sprintf("%.${dp}g", $B);
}

