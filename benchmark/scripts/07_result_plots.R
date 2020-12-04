library(ggplot2)
library(dplyr)
library(readr)
library(tidyr)
param_count_blackbox <- read_csv("params_count/param_count_blackbox.csv")
View(param_count_blackbox)

library(readr)
param_count_logreg <- read_csv("params_count/param_count_logreg.csv")
View(param_count_logreg)

library(readr)
param_count_safe <- read_csv("params_count/param_count_safe.csv")
View(param_count_safe)



results <- rbind(data.frame(param_count_safe, type = "safe"),
                 data.frame(param_count_blackbox, type= "blackbox"))
df <- results %>% 
  group_by(task, model) %>%
  summarise(auc = mean(auc_test), n_params = mean(n_params))
  
df2 <- df %>% 
  separate(model, c("x1", 'safe', "model"))
df2$model <- ifelse(is.na(df2$model), df2$x1, df2$model)
df2$safe <- ifelse(is.na(df2$safe), "blackbox", "safe")
df2 <- df2 %>%
  select(-x1)
df2 <- df2 %>% 
  pivot_wider(names_from = safe, values_from = auc:n_params)
ggplot(df2, aes(x = auc_blackbox, xend = auc_safe, y = 1/n_params_blackbox, yend = 1/n_params_safe, color = factor(task))) +
  geom_segment(arrow = arrow()) +
  facet_wrap(~model) +
  scale_y_log10() +
  geom_smooth(aes(x = auc_blackbox, y = 1/n_params_blackbox), color = "black", se = FALSE) + 
  geom_smooth(aes(x = auc_safe, y = 1/n_params_safe), color = "black", se = FALSE)



df2 %>%
  split(df2$model) %>%
    lapply(function(x) {wilcox.test(x$n_params_blackbox, x$n_params_safe)$p.value})
