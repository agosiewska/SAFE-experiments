library(ggplot2)
library(dplyr)
library(readr)
library(OpenML)
library(tidyr)
library(kableExtra)

param_count_blackbox <- read_csv("benchmark/params_count/param_count_blackbox.csv")

param_count_logreg <- read_csv("benchmark/params_count/param_count_logreg.csv")

param_count_safe <- read_csv("benchmark/params_count/param_count_safe.csv")

tasks_oml100 <- listOMLTasks(tag="openml100", number.of.classes = 2, number.of.missing.values = 0)


results <- rbind(data.frame(param_count_safe, type = "safe"),
                 data.frame(param_count_blackbox, type= "blackbox"),
                 data.frame(param_count_logreg, type = "logreg"))
res <- results %>% 
  select(-n_params, -type) %>%
  group_by(model, task) %>%
  summarise(auc_mean = mean(auc_test), auc_sd = sd(auc_test)) %>%
  mutate(auc = paste0(round(auc_mean,2), "+-", round(auc_sd,2))) %>%
  select(model, task, auc) %>%
  pivot_wider(names_from = model, values_from = auc) %>%
  select(task, logreg, gbm, safe_logreg_gbm,  gbmtuned, safe_logreg_gbmtuned, svm, safe_logreg_svm) %>%
  drop_na() %>%
  left_join(tasks_oml100[,c("task.id", "name")], by = c("task"="task.id")) %>%
  select(task, name, logreg,  gbm, safe_logreg_gbm, gbmtuned, safe_logreg_gbmtuned, svm, safe_logreg_svm) #here we can also selec task

colnames(res) <- c("task", "dataset", "logreg", "gbm", "safe gbm", "gbm t.", "safe gbm t.", "svm", "safe svm")

kable(res, format = "latex")



res$dataset
