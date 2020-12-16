library(mlr)
library(gbm)
library(DALEX)
library(DALEXtra)
set.seed(1993)

train$class <- factor(train$class, levels = c("bad", "good"))
test$class <- factor(test$class, levels = c("bad", "good"))

tsk <- makeClassifTask(data = train, target = "class")
ps <- makeParamSet(
  makeIntegerParam("n.trees", lower = 50, upper = 10000),
  makeIntegerParam("interaction.depth", lower = 1, upper = 3),
  makeNumericParam('shrinkage', lower = 0.001, upper = 0.1))


ctrl <- makeTuneControlRandom(maxit = 100L)
rdesc <- makeResampleDesc("CV", iters = 3L)

res <- tuneParams(makeLearner("classif.gbm", predict.type = "prob"),
                  task = tsk,
                  resampling = rdesc,
                  par.set = ps,
                  control = ctrl,
                  measures = auc)
lrn <- setHyperPars(makeLearner("classif.gbm", predict.type = "prob"),
                    par.vals = res$x)


## model
mod_gbm <- train(lrn, tsk)
tsk_test <-  makeClassifTask(data = test, target = "class")
pred_train <- predict(mod_gbm, tsk)
pred_test <- predict(mod_gbm, tsk_test)

# How good is this model?
#0.8975544
mltools::auc_roc(pred_train$data$prob.good, train$class == "good")
# How good is this model?
#0.7961905
mltools::auc_roc(pred_test$data$prob.good, test$class == "good")
#save(mod_gbm, file = "models/mod_gbm_credit.rda")
