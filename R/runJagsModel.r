runJagsModel <- function(input, model = createJagsModel(), Nclust = 10, shape1 = 1, shape2 = 1000, nAdapt = 3000, nBurnIn = 3000, nSample = 500, nChain = 1){
  stopifnot(class(input) == "list", "Input must be a list of two matrices, 'Support' and 'Coverage'!")
  stopifnot("Support" %in% names(input) & "Coverage" %in% names(input), "Input must be a list of two matrices, 'Support' and 'Coverage'!")
  stopifnot(dim(input$Support) == dim(input$Coverage), "Coverage and Support matrix must have same dimensions!")
  stopifnot(
    all(colnames(input$Support) %in% colnames(input$Coverage)) & all(colnames(input$Coverage) %in% colnames(input$Support)),
    "Coverage and Support do not contain the same sample IDs!"
    )
  stopifnot(
    all(rownames(input$Support) %in% rownames(input$Coverage)) & all(rownames(input$Coverage) %in% rownames(input$Support)),
    "Coverage and Support do not contain the same SNV IDs!"
  )
  if(!all(colnames(input$Support) == colnames(input$Coverage))){
    message("Coverage and Support matrix samples are not in the same order, using the sample order specified in the Support matrix!")
  }
  if(!all(rownames(input$Support) == rownames(input$Coverage))){
    message("Coverage and Support matrix SNVs are not in the same order, using the SNV order specified in the Support matrix!")
  }
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
