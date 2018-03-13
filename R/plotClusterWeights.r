plotClusterWeights <- function(dat){
  ggplot(dat$Clusters, aes(x = Mean, y = Weight, fill = ClusterName, size = Weight)) +
    geom_point(shape = 21) + facet_wrap(~ Sample, ncol = 1) +
    theme_bw() + xlim(0,1) + ylim(0,1)
}
