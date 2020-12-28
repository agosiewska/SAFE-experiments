library(ggplot2)
library(latex2exp)

## data auc for train and test data set, n_params for models
param <- data.frame(model = factor(c("vanilla logistic regression",
                                     "gbm", 
                                     "glm on all variables",
                                     "SAFE logistic regression"), 
                                   levels = c("gbm", 
                                              "vanilla logistic regression", 
                                              "glm on all variables", 
                                              "SAFE logistic regression")),
                    auc_test = c(0.7786, 0.7962, 0.7881, 0.8145),
                    auc_train = c(0.8362, 0.8976, 0.8449, 0.8214),
                    n_params = c(49, 171616, 73, 25))


## data for arrows
{curve_data <- data.frame(param[2:3,])
curve_data$x_end <- param$auc_test[3:4]
curve_data$y_end <- 1/param$n_params[3:4]}


## plot
ggplot(param, aes(x = auc_test, y = 1/n_params)) +
  theme_minimal() +
  theme(legend.position = "top",
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 12),
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 12)) +
  scale_y_continuous(expand = c(0.01, 0)) + 
  labs(x = "model performance [AUC]", 
       y = TeX("model interpretability $\\[(number\\~of\\~parameters)^{-1}\\]$")) +
  geom_segment(data = curve_data, 
               aes(x = auc_test, y = 1/n_params, xend = x_end, yend = y_end),
               arrow = arrow(length = unit(0.03, "npc"),
                             type = "closed", angle = 15)) +
  geom_point(size = 3, aes(color = model)) 
