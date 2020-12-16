#### GLM ####

model_glm <- glm(class == "bad" ~ ., data = train, family = "binomial")
summary(model_glm)

pred_train <- predict(model_glm, newdata = train, type = "response")
pred_test <- predict(model_glm, newdata = test, type = "response")

#0.8362551
mltools::auc_roc(pred_train, train$class == "bad")
#0.7785714
mltools::auc_roc(pred_test, test$class == "bad")

#save(model_glm, file = "models/glm.rda")
