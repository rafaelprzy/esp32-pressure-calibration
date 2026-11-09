# ARCHIVED SOURCE: private paths redacted; historical logic preserved.
# Not a maintained entry point. See analysis/01_calibration_validation.R.

# ==========================================================
# HX710B PRESSURE SENSOR - FINAL CALIBRATION VERIFICATION
# ==========================================================

# STEP 1: Locate our experimental files

folder <- "data/raw/LEGACY_COMBINED"

cal_names <- paste0("P", 0:6)

val_names <- c(
  "Z0", "V1", "Z1", "V2", "Z2", "V3", "Z3"
)

# Construct their expected locations
val_paths <- file.path(
  folder,
  paste0(val_names, ".csv")
)

# Check each file individually
file_check <- data.frame(
  Experiment = val_names,
  File_exists = file.exists(val_paths),
  Expected_path = val_paths
)

print(file_check, row.names = FALSE)

# Show the filenames actually present in the folder
list.files(folder, pattern = "\\.csv$", ignore.case = TRUE)

# Function to import and label the recordings
read_experiments <- function(names_vector) {
  
  files <- file.path(folder, paste0(names_vector, ".csv"))
  
  # Stop if any file is missing
  stopifnot(all(file.exists(files)))
  
  datasets <- lapply(files, read.csv)
  
  # Replace file paths with experiment names
  names(datasets) <- names_vector
  
  return(datasets)
}

cal_files <- read_experiments(cal_names)
val_files <- read_experiments(val_names)


# STEP 2: Create a reusable summary function

summarize_experiments <- function(datasets, left, right) {
  
  # Check that all imported files have the required column
  stopifnot(all(sapply(datasets, function(d) {
    "raw_pressure" %in% names(d)
  })))
  
  # Check that raw readings are numeric and not missing
  stopifnot(all(sapply(datasets, function(d) {
    is.numeric(d$raw_pressure) &&
      all(is.finite(d$raw_pressure))
  })))
  
  data.frame(
    trial = names(datasets),
    
    n = sapply(datasets, nrow),
    
    # Reference pressure calculated using the U-tube
    reference_kPa = 0.0980665 * (left - right),
    
    # Representative raw sensor measurement
    mean_raw = as.numeric(sapply(datasets, function(d) {
      mean(d$raw_pressure)
    })),
    
    # Variability within each recording
    sd_raw = as.numeric(sapply(datasets, function(d) {
      sd(d$raw_pressure)
    }))
  )
}


# STEP 3: Rebuild the original calibration dataset

cal_left <- c(14.5, 15, 15.5, 16, 16.5, 17, 14.5)
cal_right <- c(14.8, 14.3, 13.8, 13.3, 12.8, 12.5, 14.5)

calibration <- summarize_experiments(
  cal_files, cal_left, cal_right
)

cat("\n===== ORIGINAL CALIBRATION DATA =====\n")
print(calibration)


# ==========================================================
# VERIFICATION 1: CALIBRATION REGRESSION
# ==========================================================

# P0 to P5 build the calibration equation
# P6 remains separate for zero-return assessment

cal_data <- subset(calibration, trial != "P6")

model <- lm(reference_kPa ~ mean_raw, data = cal_data)

# Calculate fitted pressures and their errors
cal_data$predicted_kPa <- predict(model)

cal_data$error_kPa <- cal_data$predicted_kPa -
  cal_data$reference_kPa

# Calibration fit statistics
r_squared <- summary(model)$r.squared

calibration_rmse <- sqrt(
  mean(cal_data$error_kPa^2)
)

cat("\n===== VERIFICATION 1: CALIBRATION =====\n")

print(coef(model))

cat("R-squared:", r_squared, "\n")
cat("Calibration RMSE (kPa):", calibration_rmse, "\n")

print(cal_data[, c(
  "trial", "reference_kPa",
  "predicted_kPa", "error_kPa"
)])


# ==========================================================
# VERIFICATION 2: INDEPENDENT VALIDATION
# ==========================================================

# Reference heights measured during validation
val_left <- c(14.5, 16, 14.5, 15.75, 14.5, 15.75, 14.5)
val_right <- c(14.5, 13, 14.5, 13.25, 14.5, 13.25, 14.5)

validation <- summarize_experiments(
  val_files, val_left, val_right
)

# Predict new pressures using the ORIGINAL model
# Do not fit a new regression to the validation data

validation$predicted_kPa <- predict(
  model,
  newdata = validation
)

validation$error_kPa <- validation$predicted_kPa -
  validation$reference_kPa

cat("\n===== VERIFICATION 2: VALIDATION =====\n")

print(validation[, c(
  "trial", "n", "reference_kPa",
  "predicted_kPa", "error_kPa"
)])


# Evaluate only the independent positive-pressure trials
positive_tests <- subset(
  validation,
  trial %in% c("V1", "V2", "V3")
)

validation_rmse <- sqrt(
  mean(positive_tests$error_kPa^2)
)

cat("Positive-pressure validation RMSE (kPa):",
    validation_rmse, "\n")


# STEP 4: Evaluate repeated pressure measurements

# V2 and V3 were both measured near 0.2452 kPa
repeat_tests <- subset(
  validation,
  trial %in% c("V2", "V3")
)

cat("\n===== REPEATABILITY =====\n")

print(repeat_tests[, c("trial", "predicted_kPa")])

cat("Repeatability SD (kPa):",
    sd(repeat_tests$predicted_kPa), "\n")


# STEP 5: Evaluate zero-pressure recovery

zero_tests <- subset(
  validation,
  trial %in% c("Z0", "Z1", "Z2", "Z3")
)

cat("\n===== ZERO-PRESSURE RECOVERY =====\n")

print(zero_tests[, c(
  "trial", "predicted_kPa", "error_kPa"
)])

cat("Zero prediction spread (kPa):",
    diff(range(zero_tests$predicted_kPa)), "\n")


# STEP 6: Verify sample counts and acquisition timing

all_files <- c(cal_files, val_files)

quality <- data.frame(
  trial = names(all_files),
  
  samples = sapply(all_files, nrow),
  
  median_interval_ms = sapply(all_files, function(d) {
    median(diff(d$esp32_ms))
  }),
  
  missing_sample_ids = sapply(all_files, function(d) {
    sum(diff(d$sample_id) != 1)
  })
)

cat("\n===== DATA ACQUISITION QUALITY =====\n")
print(quality, row.names = FALSE)


# ==========================================================
# STEP 7: CREATE TWO VERIFICATION GRAPHS
# ==========================================================

old_par <- par(mfrow = c(1, 2))

# GRAPH 1: Original calibration and fitted line

plot(
  cal_data$mean_raw,
  cal_data$reference_kPa,
  pch = 19,
  xlab = "Mean raw HX710B counts",
  ylab = "Reference pressure (kPa)",
  main = "1. Calibration"
)

abline(model, col = "blue", lwd = 2)

text(
  cal_data$mean_raw,
  cal_data$reference_kPa,
  labels = cal_data$trial,
  pos = 3,
  cex = 0.8
)


# GRAPH 2: Independent validation

plot(
  validation$reference_kPa,
  validation$predicted_kPa,
  pch = 19,
  xlim = c(-0.06, 0.5),
  ylim = c(-0.06, 0.5),
  xlab = "U-tube reference pressure (kPa)",
  ylab = "HX710B predicted pressure (kPa)",
  main = "2. Independent Validation"
)

# Dashed line means perfect agreement
abline(a = 0, b = 1, col = "red", lty = 2)

text(
  validation$reference_kPa,
  validation$predicted_kPa,
  labels = validation$trial,
  pos = 3,
  cex = 0.7
)

par(old_par)

cat("\n===== FINAL CHECK COMPLETE =====\n")


# =====================================================
# FINAL CALIBRATION RESULTS - SUMMARY TABLE
# =====================================================

# 1. Collect the calculated statistics
calculated <- c(
  unname(coef(model)[1]),         # Calibration intercept
  unname(coef(model)[2]),         # Calibration slope
  r_squared,                      # R-squared
  calibration_rmse,               # Calibration RMSE
  validation_rmse,                # Validation RMSE
  diff(range(zero_tests$predicted_kPa)) # Zero-pressure spread
)

# 2. Enter the results from our previous analysis
expected <- c(
  -3.56847,
  0.00000118183,
  0.9951,
  0.0114,
  0.0090,
  0.0706
)

# 3. Create the comparison table
final_results <- data.frame(
  Statistic = c(
    "Calibration intercept",
    "Calibration slope",
    "Calibration R-squared",
    "Calibration RMSE (kPa)",
    "Validation RMSE (kPa)",
    "Zero-pressure spread (kPa)"
  ),
  Calculated = calculated,
  Expected = expected
)

# 4. Display values without scientific notation
print(
  final_results,
  digits = 9,
  row.names = FALSE
)

# 5. Show whether all six results are valid numbers
cat("\nAll results finite:",
    all(is.finite(calculated)), "\n")

