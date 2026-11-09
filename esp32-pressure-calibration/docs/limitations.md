# Measurement uncertainty and limitations

The device is an educational experimental instrumentation platform. It is not a clinical, patient-monitoring, safety-critical or certified pressure instrument. The following limits are part of the experimental result.

## Reference and physical model

The U-tube is an approximate reference with no demonstrated traceability. The conversion `P_ref (kPa) = 0.0980665 * (left_cm - right_cm)` uses an approximate water density of 1000 kg/m3 and standard gravity of 9.80665 m/s2. It does not measure local gravity or compensate for water temperature, density, capillary effects or air density. Air-column contributions are neglected at this scale. These assumptions are adequate to explain the experiment but do not define a certified standard.

Height error propagates directly: a 1 mm error in the total height difference changes the reference by 0.00980665 kPa. If each height had an independent standard uncertainty of 1 mm, an illustrative propagated standard uncertainty would be about 0.01387 kPa. Neither 1 mm assumption was measured or assigned to this apparatus; these are sensitivity examples, not a completed uncertainty budget.

Meniscus choice, parallax, nonvertical reference scale, unequal tube bores, contact-angle changes and capillarity can affect the height difference. Capillary shifts can partially cancel in similar legs but cannot be assumed to cancel without geometry and wetting information. Water motion invalidates a static interpretation until it settles. Leaks and compliant tubing can change actual pressure during a recording. The syringe displaces volume, while pressure also depends on trapped-air volume, compliance, temperature and hydrostatic loading; its graduation cannot replace the manometer reference.

## Statistical interpretation

Calibration fit describes agreement with the reference on training trials. Independent validation uses new trials and the frozen model. Precision concerns the dispersion of repeated indications under stated conditions; repeatability requires similar conditions and is only weakly evidenced by V2-V3. Accuracy concerns agreement with a reference or accepted value and cannot be quantified here as a certified percentage. Bias is a mean signed discrepancy for a specified subset. Zero-offset variation is observed between equal-height recordings; drift suggests time-dependent indication change but does not identify its cause. Measurement uncertainty requires a defensible model and quantified contributions, which these records do not provide in full.

Within-recording SD includes slow changes. Consecutive readings are correlated, so SD divided by the square root of all raw samples would overstate the information in the data if interpreted as a complete uncertainty of calibration. Six physical settings, rather than 2937 rows, determine the fitted model. Ordinary least squares treats the predictor means as fixed and does not explicitly include uncertainty in either axis. No replicated multi-level design supports a formal lack-of-fit or hysteresis assessment.

## Observed operating limits

The four validation zero means span 0.07064438 kPa. Calibration covers only -0.02941995 to +0.44129925 kPa, and independent positive validation is clustered around 0.245 and 0.294 kPa. Values outside the demonstrated interval are extrapolations. An advertised sensor pressure range, if later recovered, would not enlarge the range verified by this experiment. The exact transducer identity is not established.

V3 lacks a final manometer reading. Other recordings have one assigned reference pair in the R scripts; separately logged end heights are not available. Temperature, ambient pressure, repeated days, operators, hardware substitutions, dynamic response and a traceable standard were not studied. Calibration coefficients are specific to this assembly and conditions.

Firmware compilation and source inspection do not verify sensor electrical timing, performance under network load, CSV download timing, buffer endurance, disconnect handling, browser compatibility or final-firmware export behavior. Dashboard screenshots show operation but are not synchronized reference measurements. Out-of-range graph spikes in the supplied screenshot are retained as interface evidence and are excluded from quantitative calibration claims.
