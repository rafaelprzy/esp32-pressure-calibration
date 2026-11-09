# Technical specification

This is a specification of the implemented educational prototype, not a certified product specification. Values are source-derived unless identified as measured or calculated.

| Item | Documented value | Evidence class |
| --- | --- | --- |
| Controller | ESP32-S3 N16R8 development board | Experimenter and photograph |
| Sensor interface | HX710B data GPIO 5; clock GPIO 6; 3.3 V supply | Sketch and experimenter |
| Conversion | P = -3.56846908986 + 1.181831101965e-06 raw | Calculated from six trial means |
| Firmware constants | -3.568469 and 0.000001181831 | Source; deliberately retained rounded values |
| Reference interval | -0.02941995 to +0.44129925 kPa | Calculated from recorded water heights |
| Acquisition scheduling | 250 ms after preceding read; ready polling; 300 ms timeout | Source; not a hard real-time guarantee |
| Historical sampling | Median 250 ms; all observed steps 250-256 ms | Measured from supplied timestamps |
| Buffer | 5000 structures, five 4-byte fields | Source; approximately 100000 bytes on the tested target |
| Browser updates | 500 ms requested poll interval | Source; latency and loss not benchmarked |
| Browser plot | 60 s age window, maximum 180 received points | Source; not the recording buffer |
| HTTP | Port 80, station-mode local network | Source; no authentication or transport encryption |
| Serial | 115200 baud | Source |
| Historical CSV schema | sample_id,experiment_ms,esp32_ms,raw_pressure | All 14 original files |
| Final CSV schema | Historical fields plus pressure_kPa | Source and successful compilation; export not retested |
| Reference quality | Homemade approximate U-tube; no traceability evidence | Experimenter and records |
| Use classification | Educational experimental instrumentation platform | Project scope |

At the observed approximately 4 Hz, a 5000-row buffer would span roughly 1250 s (20.8 min). This is a capacity estimate, not a measured endurance result. Buffer retention is volatile: a new recording, reset or power loss discards the previous trial. Measured interval does not establish sensor bandwidth, response time or anti-aliasing performance.
