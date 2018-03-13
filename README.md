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

# Input Data format

The input data is expected to be a list with two elements named `Support` and `Coverage`, each of those is a matrix with `n` rows and `m` columns where `n` is the number of SNVs and `m` is the number of samples. Usage of meaningful row and column names is encouraged.

We can simulate some data to demonstrate the modelling functionality:

```
sDat <- simulateData(nSamples = 3, nSNVs = 100, nClusters = 3, meanCoverage = c(60, 120, 180))
lapply(sDat, head)
```

```
$Coverage
      sample_a sample_b sample_c
snv_1       56      110      186
snv_2       78      126      185
snv_3       64      104      187
snv_4       70      122      173
snv_5       68      112      170
snv_6       65      134      192

$Support
      sample_a sample_b sample_c
snv_1       41       26      100
snv_2       39      109      158
snv_3       49       45      136
snv_4       60       25       82
snv_5       30      104      134
snv_6       52       62      150
```

# Modelling

The model is run by a call to the `clusterSamples` function, giving the data as input as well as a number of parameters for the clustering algorith. We will leave them at the default settings for now, eventhough that will try to fit 10 clusters and we know we simulated only 3.

```
clusteringResult <- clusterSamples(sDat)
```

rjags will produce some output including a progress bar of the modelling process:

```{r}
Compiling model graph
   Resolving undeclared variables
   Allocating nodes
Graph information:
   Observed stochastic nodes: 300
   Unobserved stochastic nodes: 142
   Total graph size: 1119

Initializing model

  |++++++++++++++++++++++++++++++++++++++++++++++++++| 100%
  |**************************************************| 100%
  |**************************************************| 100%
```

# Results

## Cluster Weights and Allelic Frequencies

Let's plot the cluster weights and mean allelic frequencies of the result:

```{r}
plotClusterWeights(clusteringResult) + scale_fill_brewer(palette = "Set3")
```

In this plot we see three clusters with ~33% Weight (which makes sense since we simulated 3 clusters of equal size), the other clusters have weights close to 0.

![Cluster Weight Example Plot](clusterWeightPlotExample.png)

## SNV Cluster assignment Plot

Another way to look at this is to plot the SNVs annotated with the clusters they were assigned to:

```{r}
plotResultSNVs(clusteringResult) + scale_fill_brewer(palette = "Set3")
```

Here we see our three clusters of simulated SNVs and their respective allelic frequencies in the three samples.

![Cluster SNV Example Plot](snvPlotExample.png)

## JAGS model chain plots

A more in-depth look can be had by tracing the actual allele frequencies of the clusters as they were sampled from the mixture model. Here we plot only clusters which contain at least 1% of SNVs in the final estimate.

```{r}
plotChains(clusteringResult, minWeight = 0.01) + ylim(0,1) + scale_colour_brewer(palette = "Set3")
```

![Cluster Chain Example Plot with minimum Weight](chainPlotExample.1.perc.png)

We see that the model has converged very well and in all samples the clusters are very stable in their respective estimated alelle frequencies. Since this is simulated data we did expect such behaviour and in real-world examples the clusterin can be much more unstable. Typically it is advisable to filter the input data strictly and try to focus on SNVs where there is a lot of evidence, i.e. where the coverage is high, so that the estimated AFs can be very precise.

If we allow for all clusters to be plotted we see that the clusters with low weight do not converge at all and are all over the place, this is not a problem however, since when the clusters contain no data the prior probability is never updated and so they sample from a uniform distribution between `0` and `1`, which is expected.

```{r}
plotChains(clusteringResult, minWeight = 0) + ylim(0,1) + scale_colour_brewer(palette = "Set3")
```

![Cluster Chain Example Plot without minimum Weight](chainPlotExample.0.perc.png)
