title: "Empirical Bayesian modelling for SNV clusters using rjags"
author: "Paul Theodor Pyl"
date: "2017-06-20"
output: html_document

# Introduction
This package provides helper function to create models for SNV clustering using empirical bayesian methods with the rjags package.

# Creating a Model

A valid JAGS model can be created with the `createJagsModel` function, which takes as an input parameter the number of samples (`nSamples`) and outputs a text definition of a JAGS model for a series with `nSamples` many samples in it.

```r
theModel <- createJagsModel(nSamples = 3)
cat(theModel)
```

