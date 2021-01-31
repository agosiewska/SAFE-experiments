# A use case for a paper "Simpler is Better: Lifting Interpretability-Performance Trade-off via Automated Feature Engineering"

### Folder `data`:
- `train_test_set.R` - data preparation script
- `train.rda` - train dataset
- `test.rda` - test dataset

### Folder `model`:

Folder `models`
- `vanilla_logistic_regression.R` - vanilla logistic regression model preparation script
- `gbm_model.R` - gbm model preparation script
- `glm_on_all_variables.R` - glm on all varibale model preparation script
- `SAFE_logistic_regression.R` - SAFE logistic regression model script
		
Folder `outputs`
	
- `vanilla_logistic_regression.rda` - vanilla logistic regression model
- `gbm_model.rda` - gbm model
- `glm_on_all_variables.rda` - glm on all varibale model 
- `SAFE_logistic_regression.rda`- SAFE logistic regression
		
Folder `safe_transformation`
	
- `safe_transformation.R` - SAFE transformation script
- `safe_extractor_gbm_german_credit_split4.rda` - SAFE transformation output

- `figures.R` - script to reproduce Figure 4, value of auc_train and auc_test are come from `model/models` scripts

