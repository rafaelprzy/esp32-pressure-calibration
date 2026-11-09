# Reproducibility guide

## Reproduce the existing results

1. Extract this package or clone it once the owner has published a repository. The intended owner is `rafaelprzy` and the proposed name is `esp32-pressure-calibration`; no remote is assumed to exist.
2. Open a terminal at the project root and ensure `Rscript` is available. The verified runtime is R 4.6.1 with standard `stats`, `graphics`, `grDevices` and `utils` packages. No package installation is required.
3. Run `Rscript --vanilla analysis/01_calibration_validation.R`. This creates the model, trial summaries, validation metrics and quality tables in `results`.
4. Run `Rscript --vanilla analysis/02_generate_figures.R`. This starts by sourcing the analysis and creates all six figures in `figures/generated`; the original figures remain untouched.
5. Run `Rscript --vanilla tests/verify_analysis.R` from the root. It checks trial inclusion, sample counts, chronology, measured V1 reference, V3 missing-height handling, numerical results and figure presence.
6. Optionally run `python tests/verify_package.py` with Python 3.9 or later. It verifies the original CSV/figure hashes and safe package contents using the standard library.

Both analysis entry points can be called from another working folder with an explicit root:

```sh
Rscript --vanilla /path/to/repository/analysis/02_generate_figures.R /path/to/repository
```

In RStudio, open a fresh session, set the working folder to the repository root, and source either maintained script. Historical scripts in `analysis/source_archive` are evidence of the earlier workflow; their private paths were removed and they are not maintained entry points.

## What is deterministic

The same raw rows and reference metadata reproduce the numerical model and tables within floating-point tolerance. The main script's six summary values were compared with the supplied original after changing only its input path. Plot data are deterministic. PNG bytes, fonts and exact antialiasing may vary with R version, operating system and graphics device. The supplied PNGs were not claimed to be bit-identical to the exported files because their exact original export settings were not recorded.

## What the checks cannot establish

No physical apparatus, new pressure measurements or live browser endpoint was operated during documentation. A successful target build is recorded separately. The historical raw export predates the final five-column schema. Initial settling time, temperature, endpoint heights and original acquisition software versions cannot be recovered from the CSVs. These omissions do not prevent reproducing the existing statistical analysis.

## File integrity

The source inventory records relative source locations and SHA256 hashes for 33 files. The raw CSV and original-figure hashes can be checked by `tests/verify_package.py`. Other publication files intentionally differ from their sources where credentials, paths or embedded image metadata were removed. The source folder was never modified. Session information and the publication checklist record the verified environment and remaining hardware checks.
