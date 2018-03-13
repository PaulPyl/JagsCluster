plotResultSNVs <- function(clsRes){
  dat <- clsRes$Modelling.Data
  df <- do.call(rbind,lapply(seq(1, ncol(dat$AF)-1), function(i) do.call(rbind,lapply(seq(i+1, ncol(dat$AF)), function(j) {
    ret <- as.data.frame(dat$AF[,c(i,j)])
    ret$SampleOne <- colnames(dat$AF)[i]
    ret$SampleTwo <- colnames(dat$AF)[j]
    colnames(ret)[1:2] <- c("AFOne", "AFTwo")
    ret$SNVID <- rownames(dat$AF)
    ret
  }))))
  df$ClusterName <- dat$Cluster$ClusterName[match(df$SNVID, dat$Cluster$SNVID)]
  ggplot(df, aes(x = AFOne, y = AFTwo, fill = ClusterName)) +
    geom_point(shape = 21, size = 3, alpha = 0.6) + theme_bw() +
    facet_grid(SampleOne ~ SampleTwo) +
    xlim(0,1) + ylim(0,1)
}
