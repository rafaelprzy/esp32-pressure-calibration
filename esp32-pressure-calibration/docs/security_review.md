# Publication security review

The supplied sketch contained a hotspot name and password in plaintext. They are absent from the public sketch; only an ignored `config.h` should contain local details. The example uses obvious placeholders. Rotate the previously exposed hotspot credentials at their source before further use. Packaging does not rotate them automatically.

The public package excludes interactive `.Rhistory`, the extra tablet photograph containing a browser profile/private network address and reflections, and the 119.7 MB supplementary video. The video is not needed for analysis and has not received an audiovisual privacy review. Both apparatus-photo derivatives have their metadata removed. Both dashboard PNG derivatives retain the screenshot pixels while dropping metadata. Original scientific PNGs are preserved unchanged after metadata inspection.

The complete source folder remains local and unchanged. Source hashes and relative file names are recorded in the inventory. Absolute machine-specific paths are removed from maintained scripts and historical public script copies. No original credential-bearing firmware, local configuration, compiler binary, build directory or Git history is included in the distribution.

The included apparatus photographs were visually reviewed. A hand and nonidentifying background remain; the chosen two images show no visible password, private browser account or private address. No claim is made that inspection can guarantee absence of every possible identifier. The owner should review the exact supplied report and photographs before public release.

License scope is MIT for original software and CC BY 4.0 for original non-code material. External libraries are referenced rather than vendored. The report and citation use the owner's confirmed name and GitHub profile. No institution, supervisor, approval or affiliation is invented.
