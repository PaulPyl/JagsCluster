verifyInput <- function(input){
  stopifnot(class(input) == "list")#, "Input must be a list of matrices, containing 'Support' and 'Coverage'!")
  stopifnot("Support" %in% names(input) & "Coverage" %in% names(input))#, "Input must be a list of two matrices, 'Support' and 'Coverage'!")
  stopifnot(dim(input$Support) == dim(input$Coverage))#, "Coverage and Support matrix must have same dimensions!")
  stopifnot(
    all(colnames(input$Support) %in% colnames(input$Coverage)) & all(colnames(input$Coverage) %in% colnames(input$Support))#,
    #"Coverage and Support do not contain the same sample IDs!"
  )
  stopifnot(
    all(rownames(input$Support) %in% rownames(input$Coverage)) & all(rownames(input$Coverage) %in% rownames(input$Support))#,
    #"Coverage and Support do not contain the same SNV IDs!"
  )
  if(!all(colnames(input$Support) == colnames(input$Coverage))){
    message("Coverage and Support matrix samples are not in the same order, using the sample order specified in the Support matrix!")
  }
  if(!all(rownames(input$Support) == rownames(input$Coverage))){
    message("Coverage and Support matrix SNVs are not in the same order, using the SNV order specified in the Support matrix!")
  }
  return(TRUE)
}
