# Critical port sprints

This roadmap turns the evidence gaps in the implementation plan into the next four
bounded sprints. The ordering is mandatory: completing prototype features does not
substitute for upstream evidence, and a later sprint cannot advance a compatibility
claim while an earlier gate is open.

**Current status: Sprint 1 is partially underway but still open.** Two genuine
upstream-generated fixture sets have been contributed and registered —
`tests/fixtures/native-empty-one-movie/` and `tests/fixtures/
native-sample-catalog/` — satisfying this sprint's `validate_fixtures`/
`verify_fixtures` exit checks below. The ElTree redistribution restriction this
status previously named is resolved: `src/original/ElTree/` and the RAR
archive that also contained it have been removed from the repository and its
git history, since ElTree's license permits distribution only inside compiled
software and AMC Python never used it. The rest of Sprint 1's required work —
reacquiring the published source archive from an independently recorded
origin, and resolving the absent `Common/ComboBoxAutoWidth.pas` license
grant — still cannot be performed inside this repository's automated
development environment and remains externally blocked. Sprints 2–4 stay
gated behind Sprint 1's exit checks exactly as
written below; none of their compatibility claims may be advanced without
registered fixtures, and no status may move to `verified` without also a
documented cross-application (write, then reopen in genuine AMC) test, which
neither registered fixture set provides yet. While the remaining blockers wait
on an external contributor, execution proceeds on the ordered, fixture-independent
[**Downstream execution backlog (D0–D6)**](IMPLEMENTATION_PLAN.md#downstream-execution-backlog-d0d6)
in `IMPLEMENTATION_PLAN.md` (Milestones 5 and 6). That work never substitutes
for Sprint 1 and must not be described as compatibility progress.

## Priority rules

1. **Compatibility evidence before more inferred format behavior.** Native and XML
   code has extensive synthetic coverage but no registered upstream-generated
   fixture.
2. **Redistribution clearance before release work.** The ElTree restriction is
   resolved (by removing the affected files, not by obtained permission).
   Historical source must not be included in a release while the missing
   `Common/ComboBoxAutoWidth.pas` license grant remains unresolved.
3. **Losslessness before convenience features.** Unknown, duplicate, ordered, or
   typed interchange data must be retained or rejected with a diagnostic.
4. **Release hardening after format gates.** Refactoring, performance work, and
   packaging do not raise the compatibility evidence level on their own.

## Sprint 1 — obtain trustworthy upstream evidence (P0)

**Goal:** establish inputs that can support compatibility claims.

### Required work

- Reacquire the published source archive from an independently recorded origin;
  record retrieval timestamp, final URL, byte length, SHA-256, and any publisher
  checksum or signature. The RAR previously checked in for this comparison
  (`amc_sources.rar`) has been removed along with the ElTree files it
  contained (see below); a freshly reacquired copy would still be compared
  against the remaining 848-file expanded inventory (`src/original/` minus
  ElTree, plus `src/antcomponents/`) using `tools/acquire_upstream.py`, but
  would not itself be re-committed. RAR acquisition tries each installed
  extractor in order, so one incompatible tool does not prevent a later
  capable extractor from completing the evidence check.
- Compare a reacquired `antcomponents.zip` with the checked-in copy and its
  76-file expanded inventory the same way.
- [Done] The ElTree source-redistribution restriction is resolved: rather than
  obtaining permission or maintaining a documented non-distributed evidence
  workflow, `src/original/ElTree/` and the RAR archive that also contained it
  were removed entirely from the repository and its git history, since AMC
  Python never used ElTree. The absent license grant for
  `Common/ComboBoxAutoWidth.pas` remains open.
- Use upstream AMC 4.2.3.2 to create empty and one-movie native catalogs plus their
  XML exports. Record the exact producer build, operating-system locale, catalog
  code page, creation steps, SHA-256, expected values, and redistribution permission.
  [Partial] Empty/one-movie AMC 3.5/4.1/4.2 native catalogs and a populated
  3.5/4.2 pair with custom fields and embedded pictures are registered
  (`tests/fixtures/native-empty-one-movie/`, `tests/fixtures/
  native-sample-catalog/`); their matching XML exports are not, and the
  producer build is not confirmed as specifically 4.2.3.2.
- Register each accepted fixture with the existing provenance-manifest contract.
  [Done for the fixtures registered so far.]

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

- Website-script (IFPS) execution: intentionally excluded by accepted ADR-0005
  because arbitrary downloaded bytecode is outside the application trust
  boundary; this is a decided product/security boundary, not fixture timing — see
  `IMPLEMENTATION_PLAN.md`'s D6. A narrower, non-executing alternative
  (`amc.omdb`, a first-party OMDb API provider covering the two
  highest-value legacy-script use cases) already shipped and is not
  blocked by this gate.
- Additional native writer versions, and removing the experimental-writer
  warning on the existing AMC 4.2 writer.
- Performance-only native refactors that would change unverified byte
  boundaries.

Broad UI parity, batch picture workflows, and full media-codec
duration/bitrate analysis (MP3/MP4/OGG) turned out not to need this gate at
all: they are Python-owned behavior with no upstream-compatibility claim, so
they proceeded on the fixture-independent downstream backlog described above
and are now done — see `IMPLEMENTATION_PLAN.md`'s D0/D1/D5. Printing/report
design (porting FreeReport) is not merely deferred, either: it was decided
permanently out of scope regardless of these gates — a standalone-
application-sized effort disproportionate to this port, with HTML template
export already covering the underlying "formatted report" need — see D6.

The remaining bulleted items above stay genuinely gated on Sprints 1–4's
evidence chain; they are not on the critical path to a defensible port claim
regardless of how much downstream work lands first.
