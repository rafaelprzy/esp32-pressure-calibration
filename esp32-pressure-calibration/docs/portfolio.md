# Portfolio materials

## Short technical summary

Developed and calibrated an ESP32-S3 pressure acquisition prototype using an HX710B-based sensing module and a water U-tube reference. Implemented local browser monitoring and CSV recording, then analyzed 14 recordings in R. A six-trial calibration achieved R squared 0.9951 and fit RMSE 0.0114 kPa over -0.0294 to +0.4413 kPa. Independent positive-pressure validation gave 0.0090 kPa RMSE, with a documented missing final height for one trial. Zero-pressure variation of 0.0706 kPa identified an important operating limitation.

## Longer professional description

I built an educational low-pressure measurement platform that connects embedded acquisition, a physical pressure reference and reproducible statistical analysis. An ESP32-S3 reads an HX710B-based pressure module, timestamps raw counts, stores experiments in a bounded memory buffer and serves a local monitoring webpage. The interface shows estimated gauge pressure, raw readings, a time-series graph, recording controls and the demonstrated calibration interval.

I used a manually pressurized water U-tube as an approximate reference and fitted a linear calibration to six independent trial means. I held out an initial zero-return trial and evaluated seven later validation recordings without refitting. The analysis preserves all 2937 original readings and regenerates six scientific figures using base R. It also separates positive-pressure agreement from the larger zero-offset variation, retains a missing endpoint-height limitation and avoids interpreting R squared as accuracy.

The completed package includes sanitized firmware, unchanged raw data, explicit reference metadata, a technical report, requirements traceability and verification instructions. The project demonstrates a complete experimental engineering workflow while documenting the limits of a homemade reference, time-dependent signals and a small number of independent trials. It is an instrumentation learning platform and is not intended for clinical or safety-critical use.

## Suggested GitHub repository description

ESP32-S3/HX710B pressure prototype with U-tube calibration, local web monitoring, raw CSV data and reproducible R validation.

## Engineering competencies demonstrated

Embedded sensor interfacing; timestamped data acquisition; bounded-memory recording; HTTP and browser integration; hydrostatic pressure referencing; trial-level linear calibration; independent validation; interpretation of bias and zero-offset variation; reproducible R workflows; technical writing; evidence-based requirements verification; secure source packaging.

## Attribution

Rafael Patrick Przydzimirski — https://github.com/rafaelprzy

This text describes completed work and documented results. It does not imply institutional approval, a verified clinical application or a certified instrument specification.
