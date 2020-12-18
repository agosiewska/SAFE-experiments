#### SAFE TRANSFORMATION ####
# devtools::install_github("ModelOriented/rSAFE")
library(DALEX)
library(DALEXtra)
library(rSAFE)

load("./use-case/data/train.rda")
load("./use-case/data/test.rda")
load("./use-case/models/mod_gbm_credit.rda")

explainer_gbm <- explain_mlr(mod_gbm, 
                             data = train, 
                             y = train$class == "bad")

safe_extractor_gbm <- safe_extraction(explainer_gbm,
                                      response_type = "pdp")

# save(safe_extractor_gbm, file = "./use-case/models/safe_extractor_gbm_german_credit_split4.rda")
