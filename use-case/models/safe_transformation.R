#### SAFE TRANSFORMATION ####
devtools::install_github("ModelOriented/rSAFE")
library(DALEX)
library(DALEXtra)
library(rSAFE)
explainer_gbm <- explain_mlr(mod_gbm, 
                             data = train, 
                             y = train$class == "bad")

safe_extractor_gbm <- safe_extraction(explainer_gbm,
                                      response_type = "pdp")

#save(safe_extractor_gbm, file = "./models/safe_extractor_gbm_german_credit_split4.rda")