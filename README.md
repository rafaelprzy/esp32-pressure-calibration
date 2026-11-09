# ESP32 pressure calibration

An educational pressure instrumentation project by **Rafael Patrick Przydzimirski** ([rafaelprzy](https://github.com/rafaelprzy)): an ESP32-S3 reads an HX710B-based module, records timestamped raw counts, and displays estimated gauge pressure in a local browser. A water U-tube supplies an approximate physical reference; base R rebuilds the calibration and evaluates later recordings.

The experiment is complete. This package documents the existing work and preserves its limitations. It is an experimental platform, unsuitable for clinical, patient-monitoring, safety-critical or certified measurement use.

![Calibration curve](figures/generated/F01_calibration.png)

## What the measurements show

- Six trial means (P0-P5) establish `P_kPa = -3.56846908986 + 1.18183110197e-6 * raw_counts`.
- Calibration interval: **-0.02941995 to +0.44129925 kPa**. P6 is a held-out zero-return check.
- Calibration RMSE: **0.01139345 kPa**, R squared: **0.995101539**.
- Later positive-pressure validation RMSE: **0.00897939 kPa** across V1-V3. **V3 has no final manometer-height measurement**; excluding it gives **0.01098822 kPa** across V1-V2.
- The four zero-pressure means span **0.07064438 kPa**. RMSE across all seven validation trials, including zeros, is **0.02029445 kPa**.

R squared measures fit, not percentage accuracy. Neither RMSE nor the narrow V2-V3 agreement is a certified accuracy or uncertainty specification. The homemade reference has no traceable calibration, and signals change during individual recordings.

## Reproduce the analysis

Install R with its standard packages. Verification used R 4.6.1; no contributed R packages are needed. From the repository root:

```sh
Rscript --vanilla analysis/01_calibration_validation.R
Rscript --vanilla analysis/02_generate_figures.R
Rscript --vanilla tests/verify_analysis.R
```

The figure script also runs the analysis, so it works alone in a fresh session. Both analysis entry points accept a repository-root path as the first argument when invoked elsewhere. They write only derived tables and figures; they never edit `data/raw`.

## Read the engineering documentation

- [Technical report PDF](docs/report/technical_report.pdf) and [editable Word report](docs/report/technical_report.docx)
- [Hardware and wiring](docs/hardware.md), [technical specification](docs/technical_specification.md), and [experimental procedure](docs/experimental_procedure.md)
- [Software architecture and HTTP interface](docs/software_architecture.md)
- [Operational verification checklist](docs/operational_verification.md)
- [Results and discussion](docs/results_and_discussion.md), [limitations](docs/limitations.md), and [figure captions](docs/figure_captions.md)
- [Reproduction guide](docs/reproducibility.md), [data dictionary](docs/data_dictionary.md), and [dependency versions](docs/dependencies.md)
- [Requirements and verification](docs/requirements_verification.md), [final review](docs/final_review.md), and [publication checklist](docs/publication_checklist.md)
- [Portfolio descriptions](docs/portfolio.md)

## Package layout

```text
firmware/esp32websensor/   Sanitized final sketch and example configuration
analysis/                Portable base-R entry points and historical scripts
data/raw/calibration/    P0-P6, unchanged original CSVs
data/raw/validation/     Z0,V1,Z1,V2,Z2,V3,Z3, unchanged original CSVs
data/metadata/           Recorded heights, chronology and source hashes
results/                 Recomputed model, tables, checks and session information
figures/original/        Supplied PNGs preserved byte for byte
figures/generated/       Six reproducible publication figures
figures/apparatus/       Metadata-stripped apparatus photographs
figures/dashboard/       Supplied dashboard screenshots without metadata
docs/                    Report, engineering notes and review material
tests/                   Analysis and package integrity checks
```

## Hardware and firmware

The documented wiring is 3.3 V, GND, data GPIO 5 and clock GPIO 6. Copy `firmware/esp32websensor/config.example.h` to `config.h`, enter your own Wi-Fi details, and keep that file private. See [firmware instructions](firmware/README.md) before building. The final sketch compiles for a generic ESP32-S3 target with Arduino ESP32 3.3.12 and HX710AB 0.3.1. A build check does not verify operation on the physical apparatus.

The supplied historical CSVs have four columns. The final firmware adds a fifth derived `pressure_kPa` column; no exported dataset from that final version was supplied. The dashboard was confirmed operational by the experimenter and is documented in screenshots; no live hardware retest occurred during packaging.

## Attribution and reuse

Code is licensed under [MIT](LICENSE). Data, results, figures, photographs and documentation are licensed under [CC BY 4.0](LICENSE-DATA-DOCS.md). Cite the project using [CITATION.cff](CITATION.cff). No external library is vendored. The suggested first release is `v1.0.0`, labeled **Educational experimental prototype**; no GitHub repository or release has been created by this documentation workflow.
