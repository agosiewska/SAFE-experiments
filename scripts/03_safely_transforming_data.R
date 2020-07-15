library(rSAFE)
library(DALEX)
library(DALEXtra)
library(OpenML)
library(dplyr)
library(mlr)
library(mltools)


### GBM #################

model_name <- "gbm"

tasks_oml100 <- listOMLTasks(tag="openml100", number.of.classes = 2, number.of.missing.values = 0)

for(i in 2:(nrow(tasks_oml100)-1)){

  # i <- 3
  
  task_id <- tasks_oml100[i, "task.id"]
  
  task <- getOMLTask(task.id = task_id)
  data_set <- task$input$data.set$data
  data_splits <- task[["input"]][["estimation.procedure"]][["data.splits"]]
  
  
  results <- data.frame(model = character(),
                        split = numeric(),
                        auc_train = numeric(),
                        auc_test = numeric())
  
  
  for(split_fold in 1:10){
    # split_fold <- 1
    
    print(paste(i, split_fold))
      
    load(paste0("./safe_extractors/safe_extractor_", model_name, "_tsk_", task_id, "_fold_", split_fold, ".rda"))
    
    split_rows_test <- data_splits %>% filter(fold == split_fold & type == "TEST") %>% pull(rowid)
    split_rows_train <- data_splits %>% filter(fold == split_fold & type == "TRAIN") %>% pull(rowid)
    
    test <- data_set[split_rows_test, ]
    train <- data_set[split_rows_train, ]
    
    
    transformed_train <- safely_transform_data(safe_extractor, train, verbose = FALSE)
    new_features <- setdiff(colnames(transformed_train), colnames(train))
    transformed_train <- transformed_train[, c(new_features, task$input$target.features)]
    
    transformed_test <- safely_transform_data(safe_extractor, test, verbose = FALSE)
    transformed_test <- transformed_test[, c(new_features, task$input$target.features)]
    
    save(transformed_train, file = paste0("./safely_transformed_data/safe_train_", model_name, "_tsk_", task_id, "_fold_", split_fold, ".rda"))
    save(transformed_test, file = paste0("./safely_transformed_data/safe_test_", model_name, "_tsk_", task_id, "_fold_", split_fold, ".rda"))
    
    lrn <- makeLearner("classif.logreg", predict.type = "prob")
    
    tsk <- makeClassifTask(data = transformed_train, target = task$input$target.features)
    
    safe_model <- train(learner=lrn, task=tsk)
    
    save(safe_model, file = paste0("./safe_models/safe_logreg_", model_name,"_tsk_", task_id, "_fold_", split_fold,".rda"))
    
    predictions_train <-  getPredictionProbabilities(predict(safe_model, newdata = transformed_train))
    predictions_test <-  getPredictionProbabilities(predict(safe_model, newdata = transformed_test))
    
    # How good is this model?
    y_test <- transformed_test[, task$input$target.features]
    y_train <- transformed_train[, task$input$target.features]
    lvl <- levels(y_test)[1]
    
    new_result = data.frame(model = paste0("safe_logreg_", model_name),
                            split = split_fold,
                            auc_train = auc_roc(predictions_train, y_train == lvl),
                            auc_test = auc_roc(predictions_test, y_test == lvl))
    results <- rbind(results, new_result)
  
  }
  write.csv(results, file = paste0("./auc_scores/safe_logreg_", model_name, "_tsk_", task_id, ".csv"))
    
}  
  
  
  
### SVM #################

model_name <- "svm"

tasks_oml100 <- listOMLTasks(tag="openml100", number.of.classes = 2, number.of.missing.values = 0)

for(i in 2:(nrow(tasks_oml100)-1)){

  # i <- 3
  
  task_id <- tasks_oml100[i, "task.id"]
  
  task <- getOMLTask(task.id = task_id)
  data_set <- task$input$data.set$data
  for(a in colnames(data_set)){
    if(class(data_set[,a]) == "factor") data_set[,a] <- droplevels(data_set[,a])
  }
  data_splits <- task[["input"]][["estimation.procedure"]][["data.splits"]]
  
  
  results <- data.frame(model = character(),
                        split = numeric(),
                        auc_train = numeric(),
                        auc_test = numeric())
  
  
  for(split_fold in 1:10){
    # split_fold <- 1
    
    print(paste(i, split_fold))
    
    load(paste0("./safe_extractors/safe_extractor_", model_name, "_tsk_", task_id, "_fold_", split_fold, ".rda"))
    
    split_rows_test <- data_splits %>% filter(fold == split_fold & type == "TEST") %>% pull(rowid)
    split_rows_train <- data_splits %>% filter(fold == split_fold & type == "TRAIN") %>% pull(rowid)
    
    test <- data_set[split_rows_test, ]
    train <- data_set[split_rows_train, ]
    
    
    transformed_train <- safely_transform_data(safe_extractor, train, verbose = FALSE)
    new_features <- setdiff(colnames(transformed_train), colnames(train))
    transformed_train <- transformed_train[, c(new_features, task$input$target.features)]
    
    transformed_test <- safely_transform_data(safe_extractor, test, verbose = FALSE)
    transformed_test <- transformed_test[, c(new_features, task$input$target.features)]
    
    save(transformed_train, file = paste0("./safely_transformed_data/safe_train_", model_name, "_tsk_", task_id, "_fold_", split_fold, ".rda"))
    save(transformed_test, file = paste0("./safely_transformed_data/safe_test_", model_name, "_tsk_", task_id, "_fold_", split_fold, ".rda"))
    
    lrn <- makeLearner("classif.logreg", predict.type = "prob")

    tsk <- makeClassifTask(data = transformed_train, target = task$input$target.features)
    
    safe_model <- train(learner=lrn, task=tsk)    
    
    save(safe_model, file = paste0("./safe_models/safe_logreg_", model_name,"_tsk_", task_id, "_fold_", split_fold,".rda"))
    
    predictions_train <-  getPredictionProbabilities(predict(safe_model, newdata = transformed_train))
    predictions_test <-  getPredictionProbabilities(predict(safe_model, newdata = transformed_test))
    
    # How good is this model?
    y_test <- transformed_test[, task$input$target.features]
    y_train <- transformed_train[, task$input$target.features]
    lvl <- levels(y_test)[1]
    
    new_result = data.frame(model = paste0("safe_logreg_", model_name),
                            split = split_fold,
                            auc_train = auc_roc(predictions_train, y_train == lvl),
                            auc_test = auc_roc(predictions_test, y_test == lvl))
    results <- rbind(results, new_result)
    
  }
  write.csv(results, file = paste0("./auc_scores/safe_logreg_", model_name, "_tsk_", task_id, ".csv"))
}