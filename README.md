---
title: "Empirical Bayesian modelling for SNV clusters using rjags"
author: "Paul Theodor Pyl"
date: "2017-06-20"
output: html_document
---

# Introduction
This package provides helper function to create models for SNV clustering using empirical bayesian methods with the rjags package.

# Installation
Use devtools to pull the package from GitHub like so:
```r
install.packages("devtools") # If you do not have it yet
require(devtools)
install_github("PaulPyl/JagsCluster")
```
# Creating a Model

A valid JAGS model can be created with the `createJagsModel` function, which takes as an input parameter the number of samples (`nSamples`) and outputs a text definition of a JAGS model for a series with `nSamples` many samples in it.

```r
theModel <- createJagsModel(nSamples = 3)
cat(theModel)
```

```
model {
# Likelihood:
for( i in 1 : Nsnvs ) {
  clust[i] ~ dcat(cluster.weight[1:Nclust])
  count.1[i] ~ dbin(snv.center.1[i], coverage.1[i])
  snv.center.1[i] <- cluster.center.1a[clust[i]]
  count.2[i] ~ dbin(snv.center.2[i], coverage.2[i])
  snv.center.2[i] <- cluster.center.2a[clust[i]]
  count.3[i] ~ dbin(snv.center.3[i], coverage.3[i])
  snv.center.3[i] <- cluster.center.3a[clust[i]]
}
# Priors:
for ( clustIdx in 1 : Nclust ) {
  cluster.center.1[clustIdx] ~ dunif(0, 1)
  cluster.center.2[clustIdx] ~ dunif(0, 1)
  cluster.center.3[clustIdx] ~ dunif(0, 1)
  delta[clustIdx] ~ dgamma(alpha1, alpha2)
  cluster.weight[clustIdx] <- delta[clustIdx] / sum(delta[])
}
alpha1 ~ dbeta(shape1, shape2)
alpha2 ~ dbeta(shape2, shape2)
}
```
