train_trans <- safely_transform_data(safe_extractor_gbm, train[,-21])
train_trans[["class"]] <- train[,21] == "bad"

test_trans <- safely_transform_data(safe_extractor_gbm, test[,-21])
test_trans[["class"]] <- test[,21] == "bad"

# ALL VARIABLES

model_glm_all <- glm(class ~ . , data = train_trans, family = "binomial")

pred_glm_all_train <- predict(model_glm_all, newdata = train_trans, type = "response")
pred_glm_all_test <- predict(model_glm_all, newdata = test_trans, type = "response")

# How good is this model?
# 0.8448912
mltools::auc_roc(pred_glm_all_train, train_trans$class)
# 0.7880952
mltools::auc_roc(pred_glm_all_test, test_trans$class)

# ONLY NEW VARIABLES
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

