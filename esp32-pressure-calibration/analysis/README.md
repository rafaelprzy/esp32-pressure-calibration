# Analysis entry points

Run `01_calibration_validation.R` to rebuild the original trial-mean OLS model, frozen-model validation, quality checks and result tables. Run `02_generate_figures.R` to execute that analysis in a fresh session and generate F01-F06. No contributed packages are needed.

The original main file was named `01_calibration_validation.R.R`. Historical scripts are in `source_archive`, with private absolute paths removed. Their methods are retained as provenance, but their legacy directory assumptions and dependence on interactive objects mean they are not the reproduction route. The older `additional_verifications.R` also attempted to read bare trial IDs instead of its declared path vector; it was superseded by the supplied working final main script. No correction of that archived draft is needed to reproduce the final results.

Maintained changes: explicit metadata table; repository-relative paths; fresh-session figure generation; derived CSV exports; P6 prediction; full-validation and zero-only RMSE; V3-exclusion sensitivity; descriptive timing and raw-trend checks. Original fit and primary statistics are numerically unchanged. F04 subtracts trial means for display legibility only; all original data remain in the fit and raw archive.
