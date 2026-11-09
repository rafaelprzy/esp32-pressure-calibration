# Scientific figure captions and verification

Original F01-F06 PNGs are retained unchanged in `figures/original`. Their plotted values, fitted line and reported summaries are consistent with the supplied R code and CSV-derived results. Original F01/F02 have edge-label crowding, F03 has overlapping labels, and F04 has small labels at its supplied resolution. Publication derivatives address readability and disclose the V3 caveat without altering the model or deleting samples. Exact original export settings are unavailable.

## F01

Calibration of the six P0-P5 trial means against the assigned U-tube reference pressures. The line is the unweighted ordinary least-squares fit; P6 and all validation trials are excluded. R squared is 0.995101539 and RMSE is 0.01139345 kPa. Counts are displayed in millions. The line is an empirical calibration over the tested interval and does not establish a certified accuracy specification.

## F02

Calibration prediction error, defined as fitted pressure minus U-tube reference pressure, for P0-P5. The dashed line denotes zero error. These are in-sample errors for six physical settings; their signs and magnitudes are retained without trimming or correction. The plot cannot distinguish reference error, time effects and sensor nonlinearity.

## F03

Independent validation using the original frozen P0-P5 model. The dashed line indicates equality of predicted and reference pressure. The positive-pressure RMSE of 0.00897939 kPa uses V1-V3 only; Z0-Z3 are displayed but excluded from that number. V1 uses the actual 3.0 cm difference. V3 uses its recorded 2.5 cm reference and lacks a final height measurement.

## F04

Raw signal behavior in the seven calibration-phase recordings P0-P6. Time is relative to each recording's first ESP32 timestamp. For legibility, each panel displays raw counts minus that trial's mean, with the mean printed in the panel title; separate vertical scales are used. No samples are removed, smoothed or detrended. The original absolute-count version is preserved. Falling signals indicate time dependence but do not identify its physical cause.

## F05

Chronological zero-pressure predictions for Z0, Z1, Z2 and Z3, interleaved with the positive validation trials in the original acquisition sequence. The dashed line denotes the assigned 0 kPa gauge reference. The range of the four means is 0.07064438 kPa. Connecting segments indicate order rather than continuous measurements or a fitted drift model.

## F06

Comparison of V2 and V3 trial-mean predictions at the same assigned initial reference of 0.24516625 kPa, shown by the dashed line. Their absolute difference is 0.00335804 kPa and the sample standard deviation of the two means is 0.00237449 kPa. V3 lacks a final water-height measurement; two trials provide limited, conditional repeatability evidence.
