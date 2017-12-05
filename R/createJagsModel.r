createJagsModel <- function(nSamples = 2){
  ret <- "model {
# Likelihood:
for( i in 1 : Nsnvs ) {
  clust[i] ~ dcat(cluster.weight[1:Nclust])"
  for(i in seq(nSamples)){
    ret <- c(ret, paste0("  count.", i , "[i] ~ dbin(snv.center.", i, "[i], coverage.", i, "[i])"))
    ret <- c(ret, paste0("  snv.center.", i , "[i] <- cluster.center.", i, "[clust[i]]"))
  }
  ret <- c(
    ret,
    "}",
    "# Priors:
for ( clustIdx in 1 : Nclust ) {"
  )
  for(i in seq(nSamples)){
    ret <- c(ret, paste0("  cluster.center.", i, "[clustIdx] ~ dunif(0, 1)"))
  }
  ret <- c(
    ret,
    "  delta[clustIdx] ~ dgamma(alpha1, alpha2)",
    "  cluster.weight[clustIdx] <- delta[clustIdx] / sum(delta[])",
    "}"
  )
  ret <- c(
    ret,
    "alpha1 ~ dbeta(shape1, shape2)",
    "alpha2 ~ dbeta(shape2, shape2)",
    "}"
  )
  paste(ret, collapse = "\n")
  }
