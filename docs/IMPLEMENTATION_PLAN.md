# Implementation plan

This is the execution plan for turning the current prototype into a source-driven
port. Work is split into small, testable vertical slices. A checkbox may be marked
complete only when its tests, documentation, and compatibility evidence are merged.

## Definition of done

Completed foundation: domain construction now uses one validation path for direct
Python calls and decoded JSON, rejects ambiguous primitive values, and copies
caller-owned custom-field mappings.

Every feature change must include:

1. A reference to the relevant upstream unit, format description, or observed
   behavior in `docs/upstream/source-inventory.md`.
2. A failing test written before, or in the same commit as, the implementation.
3. Happy-path, malformed-input, boundary, and round-trip tests where applicable.
4. An update to `docs/compatibility.md`.
5. User-facing documentation for observable behavior.
6. No unexplained data loss. Unsupported data must produce a diagnostic or be
   retained opaquely.

## Execution priority: downstream features while fixtures are unavailable

Milestone 0 and the P0 evidence gate below require running the genuine,
licensed Ant Movie Catalog Windows application to produce upstream-generated
catalogs. That application cannot be installed or executed in this
repository's automated development environment, so fixture acquisition is
**externally blocked** rather than a coding gap: it can only proceed when a
contributor with a real AMC 4.2.3.2 installation supplies fixtures and their
provenance records. This does not relax the compatibility bar. It remains
true, unchanged, that no native/XML/CSV subsystem may be marked
`verified` — and no format-compatibility checkbox in this document may be
checked — without registered upstream-generated evidence.

Given that block, day-to-day execution focuses on **downstream
features**: Milestone 5 (application services and interfaces) and
Milestone 6 (scripts, metadata, and media) items that improve
`CatalogService`, the CLI, the desktop GUI, and the web interface without
making any upstream-compatibility claim. These items are evidence-independent
because they describe AMC Python's own contract, not Ant Movie Catalog's.
Each still needs the full "definition of done" above (tests, documentation,
a `docs/compatibility.md` update when it changes a status row) — only the
upstream-unit citation is inapplicable to purely Python-owned behavior.

This reprioritization changes execution order, not the milestone list or
the evidence bar: Milestones 5 and 6 already existed and their gates are
unchanged. When genuine fixtures become available, work reverts to the P1–P3
sequence below before any new compatibility claim is made.

Within the downstream track, **quick wins are the current priority**: D0–D5
(media analysis, picture workflow, bulk-operation UX, GUI/catalog
preferences, engineering debt, GUI parity) are now complete or reduced to
items that are either genuinely blocked (screen-reader verification has no
assistive technology available to test against) or explicitly optional
polish, not tracked gaps. D6's four subsystems were not one uniform backlog:
MP3/MP4/OGG duration/bitrate turned out tractable in small, bounded
increments and are done; localization and printing/reports turned out to be
scoping decisions, not implementation gaps, and are now decided — localization
because there is no translated content to load yet (revisit when there is,
not a permanent no), printing/reports because FreeReport is a standalone
report-designer-sized port disproportionate to this project regardless of
its now-resolved license (permanent no; HTML template export already covers
the underlying need). General website script execution is now also decided:
accepted ADR-0005 excludes an in-process IFPS compiler/VM because arbitrary
third-party bytecode is outside this application's trust boundary. What
was built instead, once asked which legacy scripts actually
mattered: a narrower, first-party alternative (`amc.omdb`, CLI
`imdb-lookup`, and now the desktop GUI's **Movie / Update from IMDb...**
dialog) for the two named highest-value cases — refreshing existing
entries and IMDb lookups — via the OMDb API instead of any script
execution at all. This closes D6's final security/scoping decision. Execution
continues to prioritize any remaining small, bounded, well-scoped item in the
gated compatibility/release backlog rather than open-ended subsystem
construction. This is still
evidence-independent — Python-owned behavior and
test coverage, not an upstream-compatibility claim — so none of it needs a
fixture or is blocked by Milestone 0.

The concrete, ordered form of the wider backlog is the **Downstream execution
backlog (D0–D6)** further down this document, alongside the upstream P0–P3
backlog it runs in parallel with.

## Milestone 0: authoritative upstream baseline

- [ ] Reacquire `amc_sources.rar` and record URL, retrieval date, byte size, and
  SHA-256 digest. The contributor-supplied archive, reported source page, size,
  digest, and commit date are now recorded; its precise download time is unknown.
- [x] Add a streaming acquisition, extraction, checksum, and inventory tool.
- [x] Add deterministic acquired-tree versus checked-in-snapshot comparison
  reporting; the two supplied archives match all 952 expanded files exactly.
- [x] Make both supplied archive layouts reproducible in the acquisition tool:
  safe built-in ZIP extraction and optional single-wrapper-directory stripping.
- [x] Support pre-installation verification against an independently supplied
  archive SHA-256; no authoritative published digest has yet been located.
- [ ] Confirm snapshot/archive equivalence and complete application/dependency
  license review (archive/tree equality is verified and the retained `Common` and
  `antcomponents` files now have a check-enforced per-file inventory; ElTree and
  the unlicensed `ComboBoxAutoWidth.pas` remain blockers).
- [ ] Add the applicable license and attribution files (root GPLv2 text and an
  initial notice inventory are present; ElTree redistribution and the absent
  `ComboBoxAutoWidth.pas` license grant remain blockers).
- [ ] Inventory every source unit, form, resource, script, and file
  format (952 files counted; initial subsystem map recorded).
- [ ] Map each unit to a Python subsystem or an explicit omission
  (priority units only mapped).
- [ ] Generate reference catalogs using each supported AMC release.

**Gate:** no code may be called a port of an upstream subsystem until its source
unit and compatibility evidence are recorded.

## Milestone 1: engineering baseline

- [x] Split tests into `unit`, `integration`, `compatibility`, `cli`, and `gui`
  (plus `tooling` for the repository tool self-tests); see the P3 item below for
  how the one large mixed-concern file was divided.
- [x] Configure Linux and Windows CI for all supported Python versions; hosted run
  verification remains pending.
- [x] Add formatting, linting, static typing, and coverage (Ruff formatting and
  focused linting, mypy in its default non-strict mode, and an 80% branch-
  coverage floor now run in the canonical command and CI. Canonical
  commands also cover tests, compilation, diff validation, wheel building,
  isolated installation, and source-tree and installed-module CLI smoke checks).
  Adopting mypy found and fixed several real, pre-existing issues rather than
  just satisfied the checker: two reused-loop/local-variable-name collisions in
  `cli.py` and `native.py` that happened to hold unrelated types (harmless at
  runtime since Python has no per-block scoping, but genuinely confusing and
  fragile); a `self.location` GUI attribute silently shadowing `tkinter`'s
  inherited `Grid.location` method; and a native-format `NativeExtra`
  constructor call relying on an unchecked fixed-length list splat. See
  `docs/PORT_AUDIT.md` finding 37.
- [x] Establish and automatically validate the fixture provenance manifest contract;
  genuine upstream fixtures still need to be produced and registered.
- [x] Add a changelog and architecture-decision log: `CHANGELOG.md`
  (Keep a Changelog format, seeded with the current capability baseline
  since this project has never made a tagged release) and `docs/decisions.md`
  (eight ADRs formalizing decisions already made informally across this
  document, `docs/architecture.md`, and `docs/PORT_AUDIT.md`; ADR-0005 now
  records the accepted boundary against in-process IFPS execution).
- [x] Specify internal JSON v1 and test failed-write destination preservation for
  JSON, CSV, and XML serialization failures.

**Gate:** all checks run from a single documented command and in CI.

## Milestone 2: native AMC read support

- [ ] Identify the native signature, header, versions, encodings, record framing,
  checksums, compression, and picture representation.
- [ ] Add empty, one-record, all-fields, Unicode, picture, and corrupt fixtures.
  Empty, one-record, all-fields, custom-field, and picture are done
  (`tests/fixtures/native-empty-one-movie/`: genuine 3.5/4.1/4.2 empty
  catalogs and 4.1/4.2 one-movie catalogs, this port's first
  `upstream-generated` native fixtures — see `docs/PORT_AUDIT.md`
  finding 38; `tests/fixtures/native-sample-catalog/`: genuine 3.5/4.2
  populated catalogs with all eight represented custom-field types and
  embedded pictures — see finding 39). Unicode/code-page and corrupt
  fixtures remain.
- [x] Implement source-derived native 1.0–4.2 header detection and read-only record
  parsing; compatibility verification remains blocked on genuine fixtures.
- [x] Add explicit, atomic source-derived AMC 4.2 export with synthetic round-trip
  coverage; upstream acceptance and byte-level compatibility remain unverified.
  A genuine native catalog contributed by a user for local debugging (not
  committed to the repository) round-tripped cleanly after fixing a real
  encode/decode asymmetry the synthetic-only coverage had missed — see
  `docs/PORT_AUDIT.md` finding 34. Not upgraded to verified: no
  provenance-tracked fixture is registered in the repository. A
  hand-authored `synthetic`-origin native+XML fixture pair informed by that
  finding is registered at `tests/fixtures/edge-cases/` (finding 35) as a
  committed regression guard; it does not substitute for the
  upstream-generated fixtures the unchecked item above still needs.
- [x] Add format-neutral `amc inspect` and `amc validate`; modern native validation
  parses structure but reports unverified status rather than claiming compatibility.
- [ ] Parse catalog metadata, movie records, custom fields, and pictures (read-only
  owner/mail/site/description parsing is complete for versions 3.1–4.2, and
  custom-field definition parsing for versions 4.0–4.2, and movie-row parsing for
  versions 3.1–4.2, including 4.2 supplementary records; generic/CLI read-only
  import is wired with header-based detection, catalog metadata, and embedded bytes
  retained in JSON).
  Pre-3.0 external picture names and `.amcl` borrower assignments are now loaded
  from the sidecars used by upstream; genuine legacy fixture verification remains
  pending.
- [ ] Cross-check native parsing against XML produced by upstream AMC.

**Gate:** supported `.amc` files can be converted without the original program and
all omitted or opaque data is reported.

## Milestone 3: lossless interchange

- [ ] Replace synthetic XML/CSV assumptions with upstream-generated fixtures.
- [ ] Model all known catalog and movie fields (AMC 4.2 writer, composer,
  certification, file path, user rating, and color tag are typed across
  native/JSON/XML/CSV and desktop editing; catalog properties and custom-field
  definitions are retained for native and XML inputs, while the remaining upstream
  fields still need typed coverage).
- [ ] Preserve duplicate custom fields, ordering, types, and attributes.
- [ ] Verify Python XML output by importing it into upstream AMC.
- [x] Add configurable movie collision policies: `error`, `skip`, `replace`, and
  `renumber`; metadata supports `error`, `keep`, `replace`, and `namespace`.
- [ ] Add streaming readers and documented resource limits.

**Gate:** semantic round trips are verified for every supported format/version.

## Milestone 4: native AMC write support

- [ ] Implement version-specific writers behind an experimental flag (the 4.2
  writer is atomic and now enforces configurable output, movie, picture,
  cumulative encoded-string, custom-field/list-value, and supplementary-record
  budgets; older writers and upstream acceptance remain pending).
- [x] Always back up existing native catalogs before replacement using the
  source-shaped `.bak` name; backup failures preserve the destination.
- [x] Test interrupted serialization, backup copying, and destination replacement;
  each failure preserves the original catalog and cleans temporary files. Native
  backup and catalog renames also fsync their parent directory on POSIX systems.
- [ ] Open, save, and reopen generated files with upstream AMC.
- [ ] Remove the experimental flag only after all compatibility fixtures pass.

## Milestone 5: application services and interfaces

- [ ] Move mutations and persistence policy out of CLI/GUI adapters into services.
- [ ] Add bulk operations (complete validated field editing, atomic backup/restore,
  normalized title/year duplicate detection, JSON output, installed smoke checks,
  and stable exit codes are complete).
- [ ] Add pictures, undo, progress,
  cancellation, and accessibility (service-backed open/save-as, merge import,
  validated backup/restore, basic XML/CSV/HTML/AMC export, single-movie loan
  controls, loan/checked view filters, validated editing of every modeled scalar
  field, read-only detail review, statistics, duplicate review, and confirmed
  renumbering are complete;
  linked/size-bounded embedded picture set/clear/export, validated cropping, and
  native retention are complete; unverified native export is confirmation-gated
  and reports its replacement backup; native/XML/CSV sources are protected as
  read-only until saved as JSON; batch picture set/assign/clear across an
  extended table selection is complete from both the CLI (`picture-set-many
  --crop`/`--crop-for`) and the desktop toolbar (Set/Assign/Clear Pictures),
  covering a shared picture across the selection, a distinct picture per
  movie, and clearing; interactive drag-to-select crop is complete for both
  the single-movie edit dialog and each row of the batch Assign Pictures
  dialog; progress, cancellation, and accessibility remain pending; every
  mutation persists immediately, so there
  is no unsaved dirty state left to prompt about).
- [ ] Add loan management and catalog preferences if confirmed upstream features
  (atomic single/multi-movie check-out/check-in and validated JSON-retained loan
  history, managed borrower lists, and source-shaped TSV history export are
  implemented; opt-in media-label and retained-native-number grouping are
  implemented, while upstream verification and catalog preferences remain pending).

## Milestone 6: scripts, metadata, and media

- [ ] Inventory the complete upstream scripting API and decide execution boundaries
  (bounded, non-executing `.ifs` Infos/Options/Parameters, mutation permissions,
  and static-variable-name discovery is implemented without exposing static values;
  case-insensitive option/parameter configuration and atomic AMC Python JSON public
  settings are implemented, but they do not reproduce upstream's INI cache, license
  acceptance, static state, compiler, or runtime).
- [ ] Define a provider interface with timeouts, caching, rate limits, and safe
  field-level merge previews (isolated validated previews now enforce script-declared
  movie, picture, and extra-field permissions; execution, timeouts, caching, and
  rate limits remain intentionally absent).
- [ ] Add image download and full media-file analysis as optional capabilities
  (portable file facts and dependency-free PCM WAV/FLAC/AIFF/MP3/MP4/OGG
  duration and bitrate are available; MP3 comes from the first MPEG audio
  frame header and file size, exact for CBR and approximate for VBR files
  without a parsed Xing/VBRI header; MP4 comes from the `moov/mvhd` box
  (movie-level duration only, no per-codec bitrate) and OGG from the Vorbis
  identification header plus the stream's last granule position — both
  averaging bitrate over the whole file the same way MP3's VBR case does.
  Video-track resolution, framerate, and real codec name still need an
  optional codec provider; image download is still unimplemented).
- [ ] Use recorded responses in tests; live network tests must be opt-in.
- [x] Reproduce upstream HTML template/tag semantics: `amc.html_template`
  renders real AMC `$$TAG_NAME` HTML export templates (see D6 below); safe
  static HTML table export remains available as a non-compatible baseline.

## Milestone 7: release

- [ ] Complete package metadata, licenses, attribution, migration, backup, and
  recovery documentation.
- [ ] Build and install wheels and source distributions in clean environments
  (the package check now builds and inspects an sdist, rejects retained historical
  evidence trees, and installs/smoke-tests the wheel; clean OS/Python matrix runs
  remain pending).
- [ ] Produce cross-platform release artifacts and a compatibility report.
- [ ] Complete performance, fuzz, corrupt-input, and large-catalog testing.

## Prioritized execution backlog

The code review identified a gap between **implemented from source** and **verified
against upstream output**. Work must proceed in this order; later phases do not
unblock earlier evidence gates.

### P0 — establish trustworthy evidence

1. Reacquire and checksum the published source archive; compare its deterministic
   inventory with both checked-in source trees.
2. Resolve the ElTree source-redistribution blocker and the absent license grant
   for `Common/ComboBoxAutoWidth.pas`; the check-enforced `Common` and
   `antcomponents` per-file inventory, root-level GPLv2, and initial attribution
   files are now present.
3. Generate AMC 4.2.3.2 empty, one-movie, all-fields, custom-field, embedded-picture,
   linked-picture, supplementary-record, Unicode/code-page, and corrupt catalogs.
   [Partial] Empty and one-movie catalogs are done, across AMC 3.5.x/4.1.x/4.2.x
   (not confirmed as specifically 4.2.3.2) — see `docs/PORT_AUDIT.md` finding 38.
   All-fields, custom-field, embedded-picture, and supplementary-record catalogs
   are also done, across AMC 3.5.1/4.2.0 (`tests/fixtures/native-sample-catalog/`,
   AMC's own bundled demo catalog — see finding 39). Linked-picture,
   Unicode/code-page, and corrupt catalogs remain.
4. Record producer version, creation steps, SHA-256, expected contents, mutations,
   and redistribution permission for every fixture. [Done for the fixtures generated
   so far] — `tests/fixtures/native-empty-one-movie/manifest.json`,
   `tests/fixtures/native-sample-catalog/manifest.json`.

**Exit criterion:** the checked-in source and first compatibility fixture set have
reviewable provenance. Until then, native support stays **investigating**.

### P1 — verify and harden the native reader

1. Cross-check every parsed 4.2 field and byte offset against fixtures and upstream
   XML exports; then repeat for one fixture per claimed older version.
2. Determine encoding from upstream behavior instead of treating CP-1252 as a
   universal default; CLI native import now accepts an explicit codec, but automatic
   locale behavior and genuine undecodable-byte coverage remain pending.
3. [Partial] Strictly reject truncated final records instead of copying upstream's
   silent stop; exhaustive byte-boundary truncation tests cover an empty 4.2 catalog
   and populated records for 1.0, 1.1, 2.1, 3.0, and 4.2. Repeat with genuine
   fixtures.
4. [Partial] Synthetic AMC 4.2 coverage preserves native-only scalar values,
   custom-field definitions/values, embedded images, and supplementary records
   through native → JSON → JSON without normalization loss. Unparseable framerate
   and file-size text and negative native movie numbers are retained opaquely rather
   than discarded; repeat with genuine fixtures before claiming compatibility.
5. [Partial] File size, movie, picture, string, custom-field/list-value, and
   supplementary-record limits are implemented, and native CLI import exposes each
   applicable parser budget. Exhaustive 4.2 truncation checks
   cover parser termination and bounded offsets; a deterministic byte-mutation
   corpus checks bounded public outcomes, while property-framework and genuine
   fixture mutation coverage remain pending.
6. Split `native.py` into header, primitive, metadata, and record modules only after
   fixture-backed boundaries are stable.

**Exit criterion:** supported fixtures convert deterministically, corrupt fixtures
fail with documented diagnostics and offsets, and no supported bytes disappear.

### P2 — make interchange semantics explicit

1. Replace synthetic XML/CSV assumptions with upstream-generated exports.
2. Introduce format-neutral catalog-property, custom-field-definition, picture, and
   supplementary-record models; stop using reserved `extras`/`metadata` keys as the
   long-term typed representation.
3. Preserve duplicate custom fields, order, types, attributes, and unknown nested XML
   opaquely; all native custom values are now retained in an ordered fallback list,
   protecting duplicates and reserved-key collisions, while the general typed model
   and XML behavior remain pending.
4. [Implemented internally] Metadata merge policies (`error`, `keep`, `replace`,
   `namespace`) and movie collision policies (`error`, `skip`, `replace`,
   `renumber`) are validated, deep-copied, atomic, and exposed by the CLI; verify
   them against genuine interchange fixtures.
5. Verify Python XML output by opening and resaving it with upstream AMC.

**Exit criterion:** documented semantic round trips pass for native, XML, and JSON;
CSV has explicitly documented lossy boundaries.

The internal JSON v1 boundary now validates envelope discriminator types and each
indexed movie object, rejects duplicate object members and non-standard non-finite
numbers, and validates/deep-copies movie extras. This closes the schema-validation
gap for the Python-owned format; it is not evidence for an upstream format.

### P3 — engineering and release gates

1. [Done] `tests/` is split into `unit/`, `integration/`, `compatibility/`, `cli/`,
   `gui/`, and (one category beyond the four named here) `tooling/` for the
   `tools/*.py` self-tests and repository-consistency checks that don't fit any of
   the other five. `tests/test_amc.py`, a single 1276-line file mixing storage
   round-trip and CLI end-to-end tests, was split along its clean `test_cli_*`
   naming boundary into `tests/cli/test_cli.py` (39 tests) and
   `tests/compatibility/test_storage.py` (44 tests); every other file moved
   wholesale by its dominant concern, including a few files that keep one or two
   incidental CLI smoke checks alongside their primary subject rather than
   fragmenting further for marginal benefit. `pytest`'s recursive `testpaths`
   discovery needed no configuration change; three `Path(__file__)`-relative
   fixture/repo-root lookups were updated for the extra directory level. One
   canonical local check command (`tools/check.py`) already existed before this
   split and is unaffected by it.
2. [Partial] `mypy` (default, non-strict mode; configured in `pyproject.toml`'s
   `[tool.mypy]`) now runs in `tools/check.py` and both CI matrices alongside the
   linter, coverage threshold, wheel/sdist build, clean install, and subprocess
   CLI smoke tests already there. A formatter remains pending.
3. [Partial] A shared application service now owns GUI open/reload and
   failure-atomic add/replace/remove, batch media import, catalog merge, sort, and
   renumber persistence, interchange conversion, export, and validated
   backup/restore; the CLI uses it for those workflows. Separate storage
   dispatch/codecs behind repository interfaces.
4. Add performance, concurrency, permission, durability, and large-catalog tests.
5. Keep native writing disabled until upstream open/save/reopen tests pass and backup
   and interrupted-write behavior is proven.

## Downstream execution backlog (D0–D6)

While Sprint 1 (below) stays externally blocked on genuine fixtures, this is
the ordered, concrete backlog for the "Execution priority" track above. Unlike
P0–P3, items here carry no fixture dependency and no ordering gate between
tiers — pick the next unchecked item in the lowest tier with unchecked work.
Each item still needs its own tests and a `docs/compatibility.md` update per
the "definition of done." These are sub-items of the Milestone 5/6 checklist
entries above, not new top-level checklist entries, so they intentionally use
indented, non-canonical checkbox markers that the port-progress count in
`README.md` does not scan.

### D0 — media analysis completeness

  - [x] Dependency-free PCM WAV duration/bitrate.
  - [x] Dependency-free FLAC duration/average bitrate, parsed from the
    mandatory leading STREAMINFO metadata block.
  - [x] Evaluated further fixed-header formats versus a codec-provider
    interface: fixed-header IFF/RIFF-style formats are worth continued
    dependency-free support because their headers are small, fully
    documented, and bounded to parse, the same properties that made WAV and
    FLAC tractable. Added dependency-free AIFF/AIFF-C duration and bitrate
    (COMM chunk, including manual 80-bit extended-float sample-rate
    decoding, since the stdlib `aifc` module is deprecated and removed
    starting in Python 3.13). Compressed/lossy formats (MP3, MP4, OGG, and
    similar) do not share that property — they need either a real decoder or
    frame-by-frame bitstream scanning — so they remain out of scope for
    dependency-free parsing and stay behind the deferred, intentionally
    unimplemented optional bounded codec-provider interface described in the
    compatibility matrix.

D0 is now complete: the remaining media-analysis gap is entirely the
optional codec-provider design for compressed formats, which is deferred
work rather than an open backlog item here. This framing turned out to be
premature for duration/bitrate specifically: D6's "compressed media codecs"
item below later found frame-by-frame/container-walking scanning tractable
without a real decoder after all, for MP3, MP4, and OGG alike — the codec-
provider interface remains deferred only for video/audio codec name,
resolution, and framerate, which do need real decoding.

### D1 — picture workflow completion

  - [x] Atomic batch picture clear across an extended selection (CLI and GUI).
  - [x] Atomic batch picture set — one shared picture across a selection (CLI
    and GUI).
  - [x] Atomic batch picture assignment — a distinct picture per movie in one
    write (CLI `picture-set-many`; GUI **Assign Pictures** dialog).
  - [x] Interactive crop selection (a draggable rectangle over the poster
    preview) in the edit dialog's **Crop** button, replacing the CLI-only
    `--crop X,Y,WIDTH,HEIGHT` numeric entry for the single-movie case.
  - [x] Per-movie crop rectangles in a batch assignment: `CatalogService.
    set_picture_many` accepts a `crops` mapping of movie number to rectangle,
    overriding the shared `crop` for that movie only (validated as
    embed-only, and rejecting crop entries for movie numbers outside the
    assignment set); CLI `picture-set-many --crop-for NUMBER=X,Y,WIDTH,HEIGHT`
    and a per-row **Crop** button in the **Assign Pictures** dialog (reusing
    the edit dialog's interactive selector) expose it.

D1 is now complete: every planned picture set/assign/clear/crop workflow has
both a CLI and a desktop entry point.

### D2 — bulk-operation UX

  - [x] CLI `import-media --progress` prints `Inspected N/TOTAL file(s)` to
    stderr while scanning a large tree, the case explicitly named in this
    item as the one worth it (a directory can hold thousands of files;
    `merge` and batch picture operations are typically a handful of movies
    per call, so they do not get dedicated progress reporting here).
    Explicit cancellation support turned out to be unnecessary to build:
    every `CatalogService` bulk operation already only writes the catalog
    once, after building its complete result, so interrupting any of
    them — Ctrl+C during `import-media`'s scan included — leaves the
    destination catalog completely untouched by construction. This is now a
    documented, tested guarantee (`docs/cli.md`, `unit/test_media.py`) rather
    than an unstated side effect.
  - [x] Added the prerequisite GUI media-import workflow the previous audit
    found missing: a toolbar **Import Media** action asks whether to import
    from a folder (with a recursive-subfolder prompt, using
    `amc.media.discover_media`) or choose individual files, then a modal
    dialog reports which file is being inspected and can be cancelled
    mid-scan, mirroring the CLI's atomic-after-inspection guarantee (nothing
    is added unless every selected/discovered file is inspected without
    cancelling or hitting an error). It does not yet match the CLI's
    `--extensions` filter.
  - [x] Keyboard reachability: every modal dialog now moves initial focus to
    a specific control on open (the title field in Add/Edit, the borrower
    field in Loan Out, the first Browse button in Assign Pictures, the
    Spinbox in Preferences, the Cancel button in the crop and Import Media
    dialogs) instead of leaving focus on the dialog's background, and Import
    Media gained a Ctrl+M shortcut alongside the existing toolbar shortcuts.
  - [x] Real-display smoke coverage: this development container turned out to
    have Xvfb installed, contradicting an earlier "no real display" note in
    this document. `tests/gui/test_gui_display.py` builds genuine Tk widget
    trees (not the `object.__new__`-bypassed, fully-mocked windows the rest
    of `gui/test_gui.py` uses) for the main window and the Preferences, Assign
    Pictures, Import Media, and edit/crop dialogs, including an end-to-end
    simulated drag-select-and-apply crop. `tools/check.py` wraps the test run
    in `xvfb-run` automatically on Linux when available and no `DISPLAY` is
    already set; the tests skip themselves everywhere else (no display, no
    `xvfb-run`, Windows), so this needed no changes to portability guarantees.
    CI's Linux job now installs `xvfb` so it gets this coverage too.
  - [ ] Screen-reader labels and a verified accessibility pass remain open —
    genuinely, not just for lack of a display now. Tk has no meaningful
    AT-SPI bridge on X11 to exercise, and no screen reader is installed in
    this container, so neither the keyboard-focus item above nor the
    real-display smoke tests above are a substitute for this one.

D2's progress/cancellation item, including folder-based GUI import, is now
complete, and real-display smoke coverage closes the "no real-display tests"
gap this document previously described as environment-blocked. A verified
accessibility pass with actual assistive technology remains the only open
item in D2 — that part is still genuinely blocked, unlike the D4 items below.

Comparing `import-media` against upstream's own "Import from another file
format" → Media files dialog (`import2_engines.pas`'s `TImportEngineDir`,
`getmedia.pas`) surfaced real, source-derived gaps this port does not cover
yet:

  - [x] Depth-limited subfolder browsing: upstream's `BrowseDepth` setting
    (`*` for unlimited, else an integer) caps how many directory levels a
    recursive scan descends. `discover_media(max_depth=N)`, CLI
    `import-media --max-depth N`, and the desktop folder-import prompt now
    implement the same bounded-depth choice; zero scans the selected folder
    only and an omitted value leaves recursion unlimited.
  - [x] Multi-part/multi-disk media merging: upstream (`TGetFileListThread.
    Execute`, `getmedia.pas`) sorts filenames per directory and merges
    adjacent files into one movie entry when a configurable "disk tag"
    regex (default `(cd)[0-9]{1,3}`), stripped from both names, produces
    the same result — e.g. `Movie CD1.avi`/`Movie CD2.avi`. The merge
    formulas are traceable in `GetInfoFromMedia`: title/path/label keep the
    first file's value, `length` sums across parts, `video_bitrate`/
    `audio_bitrate` average iteratively (`(previous + new) / 2` per part),
    file size sums, and disk count is the number of parts merged. This
    port now exposes the behavior as opt-in CLI `--merge-parts` (with bounded
    configurable `--disk-tag-regex`) and a desktop folder-import choice. The
    shared merger requires adjacent files in the same directory, preserves
    every source path, keeps the first part's descriptive fields, sums length
    and size, applies the source's iterative bitrate average, and records the
    part count in `media_count`.
  - [x] Pictures importation method: upstream looks for a poster image
    beside each media file or its containing folder (matching filename or
    a configured folder name) and can store it into the catalog or copy it
    to a pictures folder. AMC Python now searches bounded, explicit image
    extensions beside each media file, preferring a same-stem image and then
    a configurable folder-image base name. CLI `--import-pictures link|embed`
    and the desktop folder workflow expose linked or size/pixel-bounded
    embedded storage; every attachment is completed before the catalog's
    single atomic mutation.
  - [x] Extract process modes: upstream can extract full media info
    immediately, defer it, or skip it entirely for a faster scan; this
    port now offers CLI `--extract full|defer|skip` and the same desktop
    folder-import choice. Full preserves the existing codec inspection;
    defer records portable file facts plus an explicit `pending` marker; skip
    avoids metadata extraction and records an explicit `skipped` marker. All
    three modes still resolve the complete batch before the atomic catalog
    mutation.
  - [x] Extensions "Default" button and a configurable filename-cleanup
    pattern ("Filter the file name") for deriving a title from a raw
    filename: `--extensions default` and the desktop prompt's `default`
    keyword select the shared common-video extension set, while bounded CLI
    `--title-filter-regex` and the desktop cleanup prompt remove matching text
    and normalize the resulting title's whitespace/separators.
  - Allow duplicate numbers, allow to clear fields when empty, auto-assign
    fields to columns, and "use internal engine for AVI" are upstream
    settings without a clear equivalent here: the first two only make
    sense for an update-existing-catalog import (this port's import-media
    only adds new movies), the third is upstream's own preview-grid
    column-mapping mechanism (this port has no preview grid — it builds
    `Movie` objects directly), and the fourth toggles upstream's own
    internal-vs-external AVI parser, which has no analog since this port
    only ever has one parser per format. Not tracked as gaps for that
    reason, but noted here for completeness against the screenshot.

### D3 — catalog/GUI preferences

  - [x] Persist Python-owned GUI preferences (last-used view filter, layout,
    window geometry) separately from catalog data, so they are not confused
    with retained upstream catalog properties: the new `amc.preferences`
    module reads/writes an atomic, platform-appropriate per-user JSON file
    (`AMC_PYTHON_CONFIG_DIR` overrides it), validated field-by-field with a
    default fallback rather than an error for any missing/corrupt/invalid
    data. The desktop loads it on startup and saves on every view/layout
    change and on window close.
  - [x] Make the retained undo/redo history depth (`_HISTORY_LIMIT`) and any
    future retention limits configurable instead of a fixed constant:
    `CatalogService.__init__` now takes a validated `history_limit` keyword
    (still defaulting to 100), the desktop passes the loaded/saved
    `GuiPreferences.history_limit` through it, and a toolbar **Preferences**
    dialog lets the value (1–1000) be changed and persisted at runtime.

D3 is now complete: every planned Python-owned preference is persisted
separately from catalog data and editable from the desktop.

### D4 — engineering/quality debt from the port audit

While D0–D3 exhausted the application-feature backlog, `PORT_AUDIT.md`'s
"Design and quality debt" list still names concrete, fixture-independent gaps.
This tier works through those, oldest-numbered first, the same way D0–D3
worked through feature gaps: pick the next unchecked item, fix it, add tests,
update `docs/PORT_AUDIT.md` and `docs/compatibility.md`.

  - [x] Bound `inspect_catalog`/`validate_catalog` file size before JSON/native
    parsing (`--max-input-bytes` on the CLI `inspect`/`validate` commands),
    matching the `NativeReadLimits`/`inspect_media` precedent. True streaming
    JSON record counting remains out of scope (Python's stdlib `json` module
    has no incremental parser). PORT_AUDIT design-debt item 6.
  - [x] Reject duplicate CSV headers (exact-duplicate extras headers, or two
    headers that normalize to the same known movie field) instead of letting
    `csv.DictReader` silently discard one column's data, mirroring the JSON v1
    decoder's duplicate-member rejection. PORT_AUDIT design-debt item 5
    (partial: CSV dialect/locale/empty-value behavior is still undefined from
    upstream evidence).
  - [x] Fsync the destination directory entry after every atomic file
    replacement in the package, not just the file contents. The native `.amc`
    writer already did this; JSON/CSV/XML/HTML saves, `copy_catalog`, picture
    export, TSV loan-history export, GUI preferences, and script settings did
    not, so a crash immediately after rename could still lose the rename on
    some filesystems even though the new file's own bytes were durable.
    `native.py`'s `replace_and_sync_directory` helper is now shared by every
    writer in the package. PORT_AUDIT design-debt item 7.
  - [x] Define and test explicit behavior for a permission-denied or read-only
    destination directory across the atomic writers above: an unwrapped
    `PermissionError`/`OSError` propagates from the temp-file `open()`/`mkdir()`
    call (never wrapped into a `CatalogError`) and leaves any existing
    destination and temp-file state untouched. Verified with injected-failure
    tests (not real `chmod`, since this environment's automated checks run as
    `root`, which does not enforce permission bits) for every `storage.py`
    atomic writer, `copy_catalog`, and the native `.amc` writer.
    PORT_AUDIT design-debt item 7.
  - [x] Make concurrent atomic writers independent. The package previously
    gave every writer targeting a path the same deterministic `.tmp` name, so
    two simultaneous saves could truncate or replace one another's staging
    file before either destination replacement. Text, binary, catalog-copy,
    native-catalog, and native-backup writes now use UUID-qualified temporary
    names in the destination directory and create them exclusively, never
    truncating or cleaning up a staging path they did not create. A forced-name
    collision regression preserves both the other writer's bytes and the old
    destination. A barrier-synchronized regression test
    forces two JSON writers to reach replacement together and verifies that
    the result is one complete catalog with no temporary-file debris.
    PORT_AUDIT design-debt item 7 (now fully resolved).
  - [x] Fix the concrete bug the undocumented error-model split had produced:
    the desktop GUI's ~20 `try`/`except` boundaries around `CatalogService`
    calls were meant to share one expected-failure set, but only 5 of them
    caught `KeyError` (`Catalog.get()`'s documented signal for a movie number
    that no longer exists) alongside `CatalogError`/`OSError`/`TypeError`/
    `ValueError`; the other 15 would have let a stale-selection `KeyError`
    escape as an unhandled Tk callback traceback instead of the usual error
    dialog. All ~20 now share one `gui._SERVICE_ERRORS` tuple; `cli.main()`'s
    equivalent boundary already covered `KeyError` via `LookupError` and is now
    commented to say so. PORT_AUDIT design-debt item 8 (partial).
  - [x] Decide the rest of the error model: whether `ValueError`/`TypeError`/
    `KeyError` call sites in `catalog.py`, `application.py`, and elsewhere
    should migrate to public `CatalogError` subclasses instead of the split
    remaining permanent, then document that decision in `docs/cli.md` or a new
    error-model reference. Decided: the split stays. `docs/architecture.md`'s
    "Error model" section now documents the rule it already followed
    inconsistently-on-paper-but-consistently-in-practice — `CatalogError`
    subclasses for diagnosable catalog-content problems (`.code`/`.offset`
    consumed by `validate_catalog` and the native reader/writer); plain
    `ValueError`/`TypeError` for local API argument-contract violations,
    matching ordinary Python convention; plain `KeyError` for dict-like
    lookup failures (`Catalog.get()`, `remove_borrower`) — and why migrating
    the 60+ built-in-`raise` sites in `catalog.py`/`application.py`/
    `model.py`/`loans.py` would change no CLI or GUI behavior (both already
    catch the whole family in one block: `cli.main()`'s
    `(CatalogError, OSError, TypeError, ValueError, LookupError)`, `gui.py`'s
    `_SERVICE_ERRORS`), only make direct-API argument validation less
    idiomatic for a future non-CLI, non-GUI consumer. PORT_AUDIT design-debt
    item 8 (now fully resolved).

### D5 — GUI parity

The general engineering-debt sweep in D4 is far enough along that GUI parity —
closing the desktop GUI's own gaps against its documented contract, ahead of
further D4 items — became the priority within the downstream track. D5 is now
done: every item below is either checked or, for the one that isn't
(accessibility verification), genuinely blocked on assistive technology this
environment does not have, not on further coding. The current priority within
the downstream track has moved to D6's remaining unblocked item (the Export
dialog's picture-copying/SQL/Pictures-export gap — see below).

  - [x] Real-display smoke coverage. This development container turned out to
    have Xvfb installed, contradicting an earlier "no real display" note in
    this document (see D2 above) and in `docs/compatibility.md`/
    `docs/PORT_AUDIT.md`. `tests/gui/test_gui_display.py` builds genuine Tk widget
    trees — not the `object.__new__`-bypassed, fully-mocked windows the rest
    of `gui/test_gui.py` uses — for the main window and the Preferences, Assign
    Pictures, Import Media, and edit/crop dialogs, including an end-to-end
    simulated drag-select-and-apply crop (`canvas.event_generate` for the
    drag, a real button `.invoke()` for Apply Crop, asserting the callback
    receives the exact box the drag produced). Every test skips itself
    wherever no working Tk display exists. `tools/check.py` now wraps its
    test run in `xvfb-run` automatically on Linux when installed and no
    `DISPLAY` is already set; CI's Linux job installs `xvfb` so it gets this
    coverage too. This measurably exercises code that was previously only
    reachable through mocks: `gui.py` branch coverage rose from 53% to 77% in
    the same run.
  - [x] Import Media extension filter: the CLI's `import-media` command
    accepts `--extensions` to restrict a recursive folder scan, but the
    desktop **Import Media** dialog's folder-import path had no equivalent —
    it always imported every file `amc.media.discover_media` found. Added a
    `simpledialog.askstring` prompt (comma-separated, e.g. `mkv,mp4,wav`;
    blank means no filter) right after the existing recursive-subfolder
    question, parsed by a new `gui.parse_extensions()` that mirrors the CLI's
    own parsing exactly, and passed through as `discover_media`'s
    `extensions=` argument. Scoped to the folder path only, matching the
    CLI's own `--extensions` semantics (narrowing an automatic scan) and not
    the individual-file-selection path, where the user already chooses each
    file explicitly.
  - [x] Broader real-display widget coverage: extended `gui/test_gui_display.py`
    to Loan Out (real `ttk.Combobox.set()` plus a real button `.invoke()`,
    checked against the real service afterward), Loan In, Set Pictures'
    single-shared-picture flow and Clear Pictures' confirmation (both against
    a real embedded PNG round-tripped through the real service), and the edit
    dialog's missing-title validation path. One correction to this item's own
    original wording: a real blocking `messagebox.showerror`/`askyesno` still
    has to be patched in every one of these tests, real display or not,
    because an unpatched one blocks the test waiting for a click that will
    never come (confirmed the hard way via the Import Media test hanging
    during development). The real value real widgets add here is different
    from "not mocking messagebox": checking that the edit dialog's Toplevel
    still exists and its title Entry still holds the rejected empty value
    after a failed Save, not just that an error callback fired.
  - [x] Menu bar and toolbar UX regrouping: the toolbar had grown to 24
    ungrouped buttons across separate rows with no menu bar at all. Added a
    **File / Edit / Movie / Tools** menu bar (`_build_menu_bar`) covering
    every action, and slimmed the toolbar to only the tightest add/edit/
    remove/toggle/undo/redo loop — every action button object still exists
    in `action_buttons` (so the extensive existing headless test suite,
    which mocks that dict directly, keeps working unchanged) but only the
    six toolbar buttons are packed/visible. Menu entries call the same
    `invoke_action` path as their toolbar/keyboard-shortcut counterparts,
    and two new helpers (`_set_action_state`, `_set_menu_state`) keep a
    tracked menu entry's enabled state in lock-step with its toolbar
    button's — e.g. disabling **Remove Movie** because nothing is selected
    disables it in the **Edit** menu too. `_set_menu_state` uses
    `getattr(self, "_menu_entries", {})` rather than the attribute
    directly because headless tests build a `CatalogWindow` via
    `object.__new__`, bypassing `__init__`/`_build_menu_bar` entirely, so
    there is no menu bar to sync in that path. New real-display tests in
    `gui/test_gui_display.py` cover the slimmed toolbar's visible-button set,
    the four top-level menu labels and a sample of their entries, menu/
    toolbar state staying in sync on selection, and invoking a menu command
    end-to-end (Add Movie via the **Edit** menu opens the same dialog the
    toolbar button does).
  - [x] Right-click table context menu: the table had no context menu at
    all — the only per-row interaction outside the toolbar/menu bar/
    keyboard shortcuts was double-click-to-edit. Added
    `_build_context_menu`, a right-click (`<Button-3>`) menu on `self.table`
    with the row-scoped actions most useful there (Add/Edit/Remove Movie,
    Toggle Checked, Loan Out, Loan In, Open URL). Right-clicking a row
    outside the current selection selects just that row first, matching
    common file-manager UX; right-clicking within an existing selection or
    on empty space below the last row leaves the selection unchanged.
    Reused rather than duplicated the menu-bar's tracking: `add_action`/
    `add_tracked` became instance methods (`_add_menu_action`,
    `_add_tracked_menu_command`), and `_menu_entries` changed from
    `dict[str, tuple[Menu, int]]` to `dict[str, list[tuple[Menu, int]]]`
    so one action name can back entries in more than one menu —
    `_set_menu_state` now grays out every tracked entry for a name, so
    selecting a movie enables **Remove Movie** in the context menu, the
    **Edit** menu, and the toolbar button together, not just whichever one
    happens to be open. New real-display tests cover the context menu's
    structure, its shared state-sync with the Edit menu, an actual
    synthetic right-click selecting the clicked row and opening the Edit
    dialog through it, and a right-click on empty space leaving an
    existing selection untouched.
  - [x] Further real-display coverage: statistics (a computed summary
    against a known one-movie catalog), duplicates (both a matching
    normalized title/year group and the no-duplicates case), loan history
    (a real check-out event's row in the dialog's table, and the
    no-history-recorded status-bar message), table sort/selection (a real
    click-equivalent `sort()` call reorders the actual `ttk.Treeview` rows
    and toggles the heading's ▲/▼ marker on a second click), and the edit
    dialog's other validation paths (an out-of-range rating, a non-integer
    year) — every item this line named is now covered, closing it rather
    than leaving it open-ended polish.
  - [ ] Screen-reader labels and a verified accessibility pass remain out of
    reach here regardless of display availability: Tk has no meaningful
    AT-SPI bridge on X11 to exercise, and no screen reader is installed in
    this container. This item stays open until it can be verified on a
    platform where Tk's accessibility support is meaningful (Windows/macOS
    native widgets) or a contributor can verify it directly.
  - [x] A fourth main-window layout (`HTML`) rendering the selected movie's
    **Individual** HTML template live in the right-hand pane, matching
    upstream's own main window. Adopted `tkinterweb` as this port's second
    dependency (ADR-0009) after confirming it ships prebuilt wheels for
    Linux/Windows/macOS; **Tools → Choose HTML Preview Template...** picks
    the template file (persisted in `GuiPreferences.html_preview_template`),
    and selecting a movie renders it through `amc.html_template.
    render_individual_template` with `base_url` set to the template's own
    directory so relative CSS/image references resolve correctly. A
    real-display test (`test_gui_display.py`) confirms a genuine
    `tkinterweb.HtmlFrame` constructs and packs inside this app's actual
    widget tree under Xvfb and renders a real movie end to end.

Comparing the desktop main window against upstream's own (`main.pas`/
`main.dfm`) surfaced further real, source-derived gaps:

  - [x] Field-scoped search bar: upstream's search (`ActionFindFindnextExecute`,
    `main.pas` line ~7891) was far richer than this port's single free-text
    box, which only substring-matched a fixed 11 fields (`Catalog.search`).
    `Catalog.search` now accepts `field` (restrict to one `Movie` field —
    an unknown field raises `ValueError`, matching every other field-name
    validation in this codebase), `whole_field` (exact casefolded match
    instead of substring, matching `TMovie.ContainsText`'s "Whole field
    only"), and `reverse` (movies that do *not* match, matching "Reverse
    results"); an empty query still matches everything (or nothing, if
    `reverse`). The desktop gained a second search-bar row — **Search in
    field** (a friendly field-name dropdown, `_SEARCH_FIELDS`), **Whole
    field only**, and **Reverse results** — and the CLI's `search` command
    gained matching `--field`/`--whole-field`/`--reverse` flags. Upstream's
    "Expression" search mode (`TExprVarMovieParser`/`TExpression`,
    evaluating an arbitrary boolean expression over movie fields) and its
    distinct "Find Next" (jump-to-next-match, no list filtering) vs.
    "Display" (live-filter) modes are deliberately not implemented — this
    port always live-filters, the only mode it had before this item, now
    just with field/whole-field/reverse options added to it.
  - [x] Previous/Next movie navigation: upstream's toolbar has dedicated
    "select previous/next movie in the list" actions
    (`ActionMoviePrevious`/`ActionMovieNext`, `main.pas`), a plain
    list-position step distinct from Undo/Redo, with nothing focused
    starting Next at the first row and Previous at the last, and no
    wraparound past either end (stepping out of range clears the
    selection, matching `ItemFocused` becoming `nil` in the Delphi source).
    Added `select_next`/`select_previous` (`_step_selection`) reproducing
    that exact behavior against the real `ttk.Treeview`, wired to a new
    **Movie** menu entry pair and `Ctrl+PageUp`/`Ctrl+PageDown` (decoded
    from upstream's own default `ShortcutPrev`/`ShortcutNext` TShortcut
    values in `programsettings.pas`). Not added as toolbar buttons, per
    this port's existing "only the tightest add/edit/remove/undo/redo loop
    is a toolbar button" convention — every other action is menu/shortcut-
    only.
  - Menu-bar structure: upstream's top-level menus are File/Movie/Display/
    Tools/Help (`main.dfm`) — no "Edit" menu at all. This port's is
    File/Edit/Movie/Tools/Help: "Edit" is this port's own grouping (Add/
    Remove/Undo/Redo/Find, all of which exist upstream too, just not under
    a menu by that name), and there is still no "Display" menu (upstream's
    home for view/layout-related toggles — the closest equivalent here is
    the toolbar's Layout combobox and the Preferences dialog). The "Edit"
    naming and the missing "Display" menu are cosmetic, not filed as gaps
    on their own.
  - [x] No Help menu or About dialog: upstream has a dedicated Help menu
    (`main.dfm`) as its own top-level entry; this port had neither. Added
    a **Help** menu with an **About AMC Python...** entry showing the
    installed version (`amc.__version__`), license, and a clickable link
    to this project's own repository.

### D6 — remaining "not ported at all" subsystems

Four subsystems in `PORT_AUDIT.md`'s "Not ported" list started with no code at
all: website script execution, localization, printing/reports, and compressed
media codecs (MP3/MP4/OGG). They were not comparable in size or in what
"proceeding" meant for each — this tier records that per item rather than
treating them as one uniform backlog. Three of the four are now settled:
compressed media codecs has dependency-free duration/bitrate coverage for all
three named formats; localization and printing/reports were scoping
decisions rather than implementation gaps, and are now decided (see below —
localization is a timing decision, revisit when translated content exists;
printing/reports is permanent, FreeReport is out of proportion to this
project). Website script *execution* remains open in general: it carries
real security exposure, not just effort, and is deliberately left for an
explicit call rather than decided unilaterally here. A concrete slice of
it is no longer open, though: asked which legacy scripts mattered most,
the answer scoped the actual need down to two cases that don't need
script execution at all — see the checked sub-item below.

  - [x] MP3 duration/bitrate, the most tractable of the four: a
    dependency-free MPEG audio frame header parser (`amc.media._inspect_mp3`)
    computes duration from the first frame's declared bitrate and the
    remaining audio byte count — exact for CBR files, an approximate for VBR
    files without a parsed Xing/VBRI header (not implemented; documented
    limitation). Handles a leading ID3v2 tag (syncsafe size, optional
    footer) and a trailing 128-byte ID3v1 tag. Like WAV/FLAC/AIFF, this is
    parsed from MP3's own public specification, not upstream's actual
    mechanism: `Common/MediaInfo.pas` shows upstream delegates *all* media
    analysis, including WAV, to a dynamically-loaded third-party
    `MediaInfo.dll` (version 22.12) via `LoadLibrary`/`GetProcAddress` — there
    is no Delphi-native codec parser to port even in principle, so "verified
    upstream parity" was never achievable here and isn't being claimed.
    MP4 and OGG remain unimplemented; each needs its own container-walking
    parser (ISOBMFF box tree for MP4, page-granule-position scanning for
    OGG) following the same pattern.
  - [x] MP4/M4A/MOV and OGG Vorbis duration/bitrate, following exactly the
    container-walking pattern the item above predicted. `_inspect_mp4_movie_header`
    walks the ISOBMFF top-level box sequence (skipping each box's payload via
    `seek` rather than reading it, since `mdat` — the actual media data — can be
    arbitrarily large) until it finds the mandatory `moov` box, then its `mvhd`
    child for a movie-level timescale and duration (handling both the 32-bit
    and 64-bit `mvhd` versions, and a box's size-0 "extends to end of file" and
    size-1 64-bit-extended-size cases). There is no per-codec bitrate at this
    level — that lives in codec-specific sample tables this reader does not
    parse, the same reason it does not attempt resolution, framerate, or a
    real codec name — so bitrate is only a whole-file average, the same
    trade-off already made for AIFF-C's non-PCM branch and MP3's VBR files.
    `.mp4`/`.m4v`/`.mov` populate the previously-unused `video_format`/
    `video_bitrate` `Movie` fields instead of `audio_format`/`audio_bitrate`,
    since these are typically video files in a movie catalog and the two
    field pairs already existed distinctly on `Movie` for exactly this reason;
    `.m4a` (an MP4 container restricted to audio) uses the audio fields.
    `_inspect_ogg_vorbis` reads the mandatory Vorbis identification packet
    (`\x01vorbis`) from an Ogg file's first page for sample rate and a nominal
    bitrate, then finds the stream's last page by searching backward from the
    end of the file (Ogg pages carry no leading index of where the stream
    ends, the same reason MP3 duration is estimated from a bounded search
    window) for its granule position (total PCM samples) to compute duration;
    falls back to a whole-file average bitrate when the nominal bitrate is
    absent (0), matching upstream Vorbis encoders that sometimes omit it under
    quality-mode VBR. Deliberately out of scope, consistent with how MP3 never
    attempted VBR-exact duration without a parsed Xing/VBRI header: Ogg files
    multiplexing more than one logical bitstream (e.g. Theora video alongside
    Vorbis audio) and Opus streams (`OpusHead` instead of `\x01vorbis`) are
    rejected with a clear error rather than guessed at; video-track resolution,
    framerate, and codec name for MP4 remain unimplemented for the same
    sample-table reason bitrate is only an average. `docs/architecture.md`'s
    "Deliberate prototype boundaries" section is updated to match.
  - [x] Two real bugs found and fixed against a genuine AMC 4.2.2 XML export
    a user contributed for local debugging (a large real catalog, not
    committed to the repository — the first genuine upstream-generated data
    used to validate this port): `_XML_FIELDS` used invented attribute names
    `"MediaCount"`/`"FileSize"` that appear nowhere in the Delphi source;
    the real names, confirmed against `fields.pas`'s `strTagFields` table
    and present on every one of the real movies, are `"Disks"`/
    `"Size"`. Fixing the name alone would have introduced a second bug:
    `Size` is free-form text upstream (a multi-part release is
    `"+"`-joined, e.g. a real `"698+696"`), which the existing lenient
    number parser would have silently truncated; `load_xml`/`save_xml` now
    preserve the exact original text through `extras` when it isn't a
    plain integer. A third, unrelated encoding-corruption issue in the same
    file (raw UTF-8 bytes inside a document declared `windows-1252`) is now
    recovered from with a tolerant retry instead of failing the whole load.
    See PORT_AUDIT.md finding 26.
  - [x] HTML export templates: `amc.html_template` (new module) renders
    upstream's own `$$TAG_NAME` HTML export template syntax — the same
    placeholders `export.pas`'s `ReplaceTagsGeneral`/`ReplaceTagsMovie` use
    — so a template a user already has for real AMC's HTML export keeps
    working, wired into the CLI as `export-html-template` and into the
    desktop **Export** action (an `.html` destination now asks whether to
    use an Ant Movie Catalog template instead of the default table export).
    Validated
    locally against the same genuine 4.2.2 export above and that export's
    own real full/individual templates: both rendered with zero leftover
    `$$` placeholders across the whole catalog. The `$$ITEM_EXTRA_*`
    supplementary-record loop and upstream picture/rating-icon file
    copying are explicitly out of scope (documented in the module
    docstring). This is distinct from — and does not reduce the scope of
    — the FreeReport report-designer item below. See PORT_AUDIT.md
    finding 27.
  - [x] Desktop template selection dialog: the **Export** action's "use an
    Ant Movie Catalog template" path previously chained three sequential
    blocking file dialogs (full-catalog template, individual-movie
    template, then an individual-pages folder) with no way to see or
    change a choice before committing to the next prompt. Replaced with one
    modal dialog presenting the full-catalog page and individual-movie
    pages as two independently enabled sections — matching upstream's own
    Export screen, which treats "Full" and "Individual" as two separately
    selected templates — each with its own template-file picker (and the
    individual section's own folder and filename-pattern fields), plus
    upfront validation ("choose at least one", "choose a template for each
    enabled section") instead of silently doing nothing on a blank
    selection. Deliberately does not add upstream's in-place template
    editor (the code-editor pane in its Export dialog): selecting a
    template file, not authoring one, is what this port's renderer needs.
  - [x] "Movies to include" scope and export-time sort: upstream's Export
    dialog (`export.pas`) lets an export cover all/selected/checked/visible
    movies and sort them independently of the catalog's own current order.
    Every CLI `export-*` command now accepts `--scope {all,checked}` and
    `--sort-by FIELD [--sort-reverse]`; the desktop's Export flow opens an
    **Export options** dialog offering all four scopes (with a live count
    per option, `selected`/`visible` being desktop-only since the CLI has no
    interactive selection or search) and the same sort/reverse control.
    `CatalogService.export`/`export_html_template` take `movies`/`sort_by`/
    `sort_reverse` and build a fresh, unregistered `Catalog` for the scoped
    export — the live catalog and its own order are never touched by an
    export. `Catalog.sort`'s ordering logic moved to a shared
    `catalog.sort_movies` helper so both use one validated implementation.
  - [x] Upstream's Export
    dialog also has controls this port's export still lacks entirely: for
    HTML specifically, a Pictures section (copy pictures alongside the
    export, into a subfolder, only if missing, include extras) — the same
    "upstream picture/rating-icon file copying" gap already named in
    `amc.html_template`'s own docstring and in `docs/compatibility.md`.
    Implemented the picture-copying slice for template exports: linked and
    embedded posters can be copied through a durable atomic binary writer into
    a validated relative subdirectory, template picture tags use that path,
    filename collisions are rejected, and an "only if missing" mode preserves
    existing assets. The service resolves links relative to the source catalog
    through `presentation.poster_source`; CLI flags expose all three controls.
    The desktop template dialog exposes the same controls. Embedded pictures
    without a stored filename receive a signature-derived extension, and
    individual pages in a separate folder receive a correct relative asset
    reference. Rating icons remain template-owned assets. Also out of scope
    in the same dialog: SQL export and a dedicated
    "Pictures" export format (bulk-exporting every picture), neither of
    which this port implements under any export path.
  - [x] Localization turns out not to be a portable-format problem: reading
    `Common/AntTranslator.pas` (the actual `.lng` loader, since no `.lng`
    file itself is present in the checked-in source snapshot to treat as a
    fixture) shows the mechanism is a runtime Delphi RTTI object-graph
    patcher — each line is a dotted VCL property path (e.g.
    `Button1.Caption=Fermer`, including indexed collection/list/tree items)
    resolved and assigned live via `GetPropInfo`/`SetStrProp` against actual
    form/frame/component instances. That mechanism is structurally tied to
    VCL forms and has no Tk equivalent to receive it; "parity" with the
    `.lng` format is not a coherent target for a Tk GUI regardless of effort
    spent. A localized Python GUI is possible, but only as a wholly
    Python-owned feature (externalize `gui.py`'s hardcoded English strings
    behind a key→string lookup, add a loader), and there is no actual
    translated content available anywhere in this repository to load even if
    that scaffolding existed. **Decided:** don't build that scaffolding now —
    an i18n layer with no translations behind it is untestable beyond "does
    English fall back to English," which is speculative infrastructure for a
    hypothetical future need rather than a bounded slice with a test to
    write. This is a timing decision, not a permanent one: revisit once a
    contributor supplies real translated strings to load, at which point the
    externalization refactor becomes a bounded, testable slice like any
    other. `docs/architecture.md`'s "Deliberate prototype boundaries" and
    `docs/compatibility.md`'s Localization row record this.
  - [x] Printing/reports' license blocker is resolved but its effort is not:
    `src/original/FreeReport/license.txt` is LGPL v2, which is redistributable
    under this repository's existing GPLv2 posture — contrary to the
    "decide port/omission after ... license review" framing, there is no
    remaining license question. What remains is that FreeReport is a
    complete Delphi report designer and renderer (its own binary report
    definition format, a design-time UI, print preview, and a large source
    tree under `src/original/FreeReport/SOURCE/`) — porting it is a
    standalone-application-sized effort, not a bounded slice, and AMC Python
    already has static HTML export as a non-compatible baseline export path.
    **Decided:** don't port FreeReport, permanently rather than pending —
    `export-html-template`/`amc.html_template` (finding 27) already covers
    "produce a formatted report from the catalog" as a non-compatible
    baseline, and a full report designer/renderer is disproportionate to the
    rest of this port's scope. A specifically PDF/print-friendly export
    beyond HTML remains a separate, smaller possible future item if actually
    requested — this decision closes the FreeReport port question, not every
    conceivable printing-adjacent feature. `docs/architecture.md`'s
    "Deliberate prototype boundaries" and `docs/compatibility.md`'s
    Printing/reports row record this.
  - [x] General website script execution would need an IFPS (Innerfuse Pascal
    Script) bytecode compiler and sandboxed VM with timeouts, rate limits,
    and a result-merge UI before any script can actually run — `amc.scripts`
    deliberately reads only leading metadata comments today and never
    executes script bodies. This is comparable in scope to printing: a
    standalone interpreter project, not a bounded slice, and it additionally
    carries real security exposure (executing arbitrary scripts sourced from
    the web). **Decided:** do not build or embed that interpreter. AMC Python
    retains non-executing inspection/configuration and adds only narrow,
    audited providers with bounded network access and preview-before-apply
    changes. A separately maintained sandbox could revisit the bytecode
    question, but it is not an in-process extension point for this application.
    Accepted ADR-0005 records this security boundary.
  - [x] Asked which legacy scripts mattered most, the answer scoped the
    actual need down to two cases that don't need IFPS at all: refreshing
    metadata on movies already in the catalog ("update scripts") and IMDb
    lookups specifically. `amc.omdb` (new module) is a small, hand-written,
    auditable Python provider for exactly that pair, via the OMDb API — a
    REST API that legally re-serves a curated subset of IMDb's own data as
    JSON, chosen over scraping imdb.com directly (against its Terms of
    Service, fragile to markup changes) and over IMDb's own bulk datasets
    (no live title search without building a local index). Every request
    needs an explicit, caller-supplied API key (never hardcoded, never
    persisted) and a bounded timeout; `movie_fields_from_omdb` maps the
    response onto `Movie` fields, explicitly excluding `Poster` (image
    download is separately unimplemented) and fields with no `Movie`
    equivalent; `preview_omdb_update` builds an isolated, unmutated
    candidate and diff, reusing `amc.scripts`' `ScriptFieldChange`/
    `ScriptMergePreview` shape rather than inventing a second one. Wired
    into the CLI as `imdb-lookup NUMBER [--api-key KEY] [--imdb-id ID]
    [--apply]` (dry-run preview by default; `--apply` writes through the
    existing `CatalogService.replace`). See `docs/PORT_AUDIT.md` finding 31.
    While mapping OMDb's `Runtime` field, found and fixed a real, unrelated
    bug this same investigation surfaced: `movie_from_media` had been
    setting `Movie.length` in seconds since D0, when every other place in
    this port (including upstream's own documentation) treats it as
    minutes — see finding 32.
  - [x] Wired the same `amc.omdb` preview-then-apply contract into the
    desktop GUI as a **Movie / Update from IMDb...** dialog: an API-key
    field (defaulting to `OMDB_API_KEY`, never persisted) and an optional
    IMDb-ID field, a **Fetch Preview** button that shows the field-change
    list without writing anything, and an **Apply** button (disabled until
    a preview with at least one change exists) that writes through
    `CatalogService.replace`, gated on the same selected-exactly-one-and-
    writable rule as Edit. Verified with a real Tk widget tree under Xvfb:
    a patched OMDb response driving a real fetch-preview-apply round trip,
    and a patched network failure confirming the dialog reports the error
    and stays open with Apply disabled. See `docs/PORT_AUDIT.md` finding 36.
  - [x] Validated `amc.scripts.inspect_script`/`discover_scripts` against a
    314-file contributor snapshot of `update.antp.be/amc/scripts/`, Ant
    Movie Catalog's own official script-update feed — real scripts at real-
    world scale, not just synthetic headers. Found and fixed a real bug:
    37 of the 314 files (about 12%) crashed `inspect_script()` outright with
    an unhandled `UnicodeDecodeError`, because its two-codec fallback chain
    (`utf-8-sig` then `cp1252`) had no answer for a real script using a
    different single-byte code page (a genuine Polish script uses `cp1250`,
    which legitimately fills five byte positions `cp1252` leaves
    undefined). Fixed by decoding the `cp1252` fallback with
    `errors="replace"` instead of raising, matching every other malformed-
    input path in this module; the structural syntax this function actually
    parses is plain ASCII regardless of code page. Re-running the full
    314-file snapshot afterward produced zero exceptions. Fourteen of these
    files — the ones carrying their own explicit, redistribution-permitting
    license — are now committed as real fixtures at
    `tests/fixtures/scripts/`; the rest of the snapshot (mostly a 272-file
    archive of scripts for now-defunct sites, plus unlicensed current
    scripts) is deliberately not committed, on the same "explicit license
    required, reachability from an official feed is not enough" standard
    this project already applies to its own retained Delphi source. See
    `docs/PORT_AUDIT.md` finding 33.

## Immediate next slice

Execution is organized into four gated sprints in
[`NEXT_SPRINTS.md`](NEXT_SPRINTS.md):

1. obtain trustworthy archives, redistribution decisions, and genuine AMC 4.2.3.2
   empty/one-movie fixtures;
2. verify and correct the 4.2 codec against an expanded genuine fixture set;
3. prove lossless native/XML/JSON interchange and document CSV losses; then
4. complete engineering and release gates for the evidence-backed subset.

Sprint 1 requires a genuine Windows AMC 4.2.3.2 installation this repository's
automated environment does not have, so it is currently blocked on an external
contributor supplying fixtures, not on further coding here. Sprint exit checks
remain blocking criteria — no later sprint's work advances an earlier gate, and
no compatibility status may be upgraded without registered evidence — but with
Sprint 1 externally blocked, the immediate change should draw from the
**Downstream execution backlog (D0–D6)** above rather than sitting idle or
inferring more unverified format behavior. A downstream slice still needs its
own tests and documentation; it simply makes no upstream-compatibility claim,
so it does not require a fixture.

The manifest contract and canonical checks now support exact 65-byte native headers,
declared native versions, movie counts, metadata, and indexed movie-field expectations through
`tools/verify_fixtures.py`. This makes fixture intake reproducible, and two genuine
fixture sets have since been registered under it —
`tests/fixtures/native-empty-one-movie/` (empty/one-movie AMC 3.5/4.1/4.2 catalogs)
and `tests/fixtures/native-sample-catalog/` (a populated AMC 3.5/4.2 catalog pair
with custom fields and embedded pictures) — which satisfy Sprint 1's own
`validate_fixtures`/`verify_fixtures` exit checks. Sprint 1 as a whole is still not
closed: its other required work — reacquiring the published source archive from an
independently recorded origin, and resolving the ElTree redistribution restriction
and the absent `Common/ComboBoxAutoWidth.pas` license grant (Milestone 0) — remains
open. No compatibility status may be upgraded to `verified` regardless of Sprint 1's
state, since that also needs a documented cross-application (write, then reopen in
genuine AMC) test that neither fixture set provides yet.

Do not add unrelated UI, CRUD, native writing, or further legacy parsing until this
slice passes. A source-derived synthetic test is implementation evidence, not
compatibility evidence.
