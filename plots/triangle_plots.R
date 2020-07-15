library(ggplot2)
library(readr)
library(dplyr)
library(tidyr)
library(ggtern)
library(patchwork)


calculate_scores <- function(res1, res2, res3, cols = c("x1", "x2", "x3")){
  res1_score_1 <- res1 >= res2
  res1_score_2 <- res1 >= res3
  res1_score <- (res1_score_1 + res1_score_2) / 2
  
  res2_score_1 <- res2 >= res1
  res2_score_2 <- res2 >= res3
  res2_score <- (res2_score_1 + res2_score_2) / 2
  
  res3_score_1 <- res3 >= res1
  res3_score_2 <- res3 >= res2
  res3_score <- (res3_score_1 + res3_score_2) / 2
  
  df <- data.frame(res1_score, res2_score, res3_score)
  colnames(df) <- cols
  df
}

all_results <- data.frame()

for(i in c(37, 43, 49, 219, 3485, 3492, 3493, 3494, 3891, 3899, 3902, 3913, 3917, 3918, 3954, 
           9946, 9952, 9957, 9970, 9971, 9976, 9978, 9980, 9983,
           14965, 10101, 10093, 34537)){
  for(j in c("logreg", "gbm", "gbmtuned", "svm", "safe_logreg_svm", "safe_logreg_gbm", "safe_logreg_gbmtuned")){
    tmp_res <- read_csv(paste0("auc_scores/", j, "_tsk_", i, ".csv"), col_types = cols(X1 = col_skip()))
    tmp_res$task <- i
    all_results <- rbind(all_results, tmp_res)  
  }
}


ggplot(all_results, aes(x = factor(task), y = auc_test, fill = factor(model))) +
  geom_boxplot() +
  coord_flip()


all_results %>% 
  select(model) %>%
  unique()


### GBM

gbm_results <- all_results %>%
  filter(model %in% c("logreg", "gbm", "safe_logreg_gbm")) %>%
  select (-auc_train) %>%
  pivot_wider(names_from = model, values_from = auc_test)

scores <- calculate_scores(gbm_results[["gbm"]], gbm_results[["logreg"]], gbm_results[["safe_logreg_gbm"]], cols = c("gbm_wins", "logreg_wins", "safe_logreg_gbm_wins"))
gbm_results <- cbind(gbm_results, scores)


gbm_fraqs <- gbm_results %>%
  select(task, gbm_wins, logreg_wins, safe_logreg_gbm_wins) %>%
  group_by(task) %>%
  summarise(gbm_freq = sum(gbm_wins)/10, 
            logreg_freq = sum(logreg_wins)/10,
            safe_logreg_gbm_freq = sum(safe_logreg_gbm_wins)/10) %>%
  print()



gbm_area <- data.frame(            xx = c(0, 0.5, 1, 0.5, 0),
                                   yy = c(0, 0.5, 0, 0,   0),
                                   zz = c(0, 0,   0, 0.5, 0),        Series="Green")
logreg_area <- data.frame(         xx = c(0, 0,   0, 0.5, 0),
                                   yy = c(0, 0.5, 0, 0,   0),
                                   zz = c(0, 0.5, 1, 0.5, 0),        Series="Red")
safe_logreg_gbm_area <- data.frame(xx = c(0, 0,   0, 0.5,   0),
                                   yy = c(0, 0.5, 1, 0.5, 0),
                                   zz = c(0, 0.5, 0, 0, 0),        Series="Blue")

DATA <- rbind(gbm_area, logreg_area, safe_logreg_gbm_area)

gbm_plot <- ggtern(gbm_fraqs, aes(gbm_freq, logreg_freq, safe_logreg_gbm_freq)) +
  theme_nomask() +
  geom_polygon(aes(xx, yy, zz, fill=Series),alpha=.5,color="black",size=0.25, data = DATA) +
  scale_fill_manual(values=as.character(unique(DATA$Series))) +
  geom_point(size = 3) 

gbm_plot







### SVM ##################

svm_results <- all_results %>%
  filter(model %in% c("logreg", "svm", "safe_logreg_svm")) %>%
  select (-auc_train) %>%
  pivot_wider(names_from = model, values_from = auc_test)


scores <- calculate_scores(svm_results[["svm"]], svm_results[["logreg"]], svm_results[["safe_logreg_svm"]], cols = c("svm_wins", "logreg_wins", "safe_logreg_svm_wins"))
svm_results <- cbind(svm_results, scores)

svm_fraqs <- svm_results %>%
  select(task, svm_wins, logreg_wins, safe_logreg_svm_wins) %>%
  group_by(task) %>%
  summarise(svm_freq = sum(svm_wins)/10, 
            logreg_freq = sum(logreg_wins)/10,
            safe_logreg_svm_freq = sum(safe_logreg_svm_wins)/10) %>%
  print()



svm_area <- data.frame(            xx = c(0, 0.5, 1, 0.5, 0),
                                   yy = c(0, 0.5, 0, 0,   0),
                                   zz = c(0, 0,   0, 0.5, 0),        Series="Green")
logreg_area <- data.frame(         xx = c(0, 0,   0, 0.5, 0),
                                   yy = c(0, 0.5, 0, 0,   0),
                                   zz = c(0, 0.5, 1, 0.5, 0),        Series="Red")
safe_logreg_svm_area <- data.frame(xx = c(0, 0,   0, 0.5, 0),
                                   yy = c(0, 0.5, 1, 0.5, 0),
                                   zz = c(0, 0.5, 0, 0,   0),        Series="Blue")

DATA <- rbind(svm_area, logreg_area, safe_logreg_svm_area)


svm_plot <- ggtern(svm_fraqs, aes(svm_freq, logreg_freq, safe_logreg_svm_freq)) +
  theme_nomask() +
  geom_polygon(aes(xx, yy, zz, fill=Series),alpha=.5,color="black",size=0.25, data = DATA) +
  scale_fill_manual(values=as.character(unique(DATA$Series)))+
  geom_point(size = 3)

svm_plot










### GBM tuned ####


gbmtuned_results <- all_results %>%
  filter(model %in% c("logreg", "gbmtuned", "safe_logreg_gbmtuned")) %>%
  select (-auc_train) %>%
  spread(model, "auc_test")

scores <- calculate_scores(gbmtuned_results[["gbmtuned"]], gbmtuned_results[["logreg"]], gbmtuned_results[["safe_logreg_gbmtuned"]], cols = c("gbmtuned_wins", "logreg_wins", "safe_logreg_gbmtuned_wins"))
gbmtuned_results <- cbind(gbmtuned_results, scores)


gbmtuned_fraqs <- gbmtuned_results %>%
  select(task, gbmtuned_wins, logreg_wins, safe_logreg_gbmtuned_wins) %>%
  group_by(task) %>%
  summarise(gbmtuned_freq = sum(gbmtuned_wins)/10, 
            logreg_freq = sum(logreg_wins)/10,
            safe_logreg_gbmtuned_freq = sum(safe_logreg_gbmtuned_wins)/10) %>%
  print()



gbm_area <- data.frame(            xx = c(0, 0.5, 1, 0.5, 0),
                                   yy = c(0, 0.5, 0, 0,   0),
                                   zz = c(0, 0,   0, 0.5, 0),        Series="Green")
logreg_area <- data.frame(         xx = c(0, 0,   0, 0.5, 0),
                                   yy = c(0, 0.5, 0, 0,   0),
                                   zz = c(0, 0.5, 1, 0.5, 0),        Series="Red")
safe_logreg_gbm_area <- data.frame(xx = c(0, 0,   0, 0.5,   0),
                                   yy = c(0, 0.5, 1, 0.5, 0),
                                   zz = c(0, 0.5, 0, 0, 0),        Series="Blue")


DATA <- rbind(gbm_area, logreg_area, safe_logreg_gbm_area)


gbmtuned_plot <- ggtern(gbmtuned_fraqs, aes(gbmtuned_freq, logreg_freq, safe_logreg_gbmtuned_freq)) +
  theme_nomask() +
  geom_polygon(aes(xx, yy, zz, fill=Series),alpha=.5,color="black",size=0.25, data = DATA) +
  scale_fill_manual(values=as.character(unique(DATA$Series))) +
  geom_point(size = 3) 

gbmtuned_plot





save(gbm_plot, svm_plot,gbmtuned_plot, file = "triangle_plots.rda")
