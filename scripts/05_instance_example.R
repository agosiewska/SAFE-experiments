library(devtools)
library(tidyr)
library(rSAFE)
library(DALEX)

logreg_models %>% 
  left_join(param_count_safe, by = c("task", "split")) %>%
  filter(auc_test.x < auc_test.y) %>%
  filter(n_params.x > n_params.y) %>%
  View


# task 31	fold 4

#         logreg	      safe_logreg_gbmtuned
# params   49             25
# auc      0.7785714      0.8114286

load("./safe_extractors/safe_extractor_gbmtuned_tsk_31_fold_4.rda")
load("./safe_models/safe_logreg_gbmtuned_tsk_31_fold_4.rda")

safe_extractor

plot(safe_extractor, variable = "checking_status")
(p1 <- plot(safe_extractor, variable = "duration"))# <- ten
p2 <- plot(safe_extractor, variable = "credit_history") # <- ten
plot(safe_extractor, variable = "purpose")
plot(safe_extractor, variable = "credit_amount")
plot(safe_extractor, variable = "savings_status")
plot(safe_extractor, variable = "employment")
plot(safe_extractor, variable = "installment_commitment")
plot(safe_extractor, variable = "personal_status")
plot(safe_extractor, variable = "other_parties")
plot(safe_extractor, variable = "residence_since")
plot(safe_extractor, variable = "property_magnitude")
p3 <- plot(safe_extractor, variable = "age") # <- ten
plot(safe_extractor, variable = "other_payment_plans")
plot(safe_extractor, variable = "housing")
plot(safe_extractor, variable = "existing_credits")
plot(safe_extractor, variable = "job")

coefficients(safe_model$learner.model)

library(iBreakDown)
library(DALEXtra)
gcredit <- safe_model$learner.model$data[,-21]
safe_explainer <- explain_mlr(safe_model, data = gcredit, y = safe_model$learner.model$y, label = "safe_model")
plot(break_down(safe_explainer, gcredit[2,]))


