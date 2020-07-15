library(dplyr)
library(mlr)

model_files <- list.files("./models")

results <- data.frame(model = character(), 
                      task = character(), 
                      split = character(), 
                      n_params = numeric(), 
                      auc_test = numeric())

for(model_file in model_files){
  print(model_file)
  load(paste0("./models/", model_file))
  model_features <- unlist(strsplit(model_file, "_"))
  model_features[5] <- gsub(".rda", "", model_features[5])
  
  model_name <- model_features[1]
  task <- model_features[3]
  split <- model_features[5]
 
  model_results <- read_csv(paste0("auc_scores/",model_name, "_tsk_", task,".csv"), 
                                    col_types = cols(X1 = col_skip()))
   
  if(model_name %in% c("gbm", "gbmtuned", "gbm300")){
    m_gbm <- model$learner.model
    n_trees <- m_gbm$n.trees
    n_params <- 4 * n_trees
  }
  
  if(model_name == "logreg"){
    m_logreg <- model$learner.model
    n_params <- length(coefficients(m_logreg))
  }
  
  if(model_name == "svm"){
    m_svm <- model$learner.model
    n_params <- m_svm@nSV
  }
  
   
   new_row <-   data.frame(model = model_name,
                           task = task,
                           split = split, 
                           n_params = n_params,
                           auc_test = model_results[split, "auc_test"])
   results <- rbind(results, new_row)

}



write_csv(results, file = "./params_count/param_count.csv")
