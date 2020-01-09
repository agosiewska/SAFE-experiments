library(OpenML)
library(dplyr)
library(mlr)
library(mltools)

set.seed(123)

##### GBM  ##############

tasks_oml100 <- listOMLTasks(tag="openml100", number.of.classes = 2, number.of.missing.values = 0)


# skip 1st row due to split 8:
# Error in `contrasts<-`(`*tmp*`, value = contr.funs[1 + isOF[nn]]) : 
#   contrasts can be applied only to factors with 2 or more levels


# skip 35th row due to:
# Error in gbm.fit(x = x, y = y, offset = offset, distribution = distribution,  : 
#                    gbm does not currently handle categorical variables with more than 1024 levels. Variable 1: RESOURCE has 7085 levels.


for(i in 2:(nrow(tasks_oml100)-1)){
  # i <- 2

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
    
    split_rows_test <- data_splits %>% filter(fold == split_fold & type == "TEST") %>% pull(rowid)
    split_rows_train <- data_splits %>% filter(fold == split_fold & type == "TRAIN") %>% pull(rowid)
    
    test <- data_set[split_rows_test, ]
    train <- data_set[split_rows_train, ]
    
    lrn <- makeLearner("classif.gbm", predict.type = "prob", 
                       par.vals = list(interaction.depth = 1))
    
    tsk <- makeClassifTask(data = train, target = task$input$target.features)
    
    model <- train(learner=lrn, task=tsk)
    
    save(model, file = paste0("./models/gbm_tsk_", task_id, "_fold_", split_fold,".rda"))
    
    predictions_train <-  getPredictionProbabilities(predict(model, newdata = train))
    predictions_test <-  getPredictionProbabilities(predict(model, newdata = test))
    
    # How good is this model?
    y_test <- test[, task$input$target.features]
    y_train <- train[, task$input$target.features]
    lvl <- levels(y_test)[1]
    
    new_result = data.frame(model = "gbm",
                            split = split_fold,
                            auc_train = auc_roc(predictions_train, y_train == lvl),
                            auc_test = auc_roc(predictions_test, y_test == lvl))
    results <- rbind(results, new_result)
  }  
  
  write.csv(results, file = paste0("./auc_scores/gbm_tsk_", task_id, ".csv"))
  

}
  

#### GLM ###################

tasks_oml100 <- listOMLTasks(tag="openml100", number.of.classes = 2, number.of.missing.values = 0)

for(i in 2:(nrow(tasks_oml100)-1)){
  # i <- 2
  
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
    
    split_rows_test <- data_splits %>% filter(fold == split_fold & type == "TEST") %>% pull(rowid)
    split_rows_train <- data_splits %>% filter(fold == split_fold & type == "TRAIN") %>% pull(rowid)
    
    test <- data_set[split_rows_test, ]
    train <- data_set[split_rows_train, ]
    
    lrn <- makeLearner("classif.logreg", predict.type = "prob")
    
    tsk <- makeClassifTask(data = train, target = task$input$target.features)
    
    model <- train(learner=lrn, task=tsk)
    
    save(model, file = paste0("./models/logreg_tsk_", task_id, "_fold_", split_fold,".rda"))
    
    predictions_train <-  getPredictionProbabilities(predict(model, newdata = train))
    predictions_test <-  getPredictionProbabilities(predict(model, newdata = test))
    
    # How good is this model?
    y_test <- test[, task$input$target.features]
    y_train <- train[, task$input$target.features]
    lvl <- levels(y_test)[1]
    
    new_result = data.frame(model = "gbm",
                            split = split_fold,
                            auc_train = auc_roc(predictions_train, y_train == lvl),
                            auc_test = auc_roc(predictions_test, y_test == lvl))
    results <- rbind(results, new_result)
  }  
  
  write.csv(results, file = paste0("./auc_scores/logreg_tsk_", task_id, ".csv"))
  
  
}

#### SVM ###################

tasks_oml100 <- listOMLTasks(tag="openml100", number.of.classes = 2, number.of.missing.values = 0)

for(i in 2:(nrow(tasks_oml100)-1)){
  # i <- 2
  
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
    
    split_rows_test <- data_splits %>% filter(fold == split_fold & type == "TEST") %>% pull(rowid)
    split_rows_train <- data_splits %>% filter(fold == split_fold & type == "TRAIN") %>% pull(rowid)
    
    test <- data_set[split_rows_test, ]
    train <- data_set[split_rows_train, ]
    
    lrn <- makeLearner("classif.ksvm", predict.type = "prob")
    
    tsk <- makeClassifTask(data = train, target = task$input$target.features,
                           fixup.data = "no",check.data = FALSE)
    
    model <- train(learner=lrn, task=tsk)
    
    save(model, file = paste0("./models/svm_tsk_", task_id, "_fold_", split_fold,".rda"))
    
    predictions_train <-  getPredictionProbabilities(predict(model, newdata = train))
    predictions_test <-  getPredictionProbabilities(predict(model, newdata = test))
    
    # How good is this model?
    y_test <- test[, task$input$target.features]
    y_train <- train[, task$input$target.features]
    lvl <- levels(y_test)[1]
    
    new_result = data.frame(model = "svm",
                            split = split_fold,
                            auc_train = auc_roc(predictions_train, y_train == lvl),
                            auc_test = auc_roc(predictions_test, y_test == lvl))
    results <- rbind(results, new_result)
  }  
  
  write.csv(results, file = paste0("./auc_scores/svm_tsk_", task_id, ".csv"))
  
  
}

