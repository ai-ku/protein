use Memoize;

sub hpoly {			# computes the value of a hermite polynomial
    my ($h, $x) = @_;
    my $coeff = hermite($h);
    return poly($coeff, $x);
}

sub poly {			# computes the value of an arbitrary polynomial
    my ($coeff, $x) = @_;
    my $poly = 0;
    for (my $i = 0; $i <= $#{$coeff}; $i++) {
	$poly += $coeff->[$i] * expt($x, $i);
    }
    return $poly;
}

sub hermite {			# returns coefficients of hermite polynomial
    # H0(x) = 1, H1(x) = x, H[p+1](x) = x Hp(x) - p H[p-1](x)

    my ($h) = @_;		# degree of hermite
    my $H = [];			# polynomial coefficient array
    if ($h < 0) {
	die;
    } elsif ($h == 0) {
	$H = [1];
    } elsif ($h == 1) {
	$H = [0, 1];
    } else {
	my @H1 = @{hermite($h - 1)};
	my @H2 = @{hermite($h - 2)};
	unshift @H1, 0;	# multiply by x
	$_ *= (1 - $h) for @H2;
	for (my $i = 0; $i <= $#H1; $i++) {
	    $H->[$i] = $H1[$i] + ($H2[$i] or 0);
	}
    }
    return $H;
}

sub fact {
    my ($n) = @_;
    my $f;
    if ($n < 0) {
	die;
    } elsif ($n == 0) {
	$f = 1;
    } else {
	$f = $n * fact($n-1);
    }
    return $f;
}

sub expt {
    my ($x, $n) = @_;
    my $ans;
    if ($n == 0) {
	$ans = 1;
    } elsif ($x == 0) {
	if ($n > 0) { $ans = 0; }
	else { die "Negative power of 0"; }
    } else {
	my $xx = ($x >= 0 ? $x : -$x);
	$ans = exp($n * log($xx));
	$ans = -$ans if (($x < 0) and ($n % 2));
    }
    return $ans;
}

#memoize('hpoly');
#memoize('poly');
memoize('hermite');
memoize('fact');
#memoize('expt');

1;
