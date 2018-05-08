plotResultSNVs <- function(clsRes, mode = "point"){
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
  p <- ggplot(df, aes(x = AFOne, y = AFTwo, fill = ClusterName)) +
    xlim(0,1) + ylim(0,1) + theme_bw()
  if(mode == "point"){
    p <- p + geom_point(shape = 21, size = 3, alpha = 0.6)
  }else if(mode == "density2d"){
    p <- p + stat_density2d(alpha = 0.6, contour = TRUE, colour = "grey70", size = 0.25, geom = "polygon")
  }
  if(ncol(dat$AF) == 2){
    p <- p + xlab(colnames(dat$AF)[1]) + ylab(colnames(dat$AF)[2])
  }else{
    p <- p + facet_grid(SampleOne ~ SampleTwo)
  }
}
