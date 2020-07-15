library(dplyr)
library(tidyr)
library(readr)

param_count_safe <- read_csv("params_count/param_count_safe.csv")
param_count <- read_csv("params_count/param_count.csv")


head(param_count)
head(param_count_safe)


matched_models  <- param_count_safe %>%
  separate(model, into = c("safe", "logreg", "model"), sep = "_") %>%
  select(model, task, split) %>%
  left_join(param_count, by = c("model", "task", "split"))

write_csv(matched_models, path = "./params_count/param_count_blackbox.csv")

logreg_models <- param_count %>%
  filter(model == "logreg")

write_csv(logreg_models, path = "./params_count/param_count_logreg.csv")


