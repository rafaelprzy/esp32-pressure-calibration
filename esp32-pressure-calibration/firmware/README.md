# Firmware configuration and build

The final sketch is in `esp32websensor/esp32websensor.ino`. Its only intentional change from the supplied version is moving Wi-Fi name/password into private configuration. Calibration constants, pin numbers, state machine, dashboard and routes are retained.

1. Install the Arduino ESP32 core and HX710AB library. The verified combination is core 3.3.12 and HX710AB 0.3.1.
2. Copy `esp32websensor/config.example.h` to `esp32websensor/config.h` and enter your own network details. That file is ignored by version control. Do not reuse the original exposed password; rotate it at the hotspot or access point.
3. Open the sketch folder in Arduino IDE and select an appropriate ESP32-S3 board. The successfully compiled generic configuration is 16 MB flash, OPI PSRAM, USB CDC enabled and QIO flash. The exact original board settings were not supplied; confirm them for your board.
4. Build before uploading. A CLI equivalent for the verified build is:

```sh
arduino-cli compile --fqbn esp32:esp32:esp32s3:FlashSize=16M,PSRAM=opi,CDCOnBoot=cdc,FlashMode=qio firmware/esp32websensor
```

5. If physically operating the prototype, connect the documented wiring, upload through the appropriate USB port, inspect serial at 115200 baud and join the same local Wi-Fi network. Use the address printed by the sketch. No particular private IP is embedded in the public package.
6. Check live values, record a short trial, stop, download and retain the CSV before starting another trial. This sequence is an operational checklist; it was not rerun on hardware while preparing the package.

The build completed with 930423 bytes of program storage and 147068 bytes of reported global-variable memory, leaving 180612 bytes in the compiler's dynamic-memory summary for the tested configuration. The 16 MB physical flash setting does not mean the selected default app partition is 16 MB; the build's app limit was 1310720 bytes. No hardware upload occurred.

The static sample buffer is volatile. Starting a new recording clears the old one. No authentication protects control routes, and a synchronous CSV request may delay acquisition. Keep the device on a trusted local network and stop before downloading. None of these details establishes an accuracy or safety specification.

See the [operational verification checklist](../docs/operational_verification.md) for evidence status and optional physical checks.
