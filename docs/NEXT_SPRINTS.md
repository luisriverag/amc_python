# Critical port sprints

This roadmap turns the evidence gaps in the implementation plan into the next four
bounded sprints. The ordering is mandatory: completing prototype features does not
substitute for upstream evidence, and a later sprint cannot advance a compatibility
claim while an earlier gate is open.

## Priority rules

1. **Compatibility evidence before more inferred format behavior.** Native and XML
   code has extensive synthetic coverage but no registered upstream-generated
   fixture.
2. **Redistribution clearance before release work.** Historical source must not be
   included in a release while the ElTree restriction and the missing
   `Common/ComboBoxAutoWidth.pas` license grant remain unresolved.
3. **Losslessness before convenience features.** Unknown, duplicate, ordered, or
   typed interchange data must be retained or rejected with a diagnostic.
4. **Release hardening after format gates.** Refactoring, performance work, and
   packaging do not raise the compatibility evidence level on their own.

## Sprint 1 — obtain trustworthy upstream evidence (P0)

**Goal:** establish inputs that can support compatibility claims.

### Required work

- Reacquire the published source archives from an independently recorded origin;
  record retrieval timestamp, final URL, byte length, SHA-256, and any publisher
  checksum or signature.
- Compare each reacquired archive with both checked-in compressed archives and the
  952-file expanded inventory using `tools/acquire_upstream.py`. RAR acquisition
  tries each installed extractor in order, so one incompatible tool does not prevent
  a later capable extractor from completing the evidence check.
- Resolve the ElTree source-redistribution restriction and the absent license grant
  for `Common/ComboBoxAutoWidth.pas`, or remove the affected files from distributed
  artifacts while retaining a documented non-distributed evidence workflow.
- Use upstream AMC 4.2.3.2 to create empty and one-movie native catalogs plus their
  XML exports. Record the exact producer build, operating-system locale, catalog
  code page, creation steps, SHA-256, expected values, and redistribution permission.
- Register each accepted fixture with the existing provenance-manifest contract.

### Exit checks

- `python tools/acquire_upstream.py ...` reports a reviewed archive/tree comparison.
- `python tools/validate_fixtures.py` validates at least two genuine manifests.
- `python tools/verify_fixtures.py` verifies the empty and one-movie expectations.
- `THIRD_PARTY_NOTICES.md` contains no unhandled redistribution blocker for the
  contents intended for release.
- `python tools/check_package.py` confirms that wheel and source-distribution
  workflows exclude all retained historical source/archive evidence trees.

### Explicit non-goals

No new GUI workflow, native writer version, provider execution, or inferred legacy
field should be added in this sprint.

## Sprint 2 — verify and correct the AMC 4.2 codec (P1)

**Goal:** make the existing 4.2 reader evidence-backed rather than synthetic-only.

### Required work

- Cross-check the exact header, property block, custom-field definitions, movie
  count, every scalar field, picture framing, supplementary records, and terminal
  offset against the Sprint 1 catalogs and XML exports.
- Add all-fields, custom-field, linked-picture, embedded-picture, supplementary,
  and non-ASCII/code-page fixtures with the same provenance standard.
- Establish encoding behavior from catalogs generated under recorded locales;
  document when callers must use `--native-encoding` and how undecodable bytes are
  diagnosed or retained.
- Add byte mutations derived from genuine fixtures for truncation, invalid counts,
  oversized strings/pictures, and malformed record boundaries. Verify stable error
  codes and offsets under each public read limit.
- Correct parser assumptions exposed by evidence. Record every intentionally opaque
  or normalized value rather than silently discarding it.

### Exit checks

- Native-to-JSON output matches reviewed expected documents for every registered
  4.2 fixture.
- Corrupt fixtures terminate within configured budgets and produce documented,
  deterministic diagnostics.
- The compatibility matrix may move individual 4.2 read capabilities from
  `investigating` only when each capability cites its fixture evidence.

### Explicit non-goals

Do not enable native writing by default or claim support for older versions based
only on the verified 4.2 set.

## Sprint 3 — prove interchange losslessness (P2)

**Goal:** demonstrate semantic conversion across native AMC, upstream XML, and the
internal JSON representation.

### Required work

- Compare each upstream XML export with its native source and define expected
  normalization for dates, ratings, paths, pictures, and custom-field types.
- Introduce format-neutral typed models for catalog properties, custom-field
  definitions/values, pictures, and supplementary records; retain ordered duplicate
  values and unknown nested XML without reserved-key collisions.
- Import native and XML fixtures to JSON, export XML, then open and resave the result
  in upstream AMC. Compare the second export semantically and document differences.
- Document CSV's deliberately lossy boundaries using an upstream-generated CSV
  corpus rather than synthetic dialect assumptions.

### Exit checks

- Reviewed semantic round trips pass for every registered native/XML fixture.
- Unsupported structures fail before destination replacement or survive in a
  documented opaque representation.
- The compatibility matrix identifies evidence per format and field family instead
  of applying a blanket format claim.

## Sprint 4 — engineering and release gates (P3)

**Goal:** make the evidence-backed subset repeatable across supported environments.

### Required work

- Split tests into unit, integration, compatibility, CLI, and GUI groups while
  preserving one canonical local command.
- Add a formatter and static type checker; build both wheel and source distribution;
  verify clean installs on the supported Linux and Windows Python matrix.
- Add permission, interrupted-write, concurrency, large-catalog, and performance
  tests around the verified conversion paths.
- Separate storage dispatch from codecs only after fixture-backed boundaries are
  stable.
- Produce a compatibility report listing verified versions, fixtures, known losses,
  migration steps, backup/recovery procedures, and excluded historical sources.

### Exit checks

- Canonical and package checks pass in clean Linux and Windows environments.
- Release artifacts exclude unresolved third-party material and contain all required
  notices.
- Experimental native writing remains gated until upstream open/save/reopen evidence
  passes for every claimed output capability.

## Work deferred until these gates pass

- Sandboxed website-script execution and live network providers.
- Additional native writer versions or removing the experimental writer warning.
- Broad UI parity, batch picture workflows, printing/report design, and full media
  codec analysis.
- Performance-only native refactors that would change unverified byte boundaries.

These items remain valid project goals, but they are not on the critical path to a
defensible port claim.
