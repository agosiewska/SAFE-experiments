#### glm on all variables ####

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


model_glm_all <- glm(class ~ . , data = train_trans, family = "binomial")

pred_glm_all_train <- predict(model_glm_all, newdata = train_trans, type = "response")
pred_glm_all_test <- predict(model_glm_all, newdata = test_trans, type = "response")

# How good is this model?
# 0.8448912
mltools::auc_roc(pred_glm_all_train, train_trans$class)
# 0.7880952
mltools::auc_roc(pred_glm_all_test, test_trans$class)

#save(model_glm_all, file = "./use-case/models/outputs/glm_on_all_variables.rda")
