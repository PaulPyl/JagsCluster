plotClusters <- function(clsRes, mode = "point",  minWeight = 0.01){
  nSamples <- ncol(clsRes$Modelling.Data$AF)
  theSamples <- colnames(clsRes$Modelling.Data$AF)
  dat <- do.call(rbind,lapply(seq(nSamples), function(sid){
    res <- melt(clsRes$jags.result[[paste0("cluster.center.", sid)]][,,,drop = FALSE])
    colnames(res) <- c("ClusterIdx", "SamplingNr", "Chain", "Value")
    res$Sample <- colnames(clsRes$Modelling.Data$AF)[sid]
    res
  }))
  dat <- subset(dat, ClusterIdx %in% unique(subset(clsRes$Clusters, Weight >= minWeight)$ClusterIdx))
  df <- do.call(rbind,lapply(seq(1, ncol(clsRes$Modelling.Data$AF)-1), function(i) do.call(rbind,lapply(seq(i+1, ncol(clsRes$Modelling.Data$AF)), function(j) {
    reta <- subset(dat, Sample == theSamples[i])
    retb <- subset(dat, Sample == theSamples[j])
    colnames(reta)[4] <- "AFOne"
    colnames(retb)[4] <- "AFTwo"
    colnames(reta)[5] <- "SampleOne"
    colnames(retb)[5] <- "SampleTwo"
    merge(reta, retb)
  }))))
  df$ClusterName <- clsRes$ClusterNameMap[df$ClusterIdx]
  p <- ggplot(df, aes(x = AFOne, y = AFTwo, fill = ClusterName)) +
    facet_grid(SampleOne ~ SampleTwo) +
    xlim(0,1) + ylim(0,1) + theme_bw()
  if(mode == "point"){
    p <- p + geom_point(shape = 21, size = 3, alpha = 0.6)
  }else if(mode == "density2d"){
    p <- p + stat_density2d(alpha = 0.6, contour = TRUE, colour = "grey70", size = 0.25, geom = "polygon")
  }
}
