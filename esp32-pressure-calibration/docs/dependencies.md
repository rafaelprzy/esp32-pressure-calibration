# Software dependencies and verified environment

## Statistical analysis

Verified with R 4.6.1 (2026-06-24), 64-bit Windows. The analysis uses only standard R packages: base, stats, graphics, grDevices and utils. Session details are recorded in `results/R_session_info.txt`. No contributed package, RStudio installation, saved workspace or interactive object is required.

The final scripts remove absolute input paths, read explicit trial metadata and export results without depending on objects left in a previous session. The original scripts used one machine-specific data directory; the figure script depended on prior analysis objects. Those portability issues are resolved in the maintained entry points.

## Firmware

- Arduino CLI 1.5.1, confirmed locally.
- Arduino ESP32 core 3.3.12, inspected locally and used for the target build.
- Rob Tillaart HX710AB 0.3.1, inspected locally and used for the target build.
- `WiFi.h` and `WebServer.h` come with the ESP32 core.
- Target build: `esp32:esp32:esp32s3:FlashSize=16M,PSRAM=opi,CDCOnBoot=cdc,FlashMode=qio`.

The generic target and options establish compilation compatibility, not the exact settings originally used to acquire the experimental CSVs. The final sketch and installed HX710AB expose request/readiness/fetch methods. HX710B's `fetch(true)` selects the differential input; the module's exact sensing element remains undocumented. Consult the [library repository](https://github.com/RobTillaart/HX710AB) and [ESP32 Arduino documentation](https://docs.espressif.com/projects/arduino-esp32/en/latest/).

The browser dashboard is embedded in the sketch and draws its own canvas. It does not require a CDN, external charting library, remote database or cloud service.

## Package checks and report

`tests/verify_package.py` needs Python 3.9 or later and the standard library only. The DOCX is editable and the PDF is a verified export for reading and sharing. Reproducing the R results does not require the document-authoring tools used to assemble the report.
