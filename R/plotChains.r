plotChains <- function(clsRes, minWeight = 0.01){
  nSamples <- ncol(clsRes$Modelling.Data$AF)
  dat <- do.call(rbind,lapply(seq(nSamples), function(sid){
    res <- melt(clsRes$jags.result[[paste0("cluster.center.", sid)]][,,,drop = FALSE])
    colnames(res) <- c("ClusterIdx", "SamplingNr", "Chain", "Value")
    res$Sample <- colnames(clsRes$Modelling.Data$AF)[sid]
    res
  }))
  dat$ClusterName <- clsRes$ClusterNameMap[dat$ClusterIdx]
  ggplot(subset(dat, ClusterIdx %in% unique(subset(clsRes$Clusters, Weight >= minWeight)$ClusterIdx)), aes(x = SamplingNr, y = Value, colour = ClusterName)) +
    geom_line() + theme_bw() + facet_grid(ClusterName ~ Chain + Sample) + theme(strip.text.y = element_text(angle = 0, hjust = 0))
}
