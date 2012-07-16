#!/usr/bin/perl -w
use strict;
use Getopt::Std;
our($opt_a);
getopt('a');

my @attr;
if (defined $opt_a) {
    open(A, $opt_a) or die $!;
    @attr = <A>;
    chomp for @attr;
    close(A);
}

my @data;
while(<>) {
    my @d = split;
    push @data, \@d;
}

my $ncol = scalar(@{$data[0]});

# Assuming last column is class represented by 0/1
my $npos;
my $nneg;
for my $x (@data) {
    $x->[$ncol-1] ? $npos++ : $nneg++;
}

for (my $col = 0; $col < $ncol - 1; $col++) {
    for my $x (stats($col)) {
	printf("%.4g\t", $x);
    }
    print "$attr[$col]" if @attr;
    print "\n";
}

sub stats {
    my ($col) = @_;
    @data = sort { $a->[$col] <=> $b->[$col] } @data;
    my ($f1, $prec, $recl, $imax);
    # Try splitting data into < i and >= i:
    for (my $i = 0; $i <= @data; $i++) {
	# Only split where attr value changes
	next if ($i > 0 and $i < @data and $data[$i][$col] == $data[$i-1][$col]);
	my ($mpos0, $mneg0, $mpos1, $mneg1) = (0,0,0,0);
	for (my $j = 0; $j <= $#data; $j++) {
	    my $x = $data[$j];
	    if ($j < $i) {
		$x->[$ncol-1] ? $mpos0++ : $mneg0++;
	    } else {
		$x->[$ncol-1] ? $mpos1++ : $mneg1++;
	    }
	}
	my $prec0 = $mpos0 ? $mpos0 / ($mpos0 + $mneg0) : 0;
	my $recl0 = $mpos0 / $npos;
	my $f1_0 = $prec0 ? 2 * $prec0 * $recl0 / ($prec0 + $recl0) : 0;
	if (not defined $f1 or $f1 < $f1_0) {
	    ($f1, $prec, $recl, $imax) = ($f1_0, $prec0, $recl0, -$i);
	}
	my $prec1 = $mpos1 ? $mpos1 / ($mpos1 + $mneg1) : 0;
	my $recl1 = $mpos1 / $npos;
	my $f1_1 = $prec1 ? 2 * $prec1 * $recl1 / ($prec1 + $recl1) : 0;
	if (not defined $f1 or $f1 < $f1_1) {
	    ($f1, $prec, $recl, $imax) = ($f1_1, $prec1, $recl1, $i);
	}
    }
    return ($f1, $prec, $recl, $imax);
}
