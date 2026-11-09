# Results and engineering discussion

All six previously reported summary values reproduce at their stated precision. The maintained analysis agrees with the supplied main script to better than 1e-12 for those six statistics. It preserves the original unweighted trial-mean fit, all original samples, the P6 holdout and the validation chronology.

| Quantity | Recalculated result | Scope |
| --- | --- | --- |
| Intercept | -3.56846908986 kPa | P0-P5 means |
| Slope | 1.181831101965e-06 kPa/count | P0-P5 means |
| R squared | 0.995101539 | Six calibration trials |
| Calibration RMSE | 0.01139345 kPa | Fit error; denominator 6 |
| Positive validation RMSE | 0.00897939 kPa | V1-V3; V3 endpoint height missing |
| Validation RMSE excluding V3 | 0.01098822 kPa | V1 and V2; sensitivity result |
| All validation RMSE | 0.02029445 kPa | Seven validation trials including zeros |
| Zero-pressure mean spread | 0.07064438 kPa | Range of Z0-Z3 means |
| V2-V3 mean difference | 0.00335804 kPa | Two trials; conditional repeatability |
| P6 zero-check prediction | 0.00364341 kPa | Held out of fit |

## Calibration

The fitted relationship is `P_kPa = -3.56846908986 + 1.181831101970e-6 * raw_counts`, using six trial means from -0.02941995 to +0.44129925 kPa. The intercept is an extrapolated value at zero digital counts and has no direct interpretation as the measured zero-pressure error near three million counts. The residual standard error is 0.01395406 kPa with four residual degrees of freedom; it differs from RMSE because its denominator is 6-2 rather than 6.

R squared describes how much reference-pressure variation the fitted line explains within these six settings. It is not 99.51 percent accuracy. The signed fit errors range from -0.01534863 to +0.01443779 kPa. P6 predicts +0.00364341 kPa at its assigned zero reference and is never used to improve the fit.

## Independent validation

V1 predicts 0.27918225 kPa versus 0.29419950 kPa, an error of -0.01501725 kPa. V2 predicts 0.24117071 kPa versus 0.24516625 kPa, an error of -0.00399554 kPa. V3 predicts 0.24452875 kPa against its retained initial/reference value of 0.24516625 kPa, an error of -0.00063750 kPa, conditional on that reference remaining representative.

The 0.00897939 kPa positive-pressure RMSE excludes zero trials by the original definition. It is smaller than the calibration RMSE, but the limited, clustered validation settings and V3 reference caveat do not demonstrate improved accuracy. Excluding V3 gives 0.01098822 kPa. Including all validation trials gives 0.02029445 kPa, which better exposes the zero-offset behavior. No model is fitted to the validation data, and no post hoc zero correction is applied.

## Zero recovery and repeatability

Z0-Z3 predict +0.03853627, -0.03210811, +0.00557929 and -0.00969853 kPa. Their span is 0.07064438 kPa. Their mean signed error is only +0.00057723 kPa because positive and negative offsets cancel; zero-only RMSE is 0.02569613 kPa. Reporting the average offset alone would conceal the observed variation.

V2 and V3 differ by 0.00335804 kPa. The sample SD of those two means is 0.00237449 kPa. This is limited agreement at one initial pressure, separated by a zero trial, and V3 lacks an end-height check. It cannot characterize repeatability across the full interval, operators, days, devices or temperatures.

## Time dependence and sampling

Each trial contains 203-222 samples over 50.532-55.309 s between first and last readings. The total is 2937 rows. Median sample spacing is 250 ms for every trial, with observed steps 250-256 ms and effective rates of about 3.996-3.997 Hz. There are no saved-row ID gaps or nonincreasing timestamps.

All P0-P6 recordings have negative descriptive linear raw-count trends. The converted slopes range approximately from -0.000153 to -0.000522 kPa/s; initial-to-final ten-sample mean changes span about -0.0117 to -0.0272 kPa. Lag-one correlations across the 14 raw sequences range about 0.68-0.98, including any trend contribution. These are descriptive values, not independent error estimates or proof of thermal drift. No detrending or sample selection was used to improve the calibration.

Pressure settings and acquisition time were not randomized in the calibration sequence. Pressure and time can therefore be confounded. Falling counts may reflect pressure relaxation, leakage, thermal response, mechanical settling or sensor offset behavior; the existing records cannot isolate these causes. The approximate reference, sparse independent trials and missing V3 final height limit any accuracy claim.
