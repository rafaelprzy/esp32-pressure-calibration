# Operational verification checklist

This checklist separates available evidence from optional checks on physical hardware. No new recordings are required to complete the existing experimental documentation. No device was flashed or connected during packaging.

| Check | Evidence available | Status | Optional physical verification |
| --- | --- | --- | --- |
| Power and electrical connections | Photos, experimenter wiring and source pin constants | Documented; not electrically retested | Confirm 3.3 V, common ground, data GPIO 5 and clock GPIO 6 by labels. |
| Sensor raw acquisition | 14 original CSVs, 2937 readings | Verified for historical data | Check a changing live boot timestamp and plausible raw counts after an approved upload. |
| Firmware build | Full sanitized ESP32-S3 target compilation | Passed | Match board-specific USB, flash and PSRAM options before uploading. |
| Network and dashboard | Experimenter confirmation, two screenshots and browser source | Operation reported and visually documented | Join the same trusted local network and use the address printed to serial. |
| Recording start and stop | Source handlers and historical exports | Historical recording evidenced; final handlers compiled | Confirm Start resets count/ID and Stop preserves the buffer. Save before another Start. |
| CSV schema | Historical four-field files and final five-field handler | Historical schema verified; final export not exercised | Stop, download and inspect the header, raw values, timestamps and derived pressure. |
| Range indication | Source threshold and screenshot | Source and interface evidence | Check the badge against the estimated pressure; it is not an independent reference test. |
| Acquisition interval under HTTP traffic | Historical 250 ms median spacing | Historical timing verified; final-load timing unmeasured | Compare actual saved timestamps during relevant network activity. |
| Full-buffer behavior | 5000-entry buffer and stop guard | Source reviewed; not exercised | If needed for later use, verify the buffer stops without overwriting a trial. |
| Missing sensor or readiness timeout | 300 ms timeout branch | Source reviewed; not exercised | If needed for later use, check failure indications and retained timestamps. |
| Disconnect and restart | Blocking startup connection and volatile buffer in source | Source reviewed; recovery not exercised | Save data first; assess reconnection behavior only if required for a future iteration. |

The final sketch has no authenticated control routes, persistent storage or verified error indicator beyond the implemented source behavior. Keep that operating context distinct from a certified instrument specification. Rotate the original exposed Wi-Fi credentials before reuse.
