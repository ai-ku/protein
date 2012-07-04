#!/usr/bin/perl -w
# Wrapper for sampledist.c

use strict;
use File::Temp qw/tempdir/;

my ($file1, $file2) = @ARGV;
my $data1 = readdata($file1);
my $data2 = readdata($file2);

my $ncol = scalar @{$data1->[0]};
my $nres = $ncol / 3;

my $tmp = tempdir("sampledist-XXXX", CLEANUP => 1);

for (my $r = 0; $r < $nres; $r++) {
    my $kl1 = sampledist($data1, $data2, $r);
    my $kl2 = sampledist($data1, $data2, $r + $nres);
    my $kl3 = sampledist($data1, $data2, $r + 2 * $nres);
    printf("%g\t%g\t%g\t%g\n", $kl1+$kl2+$kl3, $kl1, $kl2, $kl3);
}

sub sampledist {
    my ($d1, $d2, $r) = @_;
    open(SD, "|sampledist > $tmp/out 2> $tmp/err") or die $!;
    print SD "$_->[$r]\n" for @$d1;
    print SD "\n";
    print SD "$_->[$r]\n" for @$d2;
    close(SD);
    open(OUT, "$tmp/out") or die $!;
    $_ = <OUT>;
    my ($kl, $l1, $l2) = split;
    return $kl;
}

sub readdata {
    my ($f) = @_;
    my @data;
    open(FP, $f) or die $!;
    while(<FP>) {
	push @data, [split];
    }
    close(FP);
    return \@data;
}
