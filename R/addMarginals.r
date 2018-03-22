addMarginals <- function(p, ...){
  require(cowplot)
  df <- p$data
  df$Marginal <- "Top"
  xplot <- ggplot(df, aes(x = AFOne, group = ClusterName, fill = ClusterName)) + geom_density(alpha = 0.6) + facet_grid(Marginal ~ SampleTwo) + theme_bw() + xlim(0,1) + theme(legend.position = "top")
  df$Marginal <- "Right"
  yplot <- ggplot(df, aes(x = AFTwo, group = ClusterName, fill = ClusterName)) + geom_density(alpha = 0.6) + facet_grid(SampleOne ~ Marginal) + theme_bw() + xlim(0,1) + ylab("") + xlab("") + coord_flip() + theme(legend.position = "none")
  yplot
  # Arranging the plot
  plot_grid(
    xplot + ..., ggplot(data.frame(x=runif(10), y = runif(10)), aes(x=x, y=y)) + geom_blank() + theme_nothing(), p + theme(legend.position = "none") + ..., yplot + ..., ncol = 2, nrow = 2,  align = "hv", axis = "lb",
    rel_widths = c(2, 1), rel_heights = c(1, 2))
}
