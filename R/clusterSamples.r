clusterSamples <- function(input, Nclust = 10, nAdapt = 1000, nBurnIn = 2000, nSample = 500, nChain = 1, maxSNVs = 1000, minAF = 0.1, varCF = Inf, minCov = 10, minWeight = 0, shape1 = 1, shape2 = 1000){
  verifyInput(input) # check if input is valid
  input$AF <- input$Support / input$Coverage
  input$AF[!is.finite(input$AF)] <- 0
  selectedSNVs <- rowSums(input$AF >= minAF) >= 1 & rowSums(input$Coverage >= minCov) >= 1
  if(sum(selectedSNVs) == 0){
    stop("No SNV calls passed filtering, consider revising criteria and check input.")
  }
  input <- lapply(input, function(m) m[selectedSNVs,,drop = FALSE])
  if(sum(selectedSNVs) == 1){
    message("Trivial case with only one SNV passing filter")
    input$Cluster <- data.frame(
      "ClusterIdx" = 1,
      "SNVID"      = rownames(input$Support),
      stringsAsFactors = FALSE
    )
    input$Cluster$ClusterName <- "c1"
    ret <- list(
      "jags.result"    = NA,
      "Modelling.Data" = input,
      "Clusters"       = data.frame(
        "Mean" = mean(input$AF),
        "Var"  = var(input$AF),
        "toRemove" = FALSE,
        "Sample" = colnames(input$Support),
        "clusterIdx" = 1,
        "Weight" = 1,
        "ClusterName" = "c1",
        stringsAsFactors = FALSE
        ),
      "ClusterNameMap" = c("c1")
    )
    return(ret)
  }
  if(length(selectedSNVs) > maxSNVs){
    message(paste0("Input too large (", length(selectedSNVs), " variant calls), subsamping to ", maxSNVs, " for modelling."))
    selectedSNVs <- sample(x = selectedSNVs, size = maxSNVs, replace = FALSE)
    input <- lapply(input, function(m) m[selectedSNVs,,drop = FALSE])
    message("Subsampled Input looks like this:")
    message(str(input))
  }
  res <- runJagsModel(input, model = createJagsModel(nSamples = ncol(input$Support)), shape1 = shape1, shape2 = shape2, Nclust = Nclust, nAdapt = nAdapt, nBurnIn = nBurnIn, nSample = nSample, nChain = nChain)
  weights <- apply(res$cluster.weight, 1, mean)
  clusters <- do.call(rbind,lapply(seq(ncol(input$Support)), function(i){
    data.frame(
      "Mean"        = apply(res[[paste0("cluster.center.", i)]], 1, mean),
      "Var"         = apply(res[[paste0("cluster.center.", i)]], 1, var),
      "toRemove"    = (apply(res[[paste0("cluster.center.", i)]], 1, var) >= varCF) | (weights <= minWeight),
      "Sample"      = colnames(input$Support)[i],
      "ClusterIdx"  = seq(Nclust),
      "Weight"      = weights,
      stringsAsFactors = FALSE
    )
  }))
  clusterNameMap <- rep(NA, Nclust)
  clusterNameMap[!subset(clusters, Sample == colnames(input$Support)[1])$toRemove] <- paste0("c", rank(subset(clusters, Sample == colnames(input$Support)[1] & !toRemove)$Mean))
  clusters$ClusterName <- clusterNameMap[clusters$ClusterIdx]
  input$Cluster <- data.frame(
    "ClusterIdx" = apply(res$clust, c(1,3), median)[,1],
    "SNVID"      = rownames(input$Support),
    stringsAsFactors = FALSE
  )
  input$Cluster$ClusterName <- clusterNameMap[input$Cluster$ClusterIdx]
  list(
    "jags.result"    = res,
    "Modelling.Data" = input,
    "Clusters"       = clusters,
    "ClusterNameMap" = clusterNameMap
  )
}
