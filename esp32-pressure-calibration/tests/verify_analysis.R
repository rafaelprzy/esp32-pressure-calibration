# Meaningful data and regression checks for this frozen experimental package.
# Run from repository root after either analysis entry point.
source("analysis/01_calibration_validation.R")
assert <- function(ok, description) {
  if (!isTRUE(ok)) stop(description)
  cat("PASS:",description,"\n")
}
assert(nrow(metadata)==14 && sum(summaries$n)==2937,"all 14 trials and 2937 raw samples are retained")
assert(all(quality$nonunit_id_steps==0) && all(quality$timestamp_nonincreasing_steps==0),"sample IDs and timestamps remain continuous within each recording")
assert(identical(cal_data$trial,paste0("P",0:5)) && identical(model$model$mean_raw,cal_data$mean_raw) && identical(model$model$reference_kPa,cal_data$reference_kPa),"the fitted observations are exactly the P0-P5 trial means")
assert(nrow(model$model)==6 && df.residual(model)==4,"trial-level model has six observations and four residual degrees of freedom")
assert(all(expected$agrees_at_reported_precision),"six historical metrics reproduce at reported precision")
assert(abs(validation$reference_kPa[validation$trial=="V1"]-0.2941995)<1e-12,"V1 uses its measured 3.0 cm difference")
assert(grepl("not recorded",metadata$final_height_status[metadata$trial=="V3"]) && is.na(metadata$final_left_cm[metadata$trial=="V3"]),"V3 missing final height is explicit and not imputed")
assert(identical(validation$trial,c("Z0","V1","Z1","V2","Z2","V3","Z3")),"validation chronology is preserved")
assert(all(diff(quality$first_esp32_ms[quality$trial %in% validation$trial])>0),"validation timestamps support the documented within-session order")
assert(abs(calibration_rmse-0.0113934462408)<1e-12 && abs(validation_rmse-0.00897939208268)<1e-12,"calibration and positive validation error definitions have not changed")
assert(abs(metrics$value[metrics$metric=="V1_V2_only_RMSE_kPa"]-0.0109882219336)<1e-12,"V3-exclusion sensitivity analysis is reproducible")
assert(all(quality$median_interval_ms==250),"raw timestamps have the reported 250 ms median interval")
figs <- file.path("figures/generated",c("F01_calibration.png","F02_calibration_errors.png","F03_validation.png","F04_raw_signal_stability.png","F05_zero_recovery.png","F06_repeatability.png"))
assert(all(file.exists(figs)) && all(file.info(figs)$size>10000),"all six regenerated figures exist")
cat("All verification checks passed. These checks do not verify live hardware or clinical suitability.\n")
