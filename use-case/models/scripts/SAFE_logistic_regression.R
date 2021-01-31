#### glm only new variables ####

library(rSAFE)
library(mlr)
library(gbm)
library(DALEX)
library(DALEXtra)

load("./use-case/data/train.rda")
load("./use-case/data/test.rda")
load("./use-case/models/safe_transformation/safe_extractor_gbm_german_credit_split4.rda")

train_trans <- safely_transform_data(safe_extractor_gbm, train[,-21])
train_trans[["class"]] <- train[,21] == "bad"

test_trans <- safely_transform_data(safe_extractor_gbm, test[,-21])
test_trans[["class"]] <- test[,21] == "bad"

train_trans_new <- train_trans[,grepl(".*new",colnames(train_trans))]
train_trans_new[["class"]] <- train[,21] == "bad"

test_trans_new <- test_trans[,grepl(".*new",colnames(test_trans))]
test_trans_new[["class"]] <- test[,21] == "bad"

model_lm_new <- lm(class ~ . , data = train_trans_new)

pred_lm_new2 <- predict(model_lm_new, newdata = train_trans_new, type = "resp")
pred_lm_new <- predict(model_lm_new, newdata = test_trans_new, type = "resp")

# How good is this model?
# 0.8145297
mltools::auc_roc(pred_lm_new2, train$class == "bad")
# 0.8214286
mltools::auc_roc(pred_lm_new, test$class == "bad")


#save(model_lm_new, file = "./use-case/models/outputs/SAFE_logistic_regression.rda")
