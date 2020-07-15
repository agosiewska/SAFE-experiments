# devtools::install_github("ModelOriented/rSAFE")

library(rSAFE)
library(DALEX)
library(DALEXtra)
library(OpenML)
library(dplyr)
library(mlr)
library(h2o)

#### GBM ##################

model_name <- "gbm"

tasks_oml100 <- listOMLTasks(tag="openml100", number.of.classes = 2, number.of.missing.values = 0)

for(i in c(2:23, 26:29, 30:34)){
  # i <- 3
  
  task_id <- tasks_oml100[i, "task.id"]
  
  task <- getOMLTask(task.id = task_id)
  data_set <- task$input$data.set$data
  data_splits <- task[["input"]][["estimation.procedure"]][["data.splits"]]
  
  for(split_fold in 1:10){
    # split_fold <- 1
    print(paste(i, split_fold))
    
    load(paste0("./models/", model_name, "_tsk_", task_id, "_fold_", split_fold, ".rda"))
    
    split_rows_test <- data_splits %>% filter(fold == split_fold & type == "TEST") %>% pull(rowid)
    split_rows_train <- data_splits %>% filter(fold == split_fold & type == "TRAIN") %>% pull(rowid)
    
    test <- data_set[split_rows_test, ]
    train <- data_set[split_rows_train, ]
    
    y_name <- task$input$target.features
    y <- train[,y_name]
    
    explainer <- explain_mlr(model, data = train %>% select(-y_name), y = as.numeric(y), 
                             label = paste0("model_tsk_", task_id, "_fold_", split_fold), 
                             verbose = FALSE)

    
    safe_extractor <- safe_extraction(explainer, penalty = "MBIC", verbose = TRUE)
    
    save(safe_extractor, file = paste0("./safe_extractors/safe_extractor_", model_name, "_tsk_", task_id, "_fold_", split_fold, ".rda" ))
  }
}







### SVM ##############################

model_name <- "svm"

tasks_oml100 <- listOMLTasks(tag="openml100", number.of.classes = 2, number.of.missing.values = 0)


# for(i in 2:(nrow(tasks_oml100)-1)){
  for(i in c(2:23, 26:29, 30:34)){
    # i <- 2

  task_id <- tasks_oml100[i, "task.id"]
  
  task <- getOMLTask(task.id = task_id)
  data_set <- task$input$data.set$data
  for(a in colnames(data_set)){
    if(class(data_set[,a]) == "factor") data_set[,a] <- droplevels(data_set[,a])
  }
  data_splits <- task[["input"]][["estimation.procedure"]][["data.splits"]]
  
  for(split_fold in 1:10){
    # split_fold <- 1
    print(paste(i, split_fold))
    
    load(paste0("./models/", model_name, "_tsk_", task_id, "_fold_", split_fold, ".rda"))
    
    split_rows_test <- data_splits %>% filter(fold == split_fold & type == "TEST") %>% pull(rowid)
    split_rows_train <- data_splits %>% filter(fold == split_fold & type == "TRAIN") %>% pull(rowid)
    
    test <- data_set[split_rows_test, ]
    train <- data_set[split_rows_train, ]
    
    y_name <- task$input$target.features
    y <- train[,y_name]
    
    explainer <- explain_mlr(model, data = train %>% select(-y_name), y = as.numeric(y), 
                             label = paste0("model_tsk_", task_id, "_fold_", split_fold), 
                             verbose = FALSE)
    
    
    safe_extractor <- safe_extraction(explainer, penalty = "MBIC", verbose = TRUE)
    
    save(safe_extractor, file = paste0("./safe_extractors/safe_extractor_", model_name, "_tsk_", task_id, "_fold_", split_fold, ".rda" ))
  }
  
}



#### GBM TUNED ##################

model_name <- "gbm"

tasks_oml100 <- listOMLTasks(tag="openml100", number.of.classes = 2, number.of.missing.values = 0)

for(i in c(2:23, 26:29, 30:34)){
  # i <- 3
  
  task_id <- tasks_oml100[i, "task.id"]
  
  task <- getOMLTask(task.id = task_id)
  data_set <- task$input$data.set$data
  data_splits <- task[["input"]][["estimation.procedure"]][["data.splits"]]
  
  for(split_fold in 10){
    # split_fold <- 1
    print(paste(i, split_fold))
    
    load(paste0("./models/", model_name, "_tsk_", task_id, "_fold_", split_fold, ".rda"))
    
    split_rows_test <- data_splits %>% filter(fold == split_fold & type == "TEST") %>% pull(rowid)
    split_rows_train <- data_splits %>% filter(fold == split_fold & type == "TRAIN") %>% pull(rowid)
    
    test <- data_set[split_rows_test, ]
    train <- data_set[split_rows_train, ]
    
    y_name <- task$input$target.features
    y <- train[,y_name]
    
    explainer <- explain_mlr(model, data = train %>% select(-y_name), y = as.numeric(y), 
                             label = paste0("model_tsk_", task_id, "_fold_", split_fold), 
                             verbose = FALSE)
    
    
    safe_extractor <- safe_extraction(explainer, penalty = "MBIC", verbose = TRUE)
    
    save(safe_extractor, file = paste0("./safe_extractors/safe_extractor_", model_name, "_tsk_", task_id, "_fold_", split_fold, ".rda" ))
  }
}
