# Requirements and verification matrix

Statuses distinguish saved-data checks, source/build evidence, reported operation and unexecuted hardware checks. No historical CSV establishes a final-firmware five-column export.

| ID | Description | Rationale | Verification method | Evidence | Status |
| --- | --- | --- | --- | --- | --- |
| FR-001 | Acquire raw pressure readings | Retain unconverted sensor evidence | Inspect CSVs and acquisition code | 14 original CSVs; sampleSensor and HX710B fetch | Verified for historical data; source reviewed |
| FR-002 | Associate each reading with timestamps | Analyze order and elapsed time | Check monotonic time and fixed timestamp offset | acquisition_quality.csv; 2937 finite rows | Verified for historical data |
| FR-003 | Export data as CSV | Allow offline scientific analysis | Inspect original exports and /csv handler | 14 four-column CSVs; final five-column route compiles | Historical export verified; final export not exercised |
| FR-004 | Convert counts to gauge pressure | Implement the measured calibration | Recompute coefficients and inspect conversion | metrics.csv; original_method_parity.csv; convertRawToPressureKPa | Verified by analysis and source; compiled |
| FR-005 | Display live pressure and raw counts | Support experiment observation | Inspect supplied screenshot and browser code | dashboard_live.png; experimenter confirmation | Operation reported and visually documented; no live retest |
| FR-006 | Maintain a time-series display | Show temporal behavior | Inspect chart and screenshots | Browser history; 60 s window and 180 point cap | Operation reported; timing not benchmarked |
| FR-007 | Preserve raw counts beside derived values | Avoid losing original information | Check exports and retained raw files | Four-column raw archive; final Sample structure and /csv | Raw preservation verified; final five-column export source only |
| FR-008 | Show tested calibration interval | Identify extrapolation | Inspect source and supplied screenshot | -0.02942 to 0.44130 kPa constants; screenshot | Verified in source and screenshot; boundary behavior not live tested |
| FR-009 | Bound recording memory | Prevent unbounded sample growth | Inspect buffer and full condition; compile | 5000 Sample entries; stop guard; successful target build | Verified by source and build; full-buffer behavior not exercised |
| FR-010 | Keep acquisition independent of browser polling | Retain MCU-side timing | Inspect loop and timestamps | sampleSensor in loop; 500 ms browser poll | Verified architecture; HTTP-load timing not measured |
| QA-001 | Reproduce analysis from a clean R session | Make results auditable | Run both scripts and parity comparison | R 4.6.1; verify_analysis.R; original_method_parity.csv | Verified in this environment |
| QA-002 | Document uncertainty and limitations | Prevent unsupported accuracy claims | Review report and results | Zero variation, reference limits and V3 caveat retained | Documented; uncertainty budget not experimentally quantified |
| QA-003 | Keep original CSVs unchanged | Preserve experimental provenance | Compare SHA256 hashes | source_inventory.csv; 14 exact byte copies | Verified |
| QA-004 | Preserve figures and regenerate them | Separate original evidence from presentation | Check original hashes and execute figure script | Six original plots plus Rplot; six new exports | Verified; exact original export settings unavailable |
| QA-005 | Remove private configuration from distribution | Prevent credential disclosure | Compare firmware change; scan text and metadata | config.example.h; ignored config.h; publication audit | Verified package checks; credentials must still be rotated by owner |
| QA-006 | Document reproducible firmware dependencies | Enable a build without changing experiment | Inspect installed versions and build target | HX710AB 0.3.1; Arduino ESP32 3.3.12; target build passes | Build verified; original acquisition software versions not established |
