# devtools::install_github("ModelOriented/rSAFE")

library(rSAFE)
library(DALEX)
library(DALEXtra)
library(OpenML)
library(dplyr)
library(mlr)
library(h2o)

h2o.init()

#### GBM ##################

model_name <- "gbm"

tasks_oml100 <- listOMLTasks(tag="openml100", number.of.classes = 2, number.of.missing.values = 0)

for(i in 2:(nrow(tasks_oml100)-1)){
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
  for(i in 3:6){
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





#### H2O ##################

model_name <- "h2o"

tasks_oml100 <- listOMLTasks(tag="openml100", number.of.classes = 2, number.of.missing.values = 0)

for(i in 3:5){
  # i <- 3
  
  task_id <- tasks_oml100[i, "task.id"]
  
  task <- getOMLTask(task.id = task_id)
  data_set <- task$input$data.set$data
  data_splits <- task[["input"]][["estimation.procedure"]][["data.splits"]]
  
  for(split_fold in 1:10){
    # split_fold <- 1
    print(paste(i, split_fold))
    
    file_name <- list.files(paste0("./models/h2o_tsk", task_id, "_fold_", split_fold))[[1]]
    
    model <- h2o.loadModel(paste0("./models/h2o_tsk", task_id, "_fold_", split_fold,"/", file_name))
    
    split_rows_test <- data_splits %>% filter(fold == split_fold & type == "TEST") %>% pull(rowid)
    split_rows_train <- data_splits %>% filter(fold == split_fold & type == "TRAIN") %>% pull(rowid)
    
    test <- data_set[split_rows_test, ]
    train <- data_set[split_rows_train, ]
    
    train_h2o <- as.h2o(train)
    test_h2o <- as.h2o(test)
    
    
    y_name <- task$input$target.features
    y <- train[,y_name]
    lvl <- levels(y)[1]
    y <- as.numeric(y == lvl)
    
    
    p_fun <- function(m, d){
      d <- as.h2o(d)
      pred_test <- as.data.frame(h2o.predict(model, d))
      pred_test[,3]
    }
    
    explainer <- explain_h2o(model, train %>% select(-y_name), y = y,
                label = paste0("model_tsk_", task_id, "_fold_", split_fold), 
                verbose = TRUE,
                predict_function = p_fun)

    safe_extractor <- safe_extraction(explainer, penalty = "MBIC", verbose = TRUE)
    
    save(safe_extractor, file = paste0("./safe_extractors/safe_extractor_", model_name, "_tsk_", task_id, "_fold_", split_fold, ".rda" ))
  }
}

