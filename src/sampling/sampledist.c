#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <gsl/gsl_statistics.h>
#include <gsl/gsl_randist.h>
#include "foreach.h"
#define INIT_SIZE (1<<20)

double *read_sample(int *nptr) {
  int size = INIT_SIZE;
  double *s = calloc(INIT_SIZE, sizeof(double));
  int n = 0;
  foreach_line(str, "") {
    if (*str == '\n') break;
    if (n == size) {
      size *= 2;
      s = realloc(s, size * sizeof(double));
    }
    s[n++] = atof(str);
  }
  *nptr = n;
  return s;
}

int main(void) {
  int n1, n2;
  double *sample1 = read_sample(&n1); 
  double *sample2 = read_sample(&n2); 
  fprintf(stderr, "Read %d instances in sample1 %d in sample2\n", n1, n2);

  /* http://en.wikipedia.org/wiki/Kernel_density_estimation

     Practical estimation of the bandwidth

     If Gaussian basis functions are used to approximate univariate
     data, and the underlying density being estimated is Gaussian then
     it can be shown that the optimal choice for h is

     h = 1.06 sigma n^(-1/5)

     , where is the standard deviation of the samples.  This
     approximation is termed the normal distribution approximation,
     Gaussian approximation, or Silverman's rule of thumb.
  */
  
  double sigma1 = gsl_stats_sd(sample1, 1, n1);
  double sigma2 = gsl_stats_sd(sample2, 1, n2);
  double bw1 = 1.06 * sigma1 * pow(n1, -0.2);
  double bw2 = 1.06 * sigma2 * pow(n2, -0.2);
  fprintf(stderr, "sigma1=%g sigma2=%g bw1=%g bw2=%g\n", sigma1, sigma2, bw1, bw2);

  double kl = 0;
  double l1 = 0;
  double l2 = 0;
  for (int i = 0; i < n1; i++) {
    double x1 = sample1[i];
    double p1 = 0;
    for (int j = 0; j < n1; j++) {
      if (i == j) continue;	/* It is unstable without this */
      p1 += gsl_ran_ugaussian_pdf((x1 - sample1[j]) / bw1);
    }
    p1 /= ((n1-1) * bw1);
    l1 += log(p1);

    double p2 = 0;
    for (int j = 0; j < n2; j++)
      p2 += gsl_ran_ugaussian_pdf((x1 - sample2[j]) / bw2);
    p2 /= (n2 * bw2);
    l2 += log(p2);

    kl += log(p1/p2);
  }
  kl /= n1; l1 /= n1; l2 /= n1;
  printf("%g\t%g\t%g\n", kl, l1, l2);
}
