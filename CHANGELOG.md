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

- Field-scoped search, matching upstream's own search bar:
  `Catalog.search` accepts `field` (restrict to one movie field),
  `whole_field` (exact match instead of substring), and `reverse`
  (movies that do *not* match). The desktop search bar gained a
  **Search in field** dropdown, **Whole field only**, and **Reverse
  results** controls; the CLI's `search` command gained matching
  `--field`/`--whole-field`/`--reverse` flags.
- Desktop GUI: **Previous Movie**/**Next Movie** (`Ctrl+PageUp`/
  `Ctrl+PageDown`, and a new **Movie** menu entry pair) step the table
  selection by one row, matching upstream's own navigation actions —
  including its no-wraparound behavior at either end.
- Desktop GUI: a **Help** menu with an **About AMC Python...** dialog
  (version, license, and a link to this project's own repository) —
  upstream has a dedicated Help menu; this port previously had neither.
- Export "Movies to include" scope and export-time sort, matching
  upstream's own Export dialog: every CLI `export-*` command now accepts
  `--scope {all,checked}` and `--sort-by FIELD [--sort-reverse]`; the
  desktop's Export flow opens an **Export options** dialog offering
  All/Selected/Checked/Visible (each with a live count) and the same
  sort/reverse control. Neither the catalog's own movie order nor its
  saved file are touched by an export.
- Depth-limited media-folder discovery through `discover_media(max_depth=...)`,
  CLI `import-media --max-depth`, and the desktop Import Media workflow.
- Optional multi-part media merging for adjacent `CD1`/`CD2`-style files,
  including a bounded configurable disk-tag expression in the CLI.
- Optional linked or embedded poster discovery during media-folder imports,
  preferring same-stem images before a configurable folder-image name.
- Full, deferred, and skipped media-metadata extraction modes in the CLI and
  desktop folder-import workflow.
- A shared default common-video extension set and bounded regex cleanup for
  filename-derived media titles.

- Desktop GUI: a fourth main-window layout (**HTML**) renders the selected
  movie live through a user-chosen Individual template, matching upstream's
  own main window. Adopted `tkinterweb` as this port's second dependency
  (see ADR-0009 in `docs/decisions.md`) after confirming it ships prebuilt
  wheels for Linux/Windows/macOS. **Tools → Choose HTML Preview
  Template...** sets the template file, persisted in `GuiPreferences.
  html_preview_template`.

### Changed

- Desktop Add/Edit Movie dialog: its ~30 fields are now grouped into named
  sections (Identification, Classification, Cast & Crew, Description,
  Technical Details) instead of one long flat list, matching upstream's own
  grouped, multi-field-per-row Edit Movie layout. Related fields (e.g. Year/
  Length, Video Format/Bitrate/Resolution) pack side by side when the dialog
  is wide (landscape) and reflow to one field per row when it is narrow
  (portrait), so resizing the window between the two never clips a field.
  Field behavior, validation, and the picture browse/crop/clear/embed
  controls are unchanged.
- Desktop **Export** action's Ant Movie Catalog HTML-template path: replaced
  three sequential blocking file dialogs (full-catalog template,
  individual-movie template, individual-pages folder) with one dialog
  presenting both as independently enabled sections — matching upstream's
  own Export screen's separate "Full"/"Individual" templates — each with
  its own template picker, plus upfront validation instead of silently
  doing nothing on a blank selection.

### Fixed

- Linked pictures in imported AMC catalogs now resolve from subdirectories
  relative to the catalog on every platform, including backslash-separated
  Windows links and case differences when a Windows-authored catalog is opened
  on a case-sensitive filesystem. Moved catalogs also recover an absolute
  Windows link when its catalog-directory suffix still matches, and catalogs
  opened through a symbolic link resolve pictures beside the real `.amc` file.
  If the stored subfolder itself is stale, a bounded fallback accepts a unique
  matching filename below the catalog directory but refuses ambiguous matches.

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
