#!/usr/bin/R --slave -f
library('np')
trn <- read.table('8967b.trn.dat')
bw  <- npudensbw(dat=trn[,1:2], ftol=.01, tol=.01, nmulti=1)
x   <- seq(-4, 4, by=.05)
y   <- seq(-4, 4, by=.05)
grd <- expand.grid(x=x, y=y)
f   <- fitted(npudens(edat=grd, bws=bw))
grd[3] <- f
write.table(grd)

## To plot with R:
## mat <- matrix(f, length(x), length(y))
## contour(x, y, mat)
## persp(x, y, mat)
## npplot(bws=bw)
