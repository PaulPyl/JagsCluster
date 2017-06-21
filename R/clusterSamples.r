clusterSamples <- function(input, Nclust = 10, nAdapt = 1000, nBurnIn = 2000, nSamples = 500, nChain = 1, maxSNVs = 1000, minAF = 0.1, varCF = Inf, minCov = 10){
  verifyInput(input) # check if input is valid
  input$AF <- input$Support / input$Coverage
  selectedSNVs <- rowSums(input$AF >= minAF) >= 1 & rowSums(input$Coverage >= minCov) >= 1
  if(length(selectedSNVs) == 0){
    stop("No SNV calls passed filtering, consider revising criteria and check input.")
  }
  input <- lapply(input, function(m) m[selectedSNVs,])
  if(length(selectedSNVs) > maxSNVs){
    message(paste0("Input too large (", length(selectedSNVs), " variant calls), subsamping to ", maxSNVs, " for modelling."))
    selectedSNVs <- sample(x = selectedSNVs, size = maxSNVs, replace = FALSE)
    input <- lapply(input, function(m) m[selectedSNVs,])
  }
  res <- runJagsModel(input, model = createJagsModel(nSamples = ncol(input$Support)), Nclust = Nclust, nAdapt = nAdapt, nBurnIn = nBurnIn, nSamples = nSamples, nChain = nChain)
  centers <- lapply(seq(ncol(input$Support)), function(i){
    data.frame(
      "Means"     = apply(res[[paste0("cluster.center", i)]], 1, mean),
      "Vars"      = apply(res[[paste0("cluster.center", i)]], 1, var),
      "toRemove"  = apply(res[[paste0("cluster.center", i)]], 1, var) >= VarCF,
      stringsAsFactors = FALSE
    )
  })
  weights <- apply(res$cluster.weight, 1, mean)
  list(
    "jags.result"    = res,
    "Modelling.Data" = input,
    "Centers"        = centers,
    "Weights"        = weights
  )
}
