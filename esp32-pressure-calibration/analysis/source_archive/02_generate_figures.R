# ARCHIVED SOURCE: private paths redacted; historical logic preserved.
# Not a maintained entry point. See analysis/01_calibration_validation.R.

# ============================================================
# HX710B PRESSURE SENSOR - SCIENTIFIC FIGURES
# File: 02_generate_figures.R
#
# Run 01_calibration_validation.R first.
# This script creates graphs from its existing R objects.
# ============================================================


# ------------------------------------------------------------
# CHECK THAT THE REQUIRED ANALYSIS EXISTS
# ------------------------------------------------------------

required_objects <- c(
  "cal_data", "model", "validation", "cal_files",
  "zero_tests", "repeat_tests",
  "r_squared", "calibration_rmse", "validation_rmse"
)

missing_objects <- required_objects[
  !vapply(required_objects, exists, logical(1))
]

if (length(missing_objects) > 0) {
  stop(
    "Run the calibration/validation script first. Missing: ",
    paste(missing_objects, collapse = ", ")
  )
}


# ============================================================
# FIGURE 1 - CALIBRATION CURVE
# ============================================================

plot_calibration <- function() {
  
  plot(
    cal_data$mean_raw,
    cal_data$reference_kPa,
    pch = 19,
    col = "#2563EB",
    cex = 1.3,
    xlab = "Mean raw HX710B counts",
    ylab = "U-tube reference pressure (kPa)",
    main = "F01 - Experimental Calibration"
  )
  
  # Draw the fitted linear regression
  abline(model, col = "#0F766E", lwd = 2)
  
  # Identify the six calibration experiments
  text(
    cal_data$mean_raw,
    cal_data$reference_kPa,
    labels = cal_data$trial,
    pos = 3,
    cex = 0.8
  )
  
  # Show model performance on the graph
  legend(
    "topleft",
    legend = c(
      paste0("R-squared = ", round(r_squared, 4)),
      paste0(
        "RMSE = ",
        round(calibration_rmse, 4),
        " kPa"
      )
    ),
    bty = "n",
    cex = 0.85
  )
}


# ============================================================
# FIGURE 2 - CALIBRATION PREDICTION ERRORS
# ============================================================

plot_errors <- function() {
  
  plot(
    cal_data$reference_kPa,
    cal_data$error_kPa,
    pch = 19,
    col = "#2563EB",
    cex = 1.3,
    xlab = "Reference pressure (kPa)",
    ylab = "Predicted - reference pressure (kPa)",
    main = "F02 - Calibration Prediction Errors"
  )
  
  # Zero error means perfect agreement
  abline(h = 0, col = "#DC2626", lty = 2)
  
  # Identify each experimental point
  text(
    cal_data$reference_kPa,
    cal_data$error_kPa,
    labels = cal_data$trial,
    pos = 3,
    cex = 0.8
  )
}


# ============================================================
# FIGURE 3 - INDEPENDENT VALIDATION
# ============================================================

plot_validation <- function() {
  
  plot(
    validation$reference_kPa,
    validation$predicted_kPa,
    pch = 19,
    col = "#2563EB",
    cex = 1.2,
    
    xlim = c(-0.07, 0.48),
    ylim = c(-0.07, 0.48),
    asp = 1,
    
    xlab = "Reference pressure (kPa)",
    ylab = "Predicted pressure (kPa)",
    main = "F03 - Independent Validation"
  )
  
  # The diagonal represents perfect agreement
  abline(
    a = 0,
    b = 1,
    col = "#DC2626",
    lty = 2,
    lwd = 2
  )
  
  # Add experiment labels
  text(
    validation$reference_kPa,
    validation$predicted_kPa,
    labels = validation$trial,
    pos = 4,
    offset = 0.4,
    cex = 0.75
  )
  
  legend(
    "topleft",
    legend = paste0(
      "Positive-pressure RMSE = ",
      round(validation_rmse, 4),
      " kPa"
    ),
    bty = "n",
    cex = 0.8
  )
}


# ============================================================
# FIGURE 4 - RAW SIGNAL STABILITY
# ============================================================

plot_raw_times <- function() {
  
  # Save current graph layout settings
  old_par <- par(no.readonly = TRUE)
  
  # Restore layout when function finishes
  on.exit(par(old_par))
  
  # 4 rows x 2 columns = 8 available panels
  par(
    mfrow = c(4, 2),
    mar = c(3.5, 4.5, 2.5, 1)
  )
  
  for (name in names(cal_files)) {
    
    d <- cal_files[[name]]
    
    # Convert ESP32 milliseconds to elapsed seconds
    time_s <- (
      d$esp32_ms - d$esp32_ms[1]
    ) / 1000
    
    plot(
      time_s,
      d$raw_pressure,
      type = "l",
      col = "#2563EB",
      lwd = 1.5,
      xlab = "Elapsed time (s)",
      ylab = "Raw counts",
      main = paste("Experiment", name)
    )
  }
  
  # Unused eighth panel
  plot.new()
  
  text(
    0.5, 0.5,
    "P0-P6\nCalibration recordings",
    cex = 1.2
  )
}


# ============================================================
# FIGURE 5 - ZERO-PRESSURE RECOVERY
# ============================================================

plot_zero <- function() {
  
  x <- seq_along(zero_tests$trial)
  
  y <- zero_tests$predicted_kPa
  
  plot(
    x,
    y,
    type = "b",
    pch = 19,
    col = "#2563EB",
    lwd = 2,
    xaxt = "n",
    xlab = "Chronological zero-pressure experiment",
    ylab = "Predicted gauge pressure (kPa)",
    main = "F05 - Zero-Pressure Recovery",
    ylim = c(min(y, 0) - 0.01, max(y, 0) + 0.01)
  )
  
  axis(
    1,
    at = x,
    labels = zero_tests$trial
  )
  
  # Reference is exactly 0 kPa gauge
  abline(h = 0, col = "#DC2626", lty = 2)
  
  # Show zero-pressure spread
  spread <- diff(range(y))
  
  legend(
    "topright",
    legend = paste0(
      "Zero spread = ",
      round(spread, 4),
      " kPa"
    ),
    bty = "n",
    cex = 0.8
  )
}


# ============================================================
# FIGURE 6 - REPEATABILITY (V2 AND V3)
# ============================================================

plot_repeatability <- function() {
  
  x <- seq_len(nrow(repeat_tests))
  
  y <- repeat_tests$predicted_kPa
  
  reference <- mean(repeat_tests$reference_kPa)
  
  plot(
    x,
    y,
    pch = 19,
    col = "#2563EB",
    cex = 1.6,
    xaxt = "n",
    xlim = c(0.5, 2.5),
    ylim = range(c(y, reference)) + c(-0.015, 0.015),
    xlab = "Independent repeated experiment",
    ylab = "Predicted gauge pressure (kPa)",
    main = "F06 - Repeatability at 0.245 kPa"
  )
  
  axis(
    1,
    at = x,
    labels = repeat_tests$trial
  )
  
  # Reference pressure for both experiments
  abline(
    h = reference,
    col = "#DC2626",
    lty = 2
  )
  
  # Display the numerical prediction
  text(
    x,
    y,
    labels = sprintf("%.4f kPa", y),
    pos = 3,
    cex = 0.9
  )
  
  difference <- abs(diff(y))
  
  legend(
    "bottomleft",
    legend = paste0(
      "Difference = ",
      round(difference, 4),
      " kPa"
    ),
    bty = "n",
    cex = 0.85
  )
}



# Preview Figure 1
plot_calibration()

# Preview Figure 2
plot_errors()

# Preview Figure 3
plot_validation()

# Preview Figure 4
plot_raw_times()

# Preview Figure 5
plot_zero()

# Preview Figure 6
plot_repeatability()


# ============================================================
# EXPORT ALL FIGURES AS PNG FILES
# ============================================================

# Create output directory if it does not exist
dir.create("figures", showWarnings = FALSE)

# Reusable figure-export function
export_figure <- function(filename, plot_function,
                          width = 1800, height = 1200) {
  
  # Open a PNG graphics device
  png(
    filename = file.path("figures", filename),
    width = width,
    height = height,
    res = 200,
    bg = "white"
  )
  
  # Ensure the graphics device is closed
  on.exit(dev.off())
  
  # Execute the plotting function
  plot_function()
}

# Export the six figures
export_figure(
  "F01_calibration.png",
  plot_calibration
)

export_figure(
  "F02_calibration_errors.png",
  plot_errors
)

export_figure(
  "F03_validation.png",
  plot_validation
)

# Larger canvas for seven time-series panels
export_figure(
  "F04_raw_signal_stability.png",
  plot_raw_times,
  width = 2400,
  height = 2000
)

export_figure(
  "F05_zero_recovery.png",
  plot_zero
)

export_figure(
  "F06_repeatability.png",
  plot_repeatability
)

cat("\nSix scientific figures exported.\n")
