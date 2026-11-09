# ARCHIVED SOURCE: private paths redacted; historical logic preserved.
# Not a maintained entry point. See analysis/01_calibration_validation.R.
#Importing the data####
trials2  <- c(
  "data/raw/LEGACY_COMBINED/Z0.csv",
  "data/raw/LEGACY_COMBINED/V1.csv",
  "data/raw/LEGACY_COMBINED/Z1.csv",
  "data/raw/LEGACY_COMBINED/V2.csv",
  "data/raw/LEGACY_COMBINED/Z2.csv",
  "data/raw/LEGACY_COMBINED/V3.csv",
  "data/raw/LEGACY_COMBINED/Z3.csv"
)

trials <- c("Z0", "V1", "Z1", "V2", "Z2", "V3", "Z3")
tests <- lapply(trials, read.csv)
names(tests) <- trials
sapply(tests, nrow)


str(tests)
# STEP 2 — Enter measured water heights

left_cm <- c(14.5, 16, 14.5, 15.75, 14.5, 15.75, 14.5)

right_cm <- c(14.5, 13, 14.5, 13.25, 14.5, 13.25, 14.5)

reference_kPa <- 0.0980665 * (left_cm - right_cm)


# STEP 3 — Calculate the mean raw reading per experiment
mean_raw <- sapply(tests, function(d) {
  mean(d$raw_pressure)
})


# STEP 4 — Apply the  calibration equation

predicted_kPa <- -3.568469 +
  0.000001181831 * mean_raw


# STEP 5 — Create a summary table

results <- data.frame(
  trial = trials,
  reference_kPa = reference_kPa,
  mean_raw = mean_raw,
  predicted_kPa = predicted_kPa
)

# Calculate prediction error
results$error_kPa <-
  results$predicted_kPa - results$reference_kPa

print(results)


# STEP 6 — Calculate validation RMSE

validation <- subset(
  results,
  trial %in% c("V1", "V2", "V3")
)

# Confirm that three experiments were selected
stopifnot(nrow(validation) == 3)

# Check that the errors are valid numbers
stopifnot(all(is.finite(validation$error_kPa)))

validation_rmse <- sqrt(mean(validation$error_kPa^2))

print(validation_rmse)


# STEP 7 — Evaluate repeatability at the same pressure

repeated_pressure <- subset(
  results,
  trial %in% c("V2", "V3")
)

sd(repeated_pressure$predicted_kPa)


# STEP 8 — Evaluate zero-pressure recovery

zeros <- subset(
  results,
  trial %in% c("Z0", "Z1", "Z2", "Z3")
)

print(zeros)

# Total spread of predicted zero pressures
diff(range(zeros$predicted_kPa))


# Plot predicted pressure against the reference pressure
plot(
  results$reference_kPa,
  results$predicted_kPa,
  pch = 19,
  xlab = "U-tube reference pressure (kPa)",
  ylab = "HX710B predicted pressure (kPa)",
  main = "Independent Calibration Validation",
  xlim = c(-0.05, 0.35),
  ylim = c(-0.05, 0.35)
)

# Perfect agreement: predicted pressure = reference pressure
abline(a = 0, b = 1, col = "red", lty = 2)

# Display the prediction errors
print(results[, c(
  "trial",
  "reference_kPa",
  "predicted_kPa",
  "error_kPa"
)])

# Display the independent validation RMSE
print(validation_rmse)
