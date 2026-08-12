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
  SHA-256 digest; a checked-in extracted snapshot exists without these records.
- [x] Add a streaming acquisition, extraction, checksum, and inventory tool.
- [ ] Confirm snapshot/archive equivalence and complete application/dependency
  license review.
- [ ] Add the applicable license and attribution files.
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
- [ ] Add formatting, linting, static typing, coverage, wheel build, and installed
  CLI smoke checks.
- [ ] Establish fixture provenance and regeneration instructions.
- [ ] Add a changelog and architecture-decision log.
- [x] Specify internal JSON v1 and test failed-write destination preservation for
  JSON, CSV, and XML serialization failures.

**Gate:** all checks run from a single documented command and in CI.

## Milestone 2: native AMC read support

- [ ] Identify the native signature, header, versions, encodings, record framing,
  checksums, compression, and picture representation.
- [ ] Add empty, one-record, all-fields, Unicode, picture, and corrupt fixtures.
- [x] Implement source-derived native 1.0–4.2 header detection and 3.1–4.2
  read-only record parsing; compatibility verification remains blocked on fixtures.
- [x] Add format-neutral `amc inspect` and `amc validate`; modern native validation
  parses structure but reports unverified status rather than claiming compatibility.
- [ ] Parse catalog metadata, movie records, custom fields, and pictures (read-only
  owner/mail/site/description parsing is complete for versions 3.1–4.2, and
  custom-field definition parsing for versions 4.0–4.2, and movie-row parsing for
  versions 3.1–4.2, including 4.2 supplementary records; generic/CLI read-only
  import is wired with header-based detection, catalog metadata, and embedded bytes
  retained in JSON).
- [ ] Cross-check native parsing against XML produced by upstream AMC.

**Gate:** supported `.amc` files can be converted without the original program and
all omitted or opaque data is reported.

## Milestone 3: lossless interchange

- [ ] Replace synthetic XML/CSV assumptions with upstream-generated fixtures.
- [ ] Model all known catalog and movie fields (catalog properties and custom-field
  definitions are retained for native and XML inputs).
- [ ] Preserve duplicate custom fields, ordering, types, and attributes.
- [ ] Verify Python XML output by importing it into upstream AMC.
- [ ] Add configurable merge policies: `error`, `skip`, `replace`, and `renumber`.
- [ ] Add streaming readers and documented resource limits.

**Gate:** semantic round trips are verified for every supported format/version.

## Milestone 4: native AMC write support

- [ ] Implement version-specific writers behind an experimental flag.
- [ ] Always back up existing native catalogs before replacement.
- [ ] Test interrupted writes and preservation of the original file.
- [ ] Open, save, and reopen generated files with upstream AMC.
- [ ] Remove the experimental flag only after all compatibility fixtures pass.

## Milestone 5: application services and interfaces

- [ ] Move mutations and persistence policy out of CLI/GUI adapters into services.
- [ ] Add complete field editing, bulk operations, backup/restore, duplicate
  detection, JSON CLI output, and stable exit codes.
- [ ] Add complete GUI editing, open/save-as, import/export, pictures, dirty-state
  prompts, undo, progress, cancellation, and accessibility.
- [ ] Add loan management and catalog preferences if confirmed upstream features.

## Milestone 6: scripts, metadata, and media

- [ ] Inventory the upstream scripting API and decide compatibility boundaries.
- [ ] Define a provider interface with timeouts, caching, rate limits, and safe
  field-level merge previews.
- [ ] Add image download and media-file analysis as optional capabilities.
- [ ] Use recorded responses in tests; live network tests must be opt-in.

## Milestone 7: release

- [ ] Complete package metadata, licenses, attribution, migration, backup, and
  recovery documentation.
- [ ] Build and install wheels and source distributions in clean environments.
- [ ] Produce cross-platform release artifacts and a compatibility report.
- [ ] Complete performance, fuzz, corrupt-input, and large-catalog testing.

## Prioritized execution backlog

The code review identified a gap between **implemented from source** and **verified
against upstream output**. Work must proceed in this order; later phases do not
unblock earlier evidence gates.

### P0 — establish trustworthy evidence

1. Reacquire and checksum the published source archive; compare its deterministic
   inventory with both checked-in source trees.
2. Complete application and bundled-dependency license review, then add root-level
   license and attribution files.
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
   universal default; cover undecodable bytes and locale differences.
3. Define strict behavior for truncated final records instead of copying upstream's
   silent stop, and test every bounded length/count/picture path.
4. Preserve native-only scalar values, custom-field types, embedded images, and
   supplementary records through native → JSON → JSON without normalization loss.
5. [Partial] File size, movie count, individual picture, and cumulative picture
   limits are implemented. Add cumulative string/nesting limits and fuzz/property
   tests for parser termination and stable diagnostics.
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
   opaquely; retain current rejection wherever lossless XML output is impossible.
4. Specify metadata merge policies (`error`, `keep`, `replace`, `namespace`) and
   movie collision policies (`error`, `skip`, `replace`, `renumber`). Current
   metadata merging is validated, deep-copied, and atomic but supports `error` only.
5. Verify Python XML output by opening and resaving it with upstream AMC.

**Exit criterion:** documented semantic round trips pass for native, XML, and JSON;
CSV has explicitly documented lossy boundaries.

### P3 — engineering and release gates

1. Split tests into unit/integration/compatibility/CLI/GUI groups and add one canonical
   local check command.
2. Add formatter, linter, type checker, coverage threshold, wheel/sdist build, clean
   install, and subprocess CLI smoke tests to Linux and Windows CI.
3. Extract storage dispatch/codecs and a shared application service from CLI/GUI.
4. Add performance, concurrency, permission, durability, and large-catalog tests.
5. Keep native writing disabled until upstream open/save/reopen tests pass and backup
   and interrupted-write behavior is proven.

## Immediate next slice

The next change should contain **fixtures and verification, not another inferred
format feature**:

1. Finish P0 archive identity/license tasks.
2. Add provenance manifests plus genuine AMC 4.2.3.2 empty and one-movie fixtures.
3. Cross-check header, metadata offsets, movie count, and native → JSON output.
4. Correct parser assumptions exposed by those fixtures and update this audit.

Do not add unrelated UI, CRUD, native writing, or further legacy parsing until this
slice passes. A source-derived synthetic test is implementation evidence, not
compatibility evidence.
