#!/usr/bin/R --slave -f
library('np')
library('mvtnorm')
trn <- read.table('8967b.trn.dat')
tst <- read.table('8967b.tst.dat')
f <- NULL

for (i in 0:ncol(tst)) {		# number of variables to use kde
  if (i > 0) {
    f <- npudens(tdat=trn[,1:i], edat=tst[,1:i], bwmethod="normal-reference");
  } else {
    f$log_likelihood <- 0; 
  }
  if (i < ncol(tst)) {
    r <- sum(log(dmvnorm(x=tst[,(i+1):ncol(tst)])));
  } else {
    r <- 0;
  }
  print(c(i, (f$log_likelihood + r) / nrow(tst)));
}
