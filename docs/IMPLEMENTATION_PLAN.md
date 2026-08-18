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

- [ ] Split tests into `unit`, `integration`, `compatibility`, `cli`, and `gui`.
- [x] Configure Linux and Windows CI for all supported Python versions; hosted run
  verification remains pending.
- [ ] Add formatting, linting, static typing, and coverage (focused Ruff linting
  and an 80% branch-coverage floor now run in the canonical command and CI;
  formatter and static typing remain pending. Canonical commands also cover tests,
  compilation, diff validation, wheel building, isolated installation, and
  source-tree and installed-module CLI smoke checks).
- [x] Establish and automatically validate the fixture provenance manifest contract;
  genuine upstream fixtures still need to be produced and registered.
- [ ] Add a changelog and architecture-decision log.
- [x] Specify internal JSON v1 and test failed-write destination preservation for
  JSON, CSV, and XML serialization failures.

**Gate:** all checks run from a single documented command and in CI.

## Milestone 2: native AMC read support

- [ ] Identify the native signature, header, versions, encodings, record framing,
  checksums, compression, and picture representation.
- [ ] Add empty, one-record, all-fields, Unicode, picture, and corrupt fixtures.
- [x] Implement source-derived native 1.0–4.2 header detection and read-only record
  parsing; compatibility verification remains blocked on genuine fixtures.
- [x] Add explicit, atomic source-derived AMC 4.2 export with synthetic round-trip
  coverage; upstream acceptance and byte-level compatibility remain unverified.
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
  read-only until saved as JSON; batch picture management, progress, cancellation,
  accessibility, and dirty-state prompting remain pending).
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
  (portable file facts and PCM WAV analysis are available without dependencies).
- [ ] Use recorded responses in tests; live network tests must be opt-in.
- [ ] Reproduce upstream HTML template/tag semantics (safe static HTML table export
  is available as a non-compatible baseline).

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
4. Record producer version, creation steps, SHA-256, expected contents, mutations,
   and redistribution permission for every fixture.

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

1. Split tests into unit/integration/compatibility/CLI/GUI groups and add one canonical
   local check command.
2. Add formatter, linter, type checker, coverage threshold, wheel/sdist build, clean
   install, and subprocess CLI smoke tests to Linux and Windows CI.
3. [Partial] A shared application service now owns GUI open/reload and
   failure-atomic add/replace/remove, batch media import, catalog merge, sort, and
   renumber persistence, interchange conversion, export, and validated
   backup/restore; the CLI uses it for those workflows. Separate storage
   dispatch/codecs behind repository interfaces.
4. Add performance, concurrency, permission, durability, and large-catalog tests.
5. Keep native writing disabled until upstream open/save/reopen tests pass and backup
   and interrupted-write behavior is proven.

## Immediate next slice

Execution is now organized into four gated sprints in
[`NEXT_SPRINTS.md`](NEXT_SPRINTS.md):

1. obtain trustworthy archives, redistribution decisions, and genuine AMC 4.2.3.2
   empty/one-movie fixtures;
2. verify and correct the 4.2 codec against an expanded genuine fixture set;
3. prove lossless native/XML/JSON interchange and document CSV losses; then
4. complete engineering and release gates for the evidence-backed subset.

The immediate change should contain **Sprint 1 fixtures and verification, not
another inferred format feature**. Sprint exit checks are blocking criteria rather
than suggestions; work from later sprints does not advance an earlier gate.

The manifest contract and canonical checks now support exact 65-byte native headers,
declared native versions, movie counts, metadata, and indexed movie-field expectations through
`tools/verify_fixtures.py`. This makes fixture
intake reproducible, but does not advance the items above: no genuine upstream
fixture or redistribution decision has yet been supplied.

Do not add unrelated UI, CRUD, native writing, or further legacy parsing until this
slice passes. A source-derived synthetic test is implementation evidence, not
compatibility evidence.
