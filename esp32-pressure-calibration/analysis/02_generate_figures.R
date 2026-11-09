# Publication figures from the same calculations as the supplied R scripts.
# Original PNGs remain unchanged in figures/original.
# Run from root: Rscript --vanilla analysis/02_generate_figures.R
# This script sources 01, so it also works in a clean R session on its own.
locate_root <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  f <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))
  of <- as.character(unlist(lapply(sys.frames(), function(x) x$ofile)))
  for (seed in c(if (length(args)) args[1], getwd(), dirname(f), dirname(of))) {
    p <- normalizePath(seed, winslash = "/", mustWork = FALSE)
    for (i in 1:10) {
      if (file.exists(file.path(p, "analysis/01_calibration_validation.R"))) return(p)
      if (dirname(p) == p) break
      p <- dirname(p)
    }
  }
  stop("Supply the repository root as the first argument.")
}
project_root <- locate_root()
source(file.path(project_root, "analysis/01_calibration_validation.R"))
fig_dir <- file.path(project_root, "figures/generated")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
blue <- "#235EA8"; red <- "#B03B35"; teal <- "#177A6A"
export <- function(name, draw, width = 2400, height = 1650, res = 300, pointsize = 12) {
  png(file.path(fig_dir, name), width = width, height = height, res = res, bg = "white", pointsize = pointsize)
  on.exit(dev.off())
  par(mar = c(5, 5.2, 3.6, 1.4), las = 1, mgp = c(3.1, 0.8, 0), bty = "l")
  draw()
}

export("F01_calibration.png", function() {
  plot(cal_data$mean_raw/1e6, cal_data$reference_kPa, pch=19, col=blue,
       xlim=range(cal_data$mean_raw/1e6)+c(-0.025,0.025), ylim=c(-0.06,0.49),
       xlab="Mean raw HX710B counts (millions)", ylab="U-tube reference pressure (kPa)",
       main="F01  Experimental calibration")
  abline(a=coef(model)[1], b=coef(model)[2]*1e6, col=teal, lwd=2)
  text(cal_data$mean_raw/1e6, cal_data$reference_kPa, cal_data$trial, pos=3, cex=0.85)
  legend("topleft", c(sprintf("R squared = %.4f", r_squared), sprintf("RMSE = %.4f kPa", calibration_rmse), "Six trial means; P6 excluded"), bty="n", cex=0.85)
})

export("F02_calibration_errors.png", function() {
  plot(cal_data$reference_kPa, cal_data$error_kPa, pch=19, col=blue,
       xlim=c(-0.06,0.48), ylim=c(-0.021,0.022),
       xlab="Reference pressure (kPa)", ylab="Predicted minus reference pressure (kPa)",
       main="F02  Calibration prediction errors")
  abline(h=0, col=red, lty=2)
  text(cal_data$reference_kPa, cal_data$error_kPa, cal_data$trial, pos=3, cex=0.85)
})

export("F03_validation.png", function() {
  plot(validation$reference_kPa, validation$predicted_kPa, pch=19, col=blue,
       xlim=c(-0.08,0.39), ylim=c(-0.08,0.39), asp=1,
       xlab="Reference pressure (kPa)", ylab="Predicted pressure (kPa)",
       main="F03  Independent validation")
  abline(0,1,col=red,lty=2,lwd=2)
  # Annotation offsets only; coordinates of all measurements remain unchanged.
  offsets <- c(0.010,0.000,-0.005,0.014,0.005,-0.014,-0.013)
  text(validation$reference_kPa+0.012, validation$predicted_kPa+offsets,
       paste0(validation$trial,ifelse(validation$trial=="V3","*","")), adj=0, cex=0.8)
  legend("topleft",c(sprintf("V1-V3 RMSE = %.4f kPa", validation_rmse), "* V3 final height not recorded"),bty="n",cex=0.8)
})

# Same seven recordings and relative time definition as the source F04.
# Subtracting each trial mean improves label readability; mean counts are shown.
export("F04_raw_signal_stability.png", function() {
  par(mfrow=c(4,2),mar=c(3.3,4.2,2.8,1.0),oma=c(0,2.5,0,0),
      mgp=c(2.3,0.65,0),cex=0.9)
  for (id in names(cal_files)) {
    d <- cal_files[[id]]; mean_raw <- mean(d$raw_pressure)
    plot((d$esp32_ms-d$esp32_ms[1])/1000, d$raw_pressure-mean_raw,
         type="l",col=blue,lwd=1.1, xlab="Elapsed time (s)", ylab="",
         main=sprintf("%s   mean %.0f",id,mean_raw),cex.main=0.9,cex.axis=0.8)
    abline(h=0,lty=3,col="grey65")
  }
  plot.new()
  text(0.5,0.5,"P0-P6 recordings\nAll samples retained\nSeparate vertical scales\nMean subtraction for display",cex=0.8)
  mtext("Raw counts minus trial mean",side=2,outer=TRUE,line=0.6,cex=0.9,las=0)
},width=2800,height=2800,res=240,pointsize=18)

export("F05_zero_recovery.png",function() {
  y <- zero_tests$predicted_kPa
  plot(seq_along(y),y,type="b",pch=19,col=blue,lwd=2,xaxt="n",
       xlab="Chronological zero-pressure recording",ylab="Predicted gauge pressure (kPa)",
       main="F05  Zero-pressure recovery",ylim=c(-0.05,0.06),xlim=c(0.85,4.2))
  axis(1,at=seq_along(y),labels=zero_tests$trial)
  abline(h=0,col=red,lty=2)
  text(seq_along(y),y,sprintf("%.4f",y),pos=c(3,1,3,1),cex=0.8)
  legend("topright",sprintf("Range of four means = %.4f kPa",diff(range(y))),bty="n",cex=0.85)
})

export("F06_repeatability.png",function() {
  y <- repeat_tests$predicted_kPa; reference <- mean(repeat_tests$reference_kPa)
  plot(1:2,y,pch=19,col=blue,cex=1.5,xaxt="n",xlim=c(0.6,2.4),ylim=c(0.225,0.263),
       xlab="Independent recording at the same initial reference",ylab="Predicted gauge pressure (kPa)",
       main="F06  Repeatability at 0.2452 kPa")
  axis(1,at=1:2,labels=c("V2","V3*"))
  abline(h=reference,col=red,lty=2)
  text(1:2,y,sprintf("%.4f kPa",y),pos=3,cex=0.9)
  legend("topleft",c(sprintf("Difference = %.4f kPa",abs(diff(y))),"* V3 final water height not recorded"),bty="n",cex=0.8)
})
cat("Six publication figures regenerated; original figures preserved separately.\n")
