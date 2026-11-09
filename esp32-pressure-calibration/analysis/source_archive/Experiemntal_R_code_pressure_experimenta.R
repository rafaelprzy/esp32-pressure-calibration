# ARCHIVED SOURCE: private paths redacted; historical logic preserved.
# Not a maintained entry point. See analysis/01_calibration_validation.R.
  #Importing the data####
  files <- c(
    "data/raw/LEGACY_COMBINED/P0.csv",
    "data/raw/LEGACY_COMBINED/P1.csv",
    "data/raw/LEGACY_COMBINED/P2.csv",
    "data/raw/LEGACY_COMBINED/P3.csv",
    "data/raw/LEGACY_COMBINED/P4.csv",
    "data/raw/LEGACY_COMBINED/P5.csv",
    "data/raw/LEGACY_COMBINED/P6.csv"
  )

  # Import all seven CSV files
  
#lapply() executes "read.csv()" separately for each file in "files".
recordings <- lapply(files, read.csv)
#recordings becomes a list containing the data frames.


# Give each dataset a meaningful name
names(recordings) <- paste0("P", 0:6)

# Verify the number of samples in each recording
sapply(recordings, nrow)

#Now we can acess to the files
summary(recordings$P5$raw_pressure)


  #Combining recording into one long dataset####

# Add a point identifier and elapsed time to each recording

#seq_along(recordings) generates a sequence of positions
for (i in seq_along(recordings)) {
  
  d <- recordings[[i]]
  
  # Identify which experiment each row came from
  #Every row receives the name of the experiment it belongs to, such as "P0", "P1", or "P2"
  d$point <- names(recordings)[i]
  #Access or create the point column with name inside d
  
  # Calculate elapsed time in seconds for this recording
  d$time_s <- (d$esp32_ms - d$esp32_ms[1]) / 1000
  
  #modifying "d" does not automatically update the corresponding data frame inside our recordings list.
  #So we use:
  recordings[[i]] <- d
  #This saves the modified data frame back into its original position in the list.
}

# Stack all recordings vertically
#rbind means row bind: it stacks the data frames vertically.
all_data <- do.call(rbind, recordings)

# Verify the result
dim(all_data)
head(all_data)
table(all_data$point)

  #Create a grid with space for eight plots####
par(mfrow = c(4, 2))

# Plot every recording separately
for (name in names(recordings)) {
  
  d <- recordings[[name]]
  
  plot(
    d$time_s,
    d$raw_pressure,
    type = "l",
    main = paste("Experiment", name),
    xlab = "Time (seconds)",
    ylab = "Raw sensor counts"
  )
}

# Restore the default plotting layout
par(mfrow = c(1, 1))


  #Reference pressures from the measured U-tube heights####
## Water heights measured during the experiment (cm)
left_cm  <- c(14.5, 15.0, 15.5, 16.0, 16.5, 17.0, 14.5)
right_cm <- c(14.8, 14.3, 13.8, 13.3, 12.8, 12.5, 14.5)

# Difference between the water columns (cm)
height_difference <- left_cm - right_cm

# Convert water-column difference to reference pressure (kPa)
reference_kPa <- 0.0980665 * height_difference

print(reference_kPa)


  #Calculate one summary per experiment####
# Create one summary row per recording
calibration <- data.frame(
  point = names(recordings),
  reference_kPa = reference_kPa,
  
  # Number of sensor readings per recording
  n = sapply(recordings, nrow),
  
  # Mean raw sensor output
  mean_raw = sapply(recordings, function(d) {
    mean(d$raw_pressure)
  }),
  
  # Median raw sensor output
  median_raw = sapply(recordings, function(d) {
    median(d$raw_pressure)
  }),
  
  # Standard deviation
  sd_raw = sapply(recordings, function(d) {
    sd(d$raw_pressure)
  })
  
)

print(calibration)

  #Calibration curve

# Use the increasing-pressure points to estimate calibration
#subset()	Selects rows that satisfy a condition
#!=	Means not equal to
cal_data <- subset(calibration, point != "P6")

#P0–P5: Calibration
#P6: Zero-return chec

# Fit a linear regression
model <- lm(reference_kPa ~ mean_raw, data = cal_data)

# Plot the observed calibration points
plot(
  cal_data$mean_raw,
  cal_data$reference_kPa,
  pch = 19,
  xlab = "Mean raw HX710B counts",
  ylab = "Reference pressure (kPa)",
  main = "HX710B Pressure Calibration"
)

# Add the regression line
abline(model, col = "blue", lwd = 2)

# Display the estimated coefficients and statistics
summary(model)

##

#Error Calculation####

# STEP 1 — Fit the calibration model with P0 to P5
model <- lm(reference_kPa ~ mean_raw, data = cal_data)

# STEP 2 — Predict pressures for the calibration points
cal_data$predicted_kPa <- predict(
  model,
  newdata = cal_data
)

# STEP 3 — Calculate each prediction error
cal_data$error_kPa <-
  cal_data$predicted_kPa - cal_data$reference_kPa

# STEP 4 — Display reference, prediction, and error
print(cal_data[, c(
  "point",
  "reference_kPa",
  "predicted_kPa",
  "error_kPa"
)])

# STEP 5 — Calculate root mean squared error (RMSE)
rmse <- sqrt(mean(cal_data$error_kPa^2))
print(rmse)

# STEP 6 — Obtain R-squared
r_squared <- summary(model)$r.squared
print(r_squared)

# STEP 7 — Test P6 separately
p6 <- subset(calibration, point == "P6")

p6_prediction <- predict(model, newdata = p6)
p6_error <- p6_prediction - p6$reference_kPa

print(p6_prediction)
print(p6_error)


# Plot prediction errors against reference pressure
plot(
  cal_data$reference_kPa,
  cal_data$error_kPa,
  pch = 19,
  xlab = "Reference pressure (kPa)",
  ylab = "Prediction error (kPa)",
  main = "Calibration Errors"
)

# Horizontal reference line for zero error
abline(h = 0, lty = 2, col = "red")
