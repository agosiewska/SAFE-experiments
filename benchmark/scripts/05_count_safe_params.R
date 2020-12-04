library(dplyr)
library(mlr)
library(readr)

model_files <- list.files("./safe_models")

results <- data.frame(model = character(), 
                      task = character(), 
                      split = character(), 
                      n_params = numeric(), 
                      auc_test = numeric())

for(model_file in model_files){
  print(model_file)
  load(paste0("./safe_models/", model_file))
  model_features <- unlist(strsplit(model_file, "_"))
  model_features[7] <- gsub(".rda", "", model_features[7])
  
  model_name <- paste(model_features[1:3], collapse = "_")
  task <- model_features[5]
  split <- model_features[7]
  
  model_results <- read_csv(paste0("auc_scores/",model_name, "_tsk_", task,".csv"), 
                            col_types = cols(X1 = col_skip()))
  m_logreg <- safe_model$learner.model
  n_params <- length(coefficients(m_logreg))

  
  
  new_row <-   data.frame(model = model_name,
                          task = task,
                          split = split, 
                          n_params = n_params,
                          auc_test = model_results[split, "auc_test"])
  results <- rbind(results, new_row)
  
}



write_csv(results, path = "./params_count/param_count_safe.csv")
