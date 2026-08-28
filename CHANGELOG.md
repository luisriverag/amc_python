# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), adapted for a
project that has not yet made a tagged release: everything currently lands
under **Unreleased**, grouped by when it was added rather than by version.
This project intends to follow [Semantic Versioning](https://semver.org/)
starting from its first tagged release.

Entries here describe *what changed*, for someone deciding whether to update
or what to test. They are not a substitute for `docs/PORT_AUDIT.md` (evidence
and confidence per subsystem), `docs/compatibility.md` (status per format),
or `docs/decisions.md` (why a choice was made) — link to those for detail
rather than repeating it here.

## [Unreleased]

### Added

- Desktop GUI: a fourth main-window layout (**HTML**) renders the selected
  movie live through a user-chosen Individual template, matching upstream's
  own main window. Adopted `tkinterweb` as this port's second dependency
  (see ADR-0009 in `docs/decisions.md`) after confirming it ships prebuilt
  wheels for Linux/Windows/macOS. **Tools → Choose HTML Preview
  Template...** sets the template file, persisted in `GuiPreferences.
  html_preview_template`.

### Changed

- Desktop **Export** action's Ant Movie Catalog HTML-template path: replaced
  three sequential blocking file dialogs (full-catalog template,
  individual-movie template, individual-pages folder) with one dialog
  presenting both as independently enabled sections — matching upstream's
  own Export screen's separate "Full"/"Individual" templates — each with
  its own template picker, plus upfront validation instead of silently
  doing nothing on a blank selection.

### Fixed

- Native `.amc` reader/writer: a `List`-type custom field previously
  crashed `read_native_catalog` outright (`CorruptCatalogError: invalid
  native string length`) for the whole catalog. `_read_custom_field`
  compared `field_type` against the bare string `"list"`, but upstream
  writes the literal Pascal enum identifier `"ftList"` (confirmed in the
  checked-in Delphi source); the mismatch skipped the list-value section
  entirely and corrupted every later byte offset. The writer had the
  mirror-image bug, silently dropping list values instead of writing them.
  Found from AMC's own official demo catalog. See `docs/PORT_AUDIT.md`
  finding 39.
- Native `.amc` reader/writer: `year`, `length`, `video_bitrate`,
  `audio_bitrate`, and `media_count` (upstream's `Disks`) now round-trip
  upstream's own `-1` "no value" sentinel as `None`, instead of the reader
  silently passing through the literal integer `-1` and the writer
  silently writing `0` for an unset field. Found from genuine AMC
  3.5/4.1/4.2 catalogs; confirmed against the checked-in Delphi source's
  own `TMovie.Reset`. See `docs/PORT_AUDIT.md` finding 38.

### Added

- `tests/fixtures/native-sample-catalog/`: genuine, redistribution-cleared
  populated-catalog native fixtures — AMC's own official bundled
  seven-movie demo catalog from genuine 3.5.1 and 4.2.0 installs, with all
  eight represented custom-field types, embedded pictures, and
  supplementary records, plus a provenance manifest. This port's first
  genuine evidence for populated movies, custom fields, and embedded
  pictures in native format. See `docs/PORT_AUDIT.md` finding 39.
- `tests/fixtures/native-empty-one-movie/`: this port's first
  `upstream-generated`-origin native fixtures — genuine empty (3.5/4.1/4.2)
  and one-movie (4.1/4.2) AMC catalogs, with a provenance manifest.

---

This project has not made a tagged release. The entries below the divider
are the current baseline as of this changelog's introduction, not a claim
that any of it shipped as a version. Add new entries above this note as
future changes land; do not rewrite this baseline retroactively.

### Added

- Command-line interface (`amc`) covering catalog CRUD, search, sort,
  renumber, merge, loans (single/batch, with media-label and
  retained-native-number grouping), managed borrowers, backup/restore,
  statistics, duplicate detection, media import, picture link/embed/crop/
  clear/export (single and atomic batch), legacy script metadata inspection
  and configuration, and OMDb-backed IMDb lookup/update (`imdb-lookup`).
- Desktop GUI (`amc-gui`, Tk) with table/details/poster layouts, a full
  menu bar and matching toolbar/context menu, undo/redo, checked/loan
  filters, interactive drag-to-select picture cropping, batch picture
  set/assign/clear, an Import Media workflow, upstream `$$TAG_NAME` HTML
  template export, a Preferences dialog, and a **Movie / Update from
  IMDb...** dialog sharing the CLI's preview-then-apply OMDb contract.
- Read-only web interface (`amc-web`) with a responsive table/poster
  gallery, search, pagination, and safe external-link handling.
- Internal JSON v1 catalog format: the project's own persistence format,
  with strict envelope/schema validation, atomic writes, and BOM tolerance
  on read.
- Interchange support: AMC-compatible XML read/write, CSV read/write with
  AMC and Python field-name aliases, static escaped HTML export, and an
  experimental, source-derived AMC 4.2 native binary reader/writer (see
  `docs/compatibility.md` — native format compatibility is not yet
  upstream-verified; see ADR-0001 in `docs/decisions.md`).
- `amc.application.CatalogService`: the one shared, failure-atomic
  application boundary behind the CLI and GUI (see ADR-0002).
- Non-executing legacy "Get Info" script metadata inspection
  (`amc.scripts`) — permissions, options, parameters, static names — with
  no IFPS execution (see ADR-0005); a first-party OMDb IMDb-lookup/update
  provider (`amc.omdb`) covering the two most-used script use cases
  instead.
- Bounded, dependency-free media analysis (`amc.media`) for portable file
  facts plus PCM WAV/FLAC/AIFF/MP3/MP4/OGG duration and bitrate.
- Fixture provenance infrastructure: `tests/fixtures/`'s manifest schema,
  `tools/validate_fixtures.py`, `tools/verify_fixtures.py`, real
  redistribution-cleared script fixtures, and a hand-authored synthetic
  native/XML edge-case fixture pair (see ADR-0001).
- Engineering baseline: `tools/check.py` (the one canonical local check —
  Ruff lint, Ruff format, mypy, the full test suite with branch-coverage
  floor, bytecode compilation, fixture validation, license-inventory
  validation, native-fixture verification, and a CLI smoke check) and
  `tools/check_package.py` (isolated sdist/wheel build and install);
  `tests/` split into `unit/`, `integration/`, `compatibility/`, `cli/`,
  `gui/`, and `tooling/` (see ADR-0007); `mypy` adopted in default mode
  (see ADR-0008); `ruff format` adopted as the canonical formatter
  (line length 100); Linux and Windows CI across four supported Python
  versions.

[Unreleased]: https://github.com/luisriverag/amc_python
