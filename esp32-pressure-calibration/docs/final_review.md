# Final review

The documentation package is complete for owner review. No source experiment was modified, no new measurements were invented, and no GitHub repository or release was created.

## Completed deliverables

- **Technical report:** [32-page PDF](report/technical_report.pdf), [editable DOCX](report/technical_report.docx), and [Markdown source](report/technical_report.md). The report includes 17 numbered tables, eight numbered figures (two apparatus photographs in one figure, six scientific plots and a dashboard screenshot), nine editable native equations, primary references and all requested subject sections.
- **Scientific analysis:** both portable base-R entry points, 14 unchanged CSVs containing 2937 readings, explicit trial metadata, six original scientific figures plus the supplied Rplot, six regenerated publication figures, model and result tables.
- **Embedded package:** final sanitized sketch, private-configuration example, architecture, HTTP route description, CSV dictionary, build instructions and operational checklist.
- **Engineering documentation:** hardware bill of materials, wiring, recovered procedure, technical specification, uncertainty discussion, reproduction guide and a 16-requirement verification matrix.
- **Portfolio and publication:** short and long portfolio text, repository description, competency statement, scoped MIT/CC BY 4.0 licenses, citation metadata, release-note draft and publication checklist.

## Recalculated evidence

| Quantity | Result | Interpretation |
| --- | --- | --- |
| Calibration R squared | 0.995101539 | Six P0-P5 trial means |
| Calibration RMSE | 0.01139345 kPa | Training fit error |
| Positive validation RMSE | 0.00897939 kPa | V1-V3; V3 final height missing |
| V1-V2-only RMSE | 0.01098822 kPa | Sensitivity excluding V3 |
| All-validation RMSE | 0.02029445 kPa | Seven trials, including zeros |
| Zero-pressure mean spread | 0.07064438 kPa | Range of Z0-Z3 means |
| P6 zero-check prediction | +0.00364341 kPa | Excluded from regression |

All six previous headline values agree at their stated precision. The maintained method and supplied main script give identical values for those six metrics in the original-method comparison. R squared is not percentage accuracy; these RMSE values are not certified accuracy or complete uncertainty specifications.

## Verification performed

Both R entry points ran in clean sessions, including invocation from a different working folder with an explicit root path. A complete isolated copy also reproduced the analysis and figures and passed the package integrity checker after relocation. The R test script passed 13 checks. The standard-library package checker passed 46 checks covering data/figure hashes, file exclusions, private-path checks, image metadata and attribution. Additional checks verified the unchanged source folder, a minimal firmware sanitization difference, screenshot pixel preservation, local links, original-credential absence and report structure. See [verification record](../results/verification_record.json) and [check results](../results/verification_checks.txt).

The full sanitized firmware compiled successfully using Arduino CLI 1.5.1, ESP32 core 3.3.12 and HX710AB 0.3.1. It was not uploaded. The build target is recorded with its memory summary. These are recovered packaging-time dependencies, not proven versions for the historical recordings.

The report was exported through Microsoft Word, including its table of contents and native equations, then rendered to page images using Poppler through the supplied document-rendering helper. LibreOffice was unavailable, so native Word provided the PDF conversion. All 32 rendered pages were visually reviewed, including the landscape requirements tables, mathematical notation and figure labels. No clipped text, overlapping labels, empty pages or broken tables remained after correction. Page images are internal review material and are not included in the package.

## Missing information and limits

The exact pressure-transducer identity and verified rating, tubing bore/material, water temperature and composition, reference-scale uncertainty, leak rate, settling time and calendar acquisition timing remain undocumented. The original acquisition sketch/build settings and software versions are not established. V3's final water height was not recorded; other endpoint heights are not separately logged in the supplied evidence. No missing measurement is imputed.

The homemade U-tube is an approximate, nontraceable reference. Time-dependent raw behavior, pressure-time confounding, four-zero variation, limited range and few independent trials constrain interpretation. No live endpoint retest, final five-column export, timeout/full-buffer run, network-load timing test or dynamic response measurement was performed during documentation. Dashboard operation is experimenter-confirmed and supported by supplied screenshots.

The extra tablet photograph, supplementary video and interactive R history remain local and are excluded from distribution. Their inventory entries explain why. The source folder is unchanged. The public package contains no original network name/password, private configuration, absolute user-data path, compiler product or original credential-bearing sketch. Rotate the previously exposed hotspot credentials; that owner action has not been performed by packaging.

## Publication decisions

Author attribution is **Rafael Patrick Przydzimirski**, with the user-specified profile **https://github.com/rafaelprzy**. The inspected integration identifies **rafaeldatafusion**; authorization for the intended account must be resolved before a remote write. Review the files and licenses, then explicitly authorize a private repository if desired. Public visibility and the proposed `v1.0.0` release require separate explicit approval. No release date, repository URL or DOI is fabricated in the citation.

The complete [publication checklist](publication_checklist.md) distinguishes completed package checks from owner actions and unexecuted physical checks. These limits do not prevent the project from being documented as completed educational experimental work.
