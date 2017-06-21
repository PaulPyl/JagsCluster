runJagsModel <- function(input, model = createJagsModel(), Nclust = 10, shape1 = 1, shape2 = 1000, nAdapt = 3000, nBurnIn = 3000, nSample = 500, nChain = 1){
  verifyInput(input)
  dataList = list(
    Nsnvs = nrow(input$Support),
    Nclust = Nclust,
    shape1 = shape1,
    shape2 = shape2
  )
  for(i in seq(ncol(input$Support))){
    dataList[[paste("count", i, sep = ".")]] <- input$Support[rownames(input$Support),colnames(input$Support)[i]]
    dataList[[paste("coverage", i, sep = ".")]] <- input$Coverage[rownames(input$Support),colnames(input$Support)[i]]
  }
  #Model
  jags <- jags.model(textConnection(model),
                     data = dataList,
                     n.chains = nChain,
                     n.adapt = nAdapt)
  #Burn-In
  update(jags, nBurnIn)
  #Sampling
  res <- jags.samples(jags,
                      c('clust', 'cluster.weight', paste("cluster.center", seq(ncol(input$Support)), sep = ".") ),
                      nSamples)
  res
}
