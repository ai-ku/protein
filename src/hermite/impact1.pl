#!/usr/bin/perl -w
use strict;

my $PI = 2*atan2(1,0);
my $Nm = 132;
my $Nt = 0;
my ($pt, $sumsq, $logf0, $h, $hsum, $lsum, $lcnt, $lavg, $xsum, $xcnt);

while(<>) {
    if (/^POINT\t(\S+)/) {
	$Nt++;
	$pt = $1;
	$hsum = 0;
    } elsif (/^SUMSQ\t(\S+)/) {
	$sumsq = $1;
    } elsif (/^LOGF0\t(\S+)/) {
	my $a = $1;
	$logf0 = -($Nm/2)*log(2*$PI) - 0.5 * $sumsq;
	warn "sumsq=$sumsq logf0=$a should be $logf0\n" unless equal($a, $logf0);
    } elsif (my ($mode, $term) = /^HSUM1\t(\S+)\t(\S+)/) {
	$h->{$mode,$pt} = $term;
	$hsum += $term;
    } elsif (my ($hsum1) = /^1\+HSUM1\t(\S+)/) {
	$hsum += 1.0;
	warn "1+hsum1 = $hsum1 should be $hsum\n" unless equal($hsum, $hsum1);
    } elsif (my ($logf1, $logf_sum) = /^LOGP\t(\S+)\t(\S+)/) {
	if ($hsum > 0) {
	    my $a = $logf0 + log($hsum);
	    warn "logf1 = $logf1 should be $a\n" unless equal($a, $logf1);
	    $lsum += $a;
	    $lcnt++;
	    # warn "logf_sum = $logf_sum should be $lsum\n" unless equal($lsum, $logf_sum);
	    for (my $m = 0; $m < $Nm; $m++) {
		my $x = $hsum - $h->{$m,$pt};
		if ($x > 0) {
		    $xsum->[$m] += log($hsum) - log($x);
		    $xcnt->[$m]++;
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

for (my $m = 0; $m < $Nm; $m++) {
    my $d = $xsum->[$m] / $xcnt->[$m];
    print "$m\t$d\t$xcnt->[$m]\n";
}


# equal(NUM1, NUM2, ACCURACY) : returns true if NUM1 and NUM2 are
# equal to ACCURACY number of decimal places

sub equal {
    my ($A, $B, $dp) = @_;
    $dp = 10 if not defined $dp;
    return sprintf("%.${dp}g", $A) eq sprintf("%.${dp}g", $B);
}

