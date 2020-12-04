# A benchmark for a paper "Simpler is Better: Lifting Interpretability-Performance Trade-off via Automated Feature Engineering"

R scritps to reproduce benchmark results

- Folder `auc_scores` - auc of models for all data sets and train/test splits

- Folder `params_count` - number of parametrs for gbm, logistic regression and svm models.

- `scripts/01_train_models.R` - model training (gbm, tuned gbm, logistic regression, svm).
- `scripts/02_count_model_params.R` - counting number of models' parameters.       
- `scripts/03_safe_extractors.R` - extract safe transformations from gbm, tuned gbm, and svm.
- `scripts/04_safely_transforming_data.R` - transform data sets due to extracted transformations and train logistic regression on transformed data.
- `scripts/05_count_safe_params.R` - counting number of parameters for logistic regression on transformed data.
- `scripts/06_filter_param_counts.R`- matching computed models and save results.        
- `scripts/07_result_plots.R` - plot AUC vs interpretabbulity plot (Figure 5).             
- `scripts/08_generate_tables_for_article.R` - generate tables included in the article
- `scripts/09_triangle_plots.R` - script with triangle plot (Figure 4)