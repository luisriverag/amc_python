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

- [ ] Acquire `amc_sources.rar` and record URL, retrieval date, byte size, and
  SHA-256 digest.
- [x] Add a streaming acquisition, extraction, checksum, and inventory tool.
- [ ] Confirm the upstream version and licensing terms.
- [ ] Add the applicable license and attribution files.
- [ ] Inventory every source unit, form, resource, script, and file format.
- [ ] Map each unit to a Python subsystem or an explicit omission.
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
- [x] Specify internal JSON v1 and test failed-write destination preservation.

**Gate:** all checks run from a single documented command and in CI.

## Milestone 2: native AMC read support

- [ ] Identify the native signature, header, versions, encodings, record framing,
  checksums, compression, and picture representation.
- [ ] Add empty, one-record, all-fields, Unicode, picture, and corrupt fixtures.
- [ ] Implement upstream-derived native format detection and a read-only header parser.
- [x] Add format-neutral `amc inspect` and `amc validate`; native `.amc` remains explicitly blocked.
- [ ] Parse catalog metadata, movie records, custom fields, and pictures.
- [ ] Cross-check native parsing against XML produced by upstream AMC.

**Gate:** supported `.amc` files can be converted without the original program and
all omitted or opaque data is reported.

## Milestone 3: lossless interchange

- [ ] Replace synthetic XML/CSV assumptions with upstream-generated fixtures.
- [ ] Model all known catalog and movie fields.
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

## Recommended next slice

The next implementation slice is deliberately narrow:

1. Obtain and checksum the source archive.
2. Complete the upstream inventory.
3. Identify the native header-reading unit.
4. Add genuine empty and one-movie `.amc` fixtures.
5. Write failing signature/version/truncation tests.
6. Implement only native format detection and header inspection.
7. Add `amc inspect` without exposing native writing.

Do not add unrelated UI or CRUD features until this slice is complete.

Progress and claims must be reconciled against [`PORT_AUDIT.md`](PORT_AUDIT.md)
after every milestone. A configured workflow or synthetic fixture is implementation
evidence, not upstream compatibility evidence.
