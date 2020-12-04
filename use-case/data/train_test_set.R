library(OpenML)
library(dplyr)
task <- getOMLTask(task.id = 31)
data_set <- task$input$data.set$data
data_splits <- task[["input"]][["estimation.procedure"]][["data.splits"]]
split_fold <- 4
split_rows_test <- data_splits %>% filter(fold == split_fold & type == "TEST") %>% pull(rowid)
split_rows_train <- data_splits %>% filter(fold == split_fold & type == "TRAIN") %>% pull(rowid)
test <- data_set[split_rows_test, ]
train <- data_set[split_rows_train, ]
head(test)


# save(train, file = "data/train.csv")
# save(test, file = "data/test.csv")
