# Data dictionary and provenance

The 14 original CSVs contain **2937 readings** and are unchanged byte copies. Seven are in `data/raw/calibration` (P0-P6) and seven are in `data/raw/validation` (chronology Z0,V1,Z1,V2,Z2,V3,Z3). Filenames identify trials; CSVs do not contain measured manometer heights, calendar timestamps, temperature or firmware versions.

| Field | Type | Unit | Meaning |
| --- | --- | --- | --- |
| sample_id | integer | count | Trial-local ID; starts at 1 in the supplied CSVs; reset by /start |
| experiment_ms | integer | ms | ESP32 acquisition timestamp minus recording start; first sample need not be at zero |
| esp32_ms | integer | ms | Time since MCU startup; not a calendar timestamp |
| raw_pressure | signed integer | ADC counts | Raw HX710B output; not a pressure unit |
| pressure_kPa | floating point | kPa gauge | Present in final firmware export only; absent from all 14 supplied raw CSVs; derived from rounded calibration coefficients |

Within every supplied file, sample IDs are consecutive, timestamps increase, all four fields are finite numeric values and `esp32_ms - experiment_ms` is constant. These checks rule out internal ID gaps and nonmonotonic timestamps in saved rows; they do not prove that every hardware conversion was saved or that clocks were externally synchronized.

## Metadata and derived tables

- `data/metadata/trials.csv` records trial role, order, left/right heights, assigned reference and explicit final-height status. Heights are transcribed from supplied R scripts, with the experimenter correction retained for V1. Final heights are not imputed.
- `data/metadata/source_inventory.csv` inventories all 33 source files with original bytes, SHA256 and publication disposition. Source paths are relative; no private disk location is included.
- `results/trial_summary.csv` contains one row per trial: sample count, mean raw counts, sample SD, reference pressure, predicted trial-mean pressure, signed prediction error and transformed within-recording SD.
- `results/calibration_results.csv` contains P0-P5 only; `validation_results.csv` contains all seven validation trials in order.
- `results/metrics.csv` identifies the trial subset and definition for every scalar result. `comparison_to_reported.csv` checks agreement with previous rounded values.
- `results/acquisition_quality.csv` includes timestamp intervals, observed duration, descriptive trend and lag-one correlation. Trend and autocorrelation describe the recorded sequence, not a fitted physical drift mechanism.
- `results/original_method_parity.csv` records exact numerical parity with the supplied main analysis after replacing its input path. It is a packaging-verification result rather than a newly measured dataset.

Within-recording SD is expressed both in counts and after linear conversion. It includes time dependence and fluctuations; it is not an uncertainty of a trial mean. The quality field `nonunit_id_steps` counts nonconsecutive ID transitions, not a count of physically missing ADC conversions. `span_s` is last minus first sample time, not total time since the Start button.
