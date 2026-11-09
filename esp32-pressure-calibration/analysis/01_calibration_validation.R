# Rebuild the supplied trial-mean calibration and frozen-model validation.
# Base R only. Run from the repository root:
#   Rscript --vanilla analysis/01_calibration_validation.R
# An optional first argument supplies the repository root from another folder.

find_project_root <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))
  source_files <- as.character(unlist(lapply(sys.frames(), function(f) f$ofile)))
  seeds <- c(if (length(args)) args[1], getwd(), dirname(script), dirname(source_files))
  for (seed in seeds[nzchar(seeds)]) {
    p <- normalizePath(seed, winslash = "/", mustWork = FALSE)
    for (i in seq_len(10)) {
      if (file.exists(file.path(p, "data", "metadata", "trials.csv"))) return(p)
      parent <- dirname(p)
      if (parent == p) break
      p <- parent
    }
  }
  stop("Cannot locate project root. Supply it as the first command-line argument.")
}

project_root <- find_project_root()
out <- file.path(project_root, "results")
dir.create(out, showWarnings = FALSE, recursive = TRUE)
metadata <- read.csv(file.path(project_root, "data/metadata/trials.csv"),
                     stringsAsFactors = FALSE, na.strings = "NA")
stopifnot(identical(metadata$trial, c(paste0("P", 0:6), "Z0", "V1", "Z1", "V2", "Z2", "V3", "Z3")))
stopifnot(!anyDuplicated(metadata$trial), all(is.finite(metadata$left_cm)),
          all(is.finite(metadata$right_cm)))

read_recording <- function(trial, phase) {
  p <- file.path(project_root, "data/raw", phase, paste0(trial, ".csv"))
  if (!file.exists(p)) stop("Missing raw recording: ", trial)
  d <- read.csv(p)
  required <- c("sample_id", "experiment_ms", "esp32_ms", "raw_pressure")
  stopifnot(identical(names(d), required), nrow(d) >= 2,
            all(vapply(d, is.numeric, logical(1))),
            all(vapply(d, function(x) all(is.finite(x)), logical(1))),
            all(d$raw_pressure == round(d$raw_pressure)),
            all(diff(d$sample_id) == 1), all(diff(d$esp32_ms) > 0),
            all(diff(d$experiment_ms) > 0),
            length(unique(d$esp32_ms - d$experiment_ms)) == 1)
  d
}
all_files <- Map(read_recording, metadata$trial, metadata$phase)
names(all_files) <- metadata$trial
cal_files <- all_files[paste0("P", 0:6)]
val_files <- all_files[c("Z0", "V1", "Z1", "V2", "Z2", "V3", "Z3")]

# Preserve all samples: no trimming, smoothing, detrending, or outlier deletion.
summaries <- data.frame(
  trial = metadata$trial, phase = metadata$phase, role = metadata$role,
  chronological_order = metadata$chronological_order,
  n = vapply(all_files, nrow, integer(1)),
  left_cm = metadata$left_cm, right_cm = metadata$right_cm,
  reference_kPa = 0.0980665 * (metadata$left_cm - metadata$right_cm),
  mean_raw = vapply(all_files, function(d) mean(d$raw_pressure), numeric(1)),
  sd_raw = vapply(all_files, function(d) sd(d$raw_pressure), numeric(1)),
  final_height_status = metadata$final_height_status,
  row.names = NULL
)
calibration <- subset(summaries, phase == "calibration")
cal_data <- subset(calibration, role == "fit")
stopifnot(identical(cal_data$trial, paste0("P", 0:5)))

# Equal weight per physical trial, as in the supplied analysis.
# P6 and every validation recording remain outside the model fit.
model <- lm(reference_kPa ~ mean_raw, data = cal_data)
summaries$predicted_kPa <- as.numeric(predict(model, newdata = summaries))
summaries$error_kPa <- summaries$predicted_kPa - summaries$reference_kPa
summaries$within_recording_sd_kPa <- abs(unname(coef(model)[2])) * summaries$sd_raw
calibration <- subset(summaries, phase == "calibration")
cal_data <- subset(summaries, role == "fit")
p6 <- subset(summaries, trial == "P6")
validation <- subset(summaries, phase == "validation")
positive_tests <- subset(validation, role == "positive_validation")
confirmed_positive <- subset(positive_tests, trial %in% c("V1", "V2"))
zero_tests <- subset(validation, role == "zero_validation")
repeat_tests <- subset(validation, trial %in% c("V2", "V3"))

rmse <- function(x) sqrt(mean(x^2))
r_squared <- summary(model)$r.squared
calibration_rmse <- rmse(cal_data$error_kPa)
validation_rmse <- rmse(positive_tests$error_kPa)
raw_vector <- unlist(lapply(all_files, `[[`, "raw_pressure"))
rounded_prediction <- -3.568469 + 0.000001181831 * raw_vector
full_prediction <- unname(coef(model)[1]) + unname(coef(model)[2]) * raw_vector
rounded_conversion_difference <- max(abs(rounded_prediction - full_prediction))
metrics <- data.frame(
  metric = c("intercept_kPa", "slope_kPa_per_count", "calibration_R_squared",
             "calibration_RMSE_kPa", "residual_standard_error_kPa",
             "positive_validation_RMSE_kPa", "V1_V2_only_RMSE_kPa",
             "positive_validation_bias_kPa", "all_validation_RMSE_kPa",
             "zero_validation_RMSE_kPa", "zero_validation_bias_kPa",
             "zero_prediction_spread_kPa", "repeatability_SD_two_means_kPa",
             "V2_V3_absolute_difference_kPa", "P6_prediction_kPa",
             "calibration_min_kPa", "calibration_max_kPa", "fit_trials",
             "positive_validation_trials", "zero_validation_trials", "raw_samples",
             "max_rounded_firmware_conversion_difference_kPa"),
  value = c(unname(coef(model)), r_squared, calibration_rmse, summary(model)$sigma,
            validation_rmse, rmse(confirmed_positive$error_kPa),
            mean(positive_tests$error_kPa), rmse(validation$error_kPa),
            rmse(zero_tests$error_kPa), mean(zero_tests$error_kPa),
            diff(range(zero_tests$predicted_kPa)), sd(repeat_tests$predicted_kPa),
            abs(diff(repeat_tests$predicted_kPa)), p6$predicted_kPa,
            range(cal_data$reference_kPa), nrow(cal_data), nrow(positive_tests),
            nrow(zero_tests), sum(summaries$n),
            rounded_conversion_difference),
  basis = c(rep("P0-P5 unweighted trial-mean OLS", 5),
            "V1-V3; V3 lacks final height; legacy analysis retained",
            "V1-V2 sensitivity excluding V3", "V1-V3 mean signed prediction error",
            "Z0,V1,Z1,V2,Z2,V3,Z3; frozen model", "Z0-Z3; frozen model",
            "Z0-Z3 mean signed prediction error", "range of four zero trial means",
            "sample SD of V2 and V3 means; n=2; V3 final height missing",
            "absolute difference of V2 and V3 means", "held out of fit; reference 0",
            rep("reference heights in supplied R analysis", 2), "P0-P5", "V1-V3", "Z0-Z3",
            "all 14 original CSVs", "double arithmetic with supplied rounded firmware constants; not hardware float validation"),
  stringsAsFactors = FALSE
)

quality_rows <- lapply(names(all_files), function(id) {
  d <- all_files[[id]]
  delta <- diff(d$esp32_ms)
  elapsed <- (d$esp32_ms - d$esp32_ms[1]) / 1000
  trend <- unname(coef(lm(d$raw_pressure ~ elapsed))[2])
  k <- min(10, nrow(d))
  data.frame(trial = id, samples = nrow(d),
             first_esp32_ms = d$esp32_ms[1], last_esp32_ms = tail(d$esp32_ms, 1),
             span_s = max(elapsed), first_experiment_ms = d$experiment_ms[1],
             last_experiment_ms = tail(d$experiment_ms, 1),
             min_interval_ms = min(delta), median_interval_ms = median(delta),
             max_interval_ms = max(delta), effective_rate_Hz = 1000 / mean(delta),
             nonunit_id_steps = sum(diff(d$sample_id) != 1),
             timestamp_nonincreasing_steps = sum(delta <= 0),
             timestamp_offset_unique_values = length(unique(d$esp32_ms - d$experiment_ms)),
             sd_raw = sd(d$raw_pressure), raw_range_counts = diff(range(d$raw_pressure)),
             trend_counts_per_s = trend, trend_kPa_per_s = trend * unname(coef(model)[2]),
             first10_to_last10_kPa = (mean(tail(d$raw_pressure, k)) - mean(head(d$raw_pressure, k))) * unname(coef(model)[2]),
             lag1_raw_correlation = cor(head(d$raw_pressure, -1), tail(d$raw_pressure, -1)))
})
quality <- do.call(rbind, quality_rows)

expected <- data.frame(
  metric = c("intercept_kPa", "slope_kPa_per_count", "calibration_R_squared", "calibration_RMSE_kPa", "positive_validation_RMSE_kPa", "zero_prediction_spread_kPa"),
  previously_reported = c(-3.568469, 0.000001181831, 0.9951, 0.0114, 0.0090, 0.0706),
  rounding_tolerance = c(0.0000005, 0.0000000000005, rep(0.00005, 4)))
expected$recalculated <- metrics$value[match(expected$metric, metrics$metric)]
expected$difference <- expected$recalculated - expected$previously_reported
expected$agrees_at_reported_precision <- abs(expected$difference) <= expected$rounding_tolerance

write_result <- function(d, name) write.csv(d, file.path(out, name), row.names = FALSE, na = "NA")
write_result(summaries, "trial_summary.csv")
write_result(cal_data, "calibration_results.csv")
write_result(validation, "validation_results.csv")
write_result(quality, "acquisition_quality.csv")
write_result(metrics, "metrics.csv")
write_result(expected, "comparison_to_reported.csv")
saveRDS(model, file.path(out, "calibration_model.rds"))
capture.output(sessionInfo(), file = file.path(out, "R_session_info.txt"))
capture.output(summary(model), file = file.path(out, "model_summary.txt"))
cat("Calibration uses P0-P5 trial means; P6 is held out.\n")
print(metrics, row.names = FALSE, digits = 12)
cat("\nAll previously reported values agree at their stated rounding:",
    all(expected$agrees_at_reported_precision), "\n")
cat("V3 final height is missing. Its assigned reference is retained with that qualification.\n")
