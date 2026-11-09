# Embedded software and dashboard architecture

The maintained firmware is the supplied final Arduino sketch with one security change: hard-coded network credentials are replaced by an include of private `config.h`. Acquisition, calibration constants, dashboard content and recording behavior are otherwise preserved. The public example contains placeholders only.

## Separation of responsibilities

1. `sampleSensor()` handles HX710B acquisition on the ESP32. A request/readiness state machine avoids a busy wait for conversion during the main loop. The 24-bit fetch still executes synchronously.
2. `convertRawToPressureKPa()` applies the rounded calibration to each raw count; `isWithinCalibratedRange()` tests the resulting estimate against rounded limits.
3. A static `Sample samples[5000]` buffer stores ID, relative timestamp, boot timestamp, raw count and derived pressure. The five 32-bit fields imply about 100 kB on the tested target; a complete linker memory report includes additional objects.
4. `WebServer` handles HTTP requests on port 80. `loop()` calls `server.handleClient()`, `sampleSensor()`, then `delay(1)`.
5. Browser JavaScript requests `/latest` every 500 ms, renders values and a canvas chart, and sends recording commands. It keeps at most 180 distinct sensor timestamps within a 60000 ms age window. This display history can omit readings between polls and is not the scientific dataset.
6. Base R imports saved CSVs after acquisition, assigns the manometer reference metadata, fits trial means and evaluates independent recordings. R does not run on the ESP32 or in the browser.

## Timing and state

When due, acquisition calls `request()` and enters a waiting state. It checks `is_ready()` each loop. If not ready after more than 300 ms, it abandons the request, logs a warning, and schedules another attempt after 250 ms. On readiness it calls `fetch(true)`, timestamps the completed read, updates live values, and schedules the next request 250 ms after that read. Therefore conversion/readiness time and HTTP servicing can add delay; the setting is not a verified exact 4 Hz scheduler. The actual historical files show median spacing 250 ms and a 250-256 ms observed range.

Acquisition continues while recording is stopped. Only buffered recording IDs advance while recording. `/start` resets the count and IDs, sets an experiment start time and enables buffering. When a subsequent sample arrives after the buffer has reached capacity, recording stops. `/stop` retains the current buffer. There is no persistent filesystem storage, automatic time synchronization or automatic trial naming.

`connectWiFi()` waits in a blocking loop until connected at startup. This is separate from the nonblocking acquisition state machine. No reconnection policy or sensor-freshness field is provided by the HTTP server. The browser infers freshness from changing timestamps and labels data stale after about 3 s. A 32-bit millisecond clock wraps after approximately 49.7 days; that long-duration behavior was not tested.

## HTTP endpoints

The browser issues GET requests. The sketch registers handlers without restricting them to an explicit method. No credentials or tokens protect these endpoints; use a trusted local network.

| Route | Response | Behavior | Operational note |
| --- | --- | --- | --- |
| / | HTML | Serves embedded dashboard | Read only |
| /latest | JSON | raw_pressure, pressure_kPa, esp32_ms, recording, sample_count, sample_id, in_range | Read only |
| /start | Plain text | Clears buffer, resets ID, timestamps start, enables recording | Erases previous RAM recording |
| /stop | Plain text | Disables recording, retains buffered samples | Preserves buffer until next start or reset |
| /csv | CSV attachment | Streams all current buffered rows as pressure_trial.csv | Stop first; streaming occupies the request handler |

`/latest.sample_id` is the latest buffered trial ID, while `esp32_ms` and the raw/pressure values continue to update when stopped. Do not interpret it as a live-reading sequence counter. `in_range` tests the estimated pressure, not an independently observed reference. A fitted P5 mean predicts approximately 0.4557 kPa, beyond the 0.4413 kPa reference endpoint, so the flag need not classify every calibration mean as in range.

## CSV and blocking operations

The final route streams `sample_id,experiment_ms,esp32_ms,raw_pressure,pressure_kPa` with pressure formatted to five decimals. All supplied experimental CSVs have only the first four fields, reflecting an earlier acquisition export. The exact earlier sketch was not supplied, so the historical files cannot verify every behavior of the final version.

Although sensor waiting is nonblocking, `WebServer` and CSV streaming are synchronous. A CSV download can delay the acquisition call. Stop recording before downloading, as the dashboard instructs. No simultaneous-download timing, full-buffer endurance, disconnect recovery or final five-column CSV round trip was measured during packaging.

## Evidence of operation

The experimenter confirmed the webpage works. Two supplied screenshots document the interface and its controls. The complete sanitized firmware passed a target compilation with Arduino ESP32 3.3.12 and HX710AB 0.3.1 using placeholder network details. This confirms build compatibility for that configuration; it does not replace an upload or hardware test. Source review identified no reason to change the experimental acquisition logic to finish this documentation.
