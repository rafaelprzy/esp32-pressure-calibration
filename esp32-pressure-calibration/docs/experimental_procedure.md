# Experimental procedure and recovered metadata

This procedure reconstructs the completed work from the supplied files and experimenter statements. Details that were not recorded remain unknown. The sequence is sufficient to understand the method; it is not evidence of a controlled settling time, specified ambient temperature or independently measured leak rate.

## Completed calibration sequence

1. The ESP32 and HX710B-based module were connected with data on GPIO 5, clock on GPIO 6 and sensor supply at 3.3 V. USB supplied power and a local Wi-Fi webpage supported recording.
2. A water-filled U-tube and metric scale were mounted on a panel. One leg remained open to atmosphere. The other leg, sensor and syringe were pneumatically connected.
3. Pressure was varied manually using the syringe. The measured left and right heights, rather than syringe displacement or intended targets, supplied the reference value.
4. P0-P5 were recorded at increasing assigned reference pressure. All samples in each CSV were summarized by a mean raw count. P0 was slightly negative (-0.3 cm signed difference), not a zero point.
5. P6 followed as an equal-height zero-recovery check. It was excluded from regression and retained as a separate result.
6. The original linear model was fitted to the six P0-P5 means and subsequently applied without refitting to new recordings.

## Completed independent validation sequence

The order was **Z0, V1, Z1, V2, Z2, V3, Z3**. Within this session, boot timestamps increase in that order. The validation boot times start below the calibration boot times, consistent with a clock reset or a different boot session; they do not establish the elapsed wall-clock gap between phases.

Z0-Z3 are four additional equal-height zero-pressure recordings. V1 used a measured 3.0 cm total difference (0.2941995 kPa), rather than a nominal 2.5 cm target. V2 and V3 used a 2.5 cm reference (0.24516625 kPa). The experimenter explicitly states that V3's final water height was not recorded. Its assigned initial/reference value is retained to preserve the original analysis, and a V1-V2-only RMSE is supplied as a sensitivity check. No missing height is estimated from sensor data.

## Recovered per-trial references

| Trial | Left cm | Right cm | Difference cm | Reference kPa | Role |
| --- | --- | --- | --- | --- | --- |
| P0 | 14.5 | 14.8 | -0.30 | -0.02941995 | fit |
| P1 | 15 | 14.3 | 0.70 | 0.06864655 | fit |
| P2 | 15.5 | 13.8 | 1.70 | 0.16671305 | fit |
| P3 | 16 | 13.3 | 2.70 | 0.26477955 | fit |
| P4 | 16.5 | 12.8 | 3.70 | 0.36284605 | fit |
| P5 | 17 | 12.5 | 4.50 | 0.44129925 | fit |
| P6 | 14.5 | 14.5 | 0.00 | 0.00000000 | initial zero check |
| Z0 | 14.5 | 14.5 | 0.00 | 0.00000000 | zero validation |
| V1 | 16 | 13 | 3.00 | 0.29419950 | positive validation |
| Z1 | 14.5 | 14.5 | 0.00 | 0.00000000 | zero validation |
| V2 | 15.75 | 13.25 | 2.50 | 0.24516625 | positive validation |
| Z2 | 14.5 | 14.5 | 0.00 | 0.00000000 | zero validation |
| V3 | 15.75 | 13.25 | 2.50 | 0.24516625 | positive validation |
| Z3 | 14.5 | 14.5 | 0.00 | 0.00000000 | zero validation |

## Repeating the method with another apparatus

The following are reproduction instructions, not retrospective claims that every step was logged. Confirm pin labels and supply voltage, check the pneumatic connection and atmospheric opening, keep liquid away from the sensor, align the scale vertically, and read both menisci at eye level after visible motion subsides. Record actual initial and final heights, ambient conditions and any intervention. Start a fresh recording, retain the raw CSV, stop before downloading, and give it a distinct trial filename. Do not transfer this hardware's calibration equation to another sensor as if it were universal.

A repeated experiment may show different offsets or slopes. Reproducing the supplied analysis requires no new experiments; reproducing the physical instrument's performance would require its own measurements. No additional recordings are prerequisites for completing this project package.
