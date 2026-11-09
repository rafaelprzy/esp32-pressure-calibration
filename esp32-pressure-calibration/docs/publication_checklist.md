# Publication readiness checklist

## Completed package checks

- [x] Fourteen raw CSVs copied without changing their bytes; SHA256 checks recorded.
- [x] Six original scientific figures preserved and six publication figures regenerated from existing data.
- [x] Trial-level calibration, P6 holdout, validation chronology and actual V1 reference retained.
- [x] V3 missing final height stated; V1-V2 sensitivity result supplied.
- [x] Zero-pressure variation and all-validation RMSE retained in the main results.
- [x] Base-R scripts run from clean sessions; original-method numerical parity checked.
- [x] Sanitized final firmware compiled with placeholder configuration; no hardware upload.
- [x] Credential declarations moved out of public sketch; local secrets and build products excluded.
- [x] Hardware, wiring, procedure, dictionary, architecture, requirements and portfolio materials supplied.
- [x] Editable report and visually reviewed PDF prepared; final page-review result recorded in final review.
- [x] Conventional license scope and citation metadata prepared using the confirmed author name.

## Owner decisions before any GitHub write

- [ ] Review the report, images, limitation statements and reuse licenses in this exact package.
- [ ] Rotate the previously plaintext Wi-Fi credentials. This is an owner action, not a packaging test.
- [ ] Connect/authorize the intended GitHub account **rafaelprzy**. The integration inspected during packaging identified **rafaeldatafusion**. Account ownership or access equivalence was not assumed.
- [ ] Explicitly authorize creation or population of a **private** repository under the intended owner.
- [ ] Confirm the proposed repository name `esp32-pressure-calibration` and inspect its private contents after upload.
- [ ] Give separate explicit approval before changing visibility to public.
- [ ] After final review, approve creation of release `v1.0.0`, labeled **Educational experimental prototype**. Add the actual repository/release URL and release date to citation metadata only after they exist.

## Known limits that do not block documentation completion

- Exact pressure-transducer identity and verified manufacturer range are not recovered.
- V3 has no final water height; other endpoint heights are not separately logged in the supplied evidence.
- Reference uncertainty, water temperature, leak rate and original build versions remain undocumented.
- Hardware uploads, final five-column CSV export, timeout behavior, full-buffer operation and HTTP-load timing were not retested.
- Existing videos and the excluded extra photo remain local; including them later requires a privacy and size review.

No repository, remote commit, public visibility change or release has been created. The ZIP can be uploaded manually if preferred, after owner review and authorization.
