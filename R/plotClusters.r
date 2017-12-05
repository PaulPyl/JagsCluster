plotClusters <- function(clusters){
  ggplot(clusters, aes(x = Sample, y = Mean, group = paste(Sample, Cluster), colour = Cluster)) +
    geom_point(aes(size = Weight)) + geom_line() + theme_bw() +
    geom_errorbar(aes(ymin = Mean - Var, ymax = Mean + Var)) +
    ylim(0,1) + scale_colour_brewer(palette = "Set1")
}
