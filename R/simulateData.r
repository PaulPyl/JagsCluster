simulateData <- function(nSamples = 2, nSNVs = 20, nClusters = 3, meanCoverage = rep(100, nSamples)){
  clusterAFs <- matrix(sapply(seq(nClusters), function(i) round(runif(min = 0.05, max = 0.95, nSamples), digits = 2)), ncol = nClusters, byrow = TRUE)
  coverage   <- matrix(sapply(meanCoverage,  function(m) rpois(nSNVs, m)), ncol = nSamples, byrow = FALSE)
  support    <- matrix(sapply(seq(nSamples), function(i) rbinom(nSNVs, coverage[,i], clusterAFs[i,])), ncol = nSamples, byrow = FALSE)
  colnames(coverage) <- paste("sample", letters[seq(nSamples)], sep = "_")
  colnames(support) <- paste("sample", letters[seq(nSamples)], sep = "_")
  rownames(coverage) <- paste("snv", seq(nSNVs), sep = "_")
  rownames(support) <- paste("snv", seq(nSNVs), sep = "_")
  list(
    Coverage = coverage,
    Support = support
  )
}
