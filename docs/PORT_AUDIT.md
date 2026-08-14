# Port progress audit

**Audit date:** 2026-08-13
**Audited commit:** `0575daa` plus this review

**Method:** source review, documentation-claim comparison, CLI enumeration, the
complete automated test suite, and inspection of the checked-in Delphi source
snapshot. The supplied archives exactly match all 952 expanded files, but their
origin lacks independent publisher authentication and upstream-generated fixtures
are not available, so no claim of behavioral parity with Ant Movie Catalog can be
verified.
The user has designated the checked-in Delphi files as the authoritative source
baseline for continued implementation; that decision does not independently
authenticate the archives or create genuine compatibility fixtures.

## Executive conclusion

The repository is a functioning **prototype catalog application**, not a verified
drop-in Ant Movie Catalog port. Internal JSON behavior, catalog operations, the
application service, and guarded CLI workflows have useful automated coverage.
Native `.amc` parsing/writing, XML, CSV, metadata, and embedded-picture retention
are implemented from source or synthetic examples but lack genuine upstream
fixtures. Safe subsets also exist for HTML export, media discovery, PCM WAV
inspection, non-executing script metadata, desktop/web presentation, and loans.
Script execution, localization, printing, and full
upstream desktop workflows are not ported. Python-owned borrower/history metadata
is deliberately distinguished from upstream file-format compatibility.

Two progress measures are tracked deliberately:

| Measure | Result | Meaning |
|---|---:|---|
| Prototype implementation | 14 functional package modules, 4 repository tools, 317 passing tests | Python foundation and guarded prototype features exist |
| Source-analysis progress | 952 checked-in upstream/component files; 13 subsystem mappings | Archive/tree identity is established; detailed per-file review is incomplete |
| Upstream port verification | 0 upstream-derived fixtures; 0 verified upstream subsystems | Port parity is not established |

Line count and test count must not be used as a substitute for upstream
compatibility evidence.

### Confidence vocabulary

- **Internal:** behavior belongs to AMC Python and is tested against its documented
  contract; it makes no upstream claim.
- **Source-derived:** implementation is traced to identified Delphi units and
  symbols, but has no genuine upstream-produced fixture or cross-application run.
- **Upstream-verified:** a provenance-registered upstream artifact or application
  run demonstrates the claimed behavior. No subsystem currently meets this bar.

The tables below apply these meanings narrowly. A row may have high confidence in
an internal safety property while still having low or zero AMC compatibility
confidence.

## Evidence inventory

### Implemented and covered by automated tests

| Area | Implementation | Evidence | Confidence |
|---|---|---|---|
| Movie value object | Common flat fields, dictionary conversion, primitive validation | Direct/JSON validation and round-trip tests | Moderate for internal use |
| Catalog collection | Add/get/remove, search, sort, renumber, merge, statistics | Direct unit-style tests | Moderate for internal use |
| Internal JSON v1 | Load/save, envelope/version checks, atomic replacement | Round-trip, future-version, and failed-serialization tests | High for tested cases |
| CSV prototype | Header aliases, primitive conversion, custom columns, export | Synthetic round-trip test | Low for AMC compatibility |
| XML prototype | Movies, catalog properties, custom-field definitions, export | Synthetic import and metadata round-trip tests | Low for AMC compatibility |
| Inspection | JSON/XML/CSV identification plus native 1.0–4.2 header probe | API and CLI tests | Moderate for synthetic cases |
| Validation | Stable diagnostics, native structural validation, CLI exit status | API and CLI tests, including corrupt native input | Moderate for synthetic cases |
| Source acquisition tool | Streaming download, digest, extraction selection, inventory | Local HTTP and synthetic inventory tests | High for tested behavior |
| Engineering checks | Canonical tests/compile/fixture checks plus isolated wheel install | Tool unit tests and installed console-script JSON smoke | High for tested environment |
| HTML prototype | Escaped static table with bounded document/row templates | Injection, marker, failure-preservation, and CLI tests | Moderate internally; no AMC template parity |
| Media prototype | File discovery/facts and PCM WAV duration/bitrate | File, WAV, bounds, filtering, recursive, and atomic CLI tests | Moderate for stated subset |
| Script inventory | Bounded non-executing Infos/options/parameters/permissions/static-name parser | Synthetic metadata, malformed-entry, ordering, CLI tests | Moderate for stated subset |
| Application service | Failure-atomic CRUD, merge, media import, loans, undo/redo, backup/restore, and export orchestration | Mutation-failure, persistence, history, and adapter tests | High for tested internal workflows |
| Loan prototype | Single/batch, media-label, and retained-native-number group transitions; managed borrowers; JSON history; source-shaped TSV export | Unit/service/CLI/GUI tests, including atomic conflicts and output preservation | Moderate internally; upstream encoding/behavior unverified |
| Web prototype | Read-only table, gallery, details, bounded posters, pagination, search, and safe links | HTTP, escaping, reload, MIME, bounds, and security-header tests | Moderate for stated read-only subset |
| Picture prototype | Linked and byte/pixel-bounded validated embedded set/clear/crop, JSON/native retention, and atomic export | Service/CLI/native tests, including malformed image, crop/bounds, and failure preservation | Moderate internally; upstream path/conversion semantics unverified |

### Present but inadequately tested

| Area | Current state | Missing evidence |
|---|---|---|
| GUI | Tk catalog manager with file workflows, CRUD, filters, details/posters, loans, undo/redo, statistics, and duplicates | Headless controller/dialog tests; no real-display smoke run or broad widget integration suite |
| Installed CLI | Wheel console script and module entry point smoke-tested; empty JSON list exact output checked | Broader installed command contracts remain missing |
| Packaging | Wheel build, isolated install, license inclusion, and smoke checks | Source-distribution build/install remains missing |
| CI | Workflow configured for Linux/Windows and Python 3.10–3.13 | No run result is stored in the repository |
| Atomic CSV/XML | Shared atomic writer | Injected codec-failure preservation tests cover both formats |
| Large-file behavior | XML uses iterative inspection | No resource-limit or performance tests |

### Not ported

- Verified native `.amc` write compatibility (a source-derived 4.2 writer exists).
- Verified native read compatibility for any version.
- Catalog preferences beyond retained catalog/custom-field metadata.
- Lossless preservation of repeated/ordered/typed unknown fields.
- Verified upstream external/embedded picture path and conversion semantics.
- Upstream website script execution and scripting runtime (metadata inventory only).
- Full media analysis and codec mapping (portable facts and PCM WAV only).
- Upstream verification of grouped-loan and TSV history encoding/consumption.
- Localization resources.
- Printing and reports.
- Full desktop workflows and upstream UI parity.

## Findings requiring correction

### Critical blockers

1. **Archive identity is recorded, but publisher authentication is incomplete.**
   The supplied RAR and ZIP have recorded source-page claims, byte sizes, SHA-256
   digests, and exact 876-file and 76-file expanded-tree matches. Their precise
   download time and an independently published checksum are unavailable. See the
   archive provenance record for the reproducible facts and remaining limitation.
2. **Source-snapshot redistribution clearance remains incomplete.** A root
   GPLv2 `LICENSE` and an initial component notice inventory now exist, but the
   review found an ElTree license that does not permit source redistribution and
   unresolved per-file review for `Common` and `antcomponents`. See
   `THIRD_PARTY_NOTICES.md`; these are release blockers, not inferred clearance.
3. **There are no upstream-generated fixtures.** Consequently XML/CSV compatibility
   and all upstream parity claims remain unverified.
4. **Native `.amc` verification is blocked, not implementation.** A source-derived
   1.0–4.2 reader now exists, but it has only synthetic byte fixtures. Encoding,
   compiler-layout assumptions, version behavior, and malformed-file compatibility
   cannot be claimed until upstream-generated catalogs are registered.

### Design and quality debt

1. `storage.py` combines dispatch, three codecs, and atomic filesystem behavior; it
   should be split after genuine fixtures establish codec contracts.
2. The shared application service now owns major CLI/GUI mutations and persistence,
   but storage codecs remain concrete functions rather than repository interfaces;
   some adapter-specific presentation and argument translation is necessarily local.
3. `Movie` now applies primitive type and finite-number validation to direct and JSON
   construction. Semantic constraints for most upstream fields remain unknown.
4. XML custom data is flattened into a dictionary, losing repeated names, ordering,
   attributes, and nested structure.
5. CSV dialect, locale, empty-value, duplicate-header, and malformed-row behavior is
   not defined from upstream evidence.
6. Inspection parses complete JSON documents merely to count records; large-catalog
   resource bounds are not defined.
7. Atomic replacement now has injected serialization-failure coverage for JSON,
   CSV, and XML. Directory durability, permission errors, and concurrent writers remain
   untested. A generic injected replacement failure is covered.
8. Expected errors are partly represented by public exceptions and partly by built-in
   `ValueError`, `TypeError`, and `KeyError`; the documented error model is incomplete.
9. The Python native reader deliberately reports truncated records, unlike upstream
   `ReadData`, which catches a movie-record exception and stops. This intentional
   difference needs fixture-backed documentation and stable diagnostics.
10. Upstream `ReadHeader` is only a fixed-length preview: it returns file size and
    trims at a line break but does not validate a native signature. The Python probe
    correctly uses explicit versioned constants and `LoadFromFile` dispatch, but
    fixture cross-checking remains outstanding.
11. XML catalog properties and custom-field definitions are now retained, but
    unknown nested structures and typed values are still normalized into the
    Python metadata representation and have no upstream-generated fixture coverage.
12. Native strings default to CP-1252, version comparisons are textual, and Delphi
    primitive/layout assumptions are encoded directly. They are plausible from the
    source snapshot but not established across compiler settings or real catalogs.
13. Native reads bound file size, movies, individual/cumulative pictures, cumulative
    strings, custom fields/list values, and supplementary records. Exhaustive
    synthetic fixed-record truncations and a seeded 4.2 byte-mutation corpus now
    require bounded public outcomes. Base64 amplification, a property framework,
    and genuine-fixture mutation coverage remain outstanding.
14. Native writes now bound output bytes, cumulative encoded-string bytes, movies,
    individual/cumulative pictures, custom fields/list values, and supplementary
    records before destination replacement. Genuine upstream acceptance remains
    untested.
15. Native-only fields and supplementary records use reserved dictionary keys rather
    than typed format-neutral models, making collisions and merge semantics unclear.
16. `Catalog.metadata` is JSON-validated, deep-copied, and merged atomically with
    `error`, `keep`, `replace`, and `namespace` policies. Nested semantic merging is
    intentionally not performed; genuine interchange verification remains absent.
17. Loan history timestamps are Python-owned timezone-aware ISO-8601 values. The
    optional legacy export converts them to local time and UTF-8 TSV, while upstream
    writes Delphi local time through the process code page; genuine comparison is
    still required.
18. Managed borrower removal intentionally rejects names with active loans, unlike
    upstream `loan.pas`, which clears every matching `strBorrower`. This safer
    divergence is documented but not an upstream-parity behavior.
19. `storage.py` combines JSON, CSV, XML, native dispatch, metadata translation,
    and atomic writes. Codec separation is urgent once genuine fixtures lock contracts.
20. Review fixed native validation so structural parse failures return diagnostics
    instead of escaping `validate_catalog` and becoming CLI usage errors.

## Requirement traceability

| Port requirement | Code | Tests | Upstream evidence | Status |
|---|---|---|---|---|
| Acquire/inventory source | `tools/acquire_upstream.py` | `test_acquire_upstream.py` | Supplied archives exactly match the 952-file snapshot; publisher authentication is unavailable | Archive/tree identity confirmed; acquisition timestamp and independent digest pending |
| Native header probe | Source-derived 1.0–4.2 recognition in `inspection.py` | All ten headers, truncation, unknown-version, CLI, and warning tests | Constants and dispatch in `movieclass.pas` | Implemented from source; genuine fixtures pending |
| Native catalog reader | `native.py`, storage/CLI import | Source-derived synthetic happy/error tests | `TMovieList.LoadFromFile`, `ReadRecords`, fixed records, `ReadData`, pictures/custom/extras | 1.0–4.2 implemented; no genuine verification |
| Native catalog writer | `native.py`, `storage.py`, `export-amc` | Synthetic round trip; atomic failure; malformed metadata/rating/separator; invalid-limit; encoded-string; full service/CLI budget and resource tests | `TMovieList.SaveToFile` and nested `WriteData` methods | Strict bounded configurable 4.2 writer implemented from source; upstream acceptance unverified |
| Internal working format | `storage.py`, JSON v1 spec | `test_amc.py` | Not applicable | Implemented |
| AMC XML reader/writer | `storage.py` | Synthetic tests | None | Prototype only |
| AMC CSV reader/writer | `storage.py` | Synthetic tests | None | Prototype only |
| Catalog operations | `catalog.py` | Direct tests | None | Prototype only |
| CLI adapter | `cli.py` | In-process tests plus installed entry-point/JSON smoke | None | Partial |
| Desktop adapter | `gui.py`, `application.py` | Headless controller/dialog and service tests | Source workflows located; no display/genuine workflow fixture | Broad prototype; no upstream UI parity |
| Scripts/media/HTML | `scripts.py`, `media.py`, `storage.py` | Synthetic bounded subset tests | `getscript_readscripts.pas`, `getmedia.pas`, `export.pas` | Prototype subsets; no execution/provider/template parity |
| Pictures/loans | Linked/embedded picture set/clear/export and native retention; current borrower; managed list; JSON history; TSV export; opt-in loan groups | Synthetic unit/service/CLI/GUI/native tests | `TMoviePicture` in `movieclass.pas`; `loan.pas`; `loanhistory.pas` characterized | Source-derived prototypes pending genuine picture/loan verification |

## Next audited milestone

Do not claim additional AMC compatibility without fixture evidence. The next
implementation milestone is:

1. Produce empty and one-movie catalogs with upstream 4.2.3.2, register their
   producer/version/creation provenance and hashes, and obtain redistribution
   permission for the fixture bytes.
2. Cross-check native header, metadata offsets, movie count, reader output, and the
   explicit 4.2 writer against those fixtures; document every normalized or
   unsupported field.
3. Add broader malformed-metadata/property tests to the native writer.
4. Resolve the documented ElTree redistribution blocker and complete the
   per-file `Common` and `antcomponents` license review.
5. Only after those evidence gates, continue format behavior or claim compatibility.

## Audit reproduction

```console
python -m pip install -e .[dev]
git status --short --branch
git log --oneline --decorate -8
python tools/check.py
python tools/check_package.py
```

Observed for this audit:

| Command/check | Result |
|---|---|
| `python tools/check.py` | 317 tests passed; 85% aggregate branch coverage; Ruff, compilation, fixture-manifest validation, and source CLI help passed |
| `python tools/check_package.py` | Wheel built and installed into an isolated environment; module and `amc`, `amc-gui`, and `amc-web` entry-point smoke checks passed |
| `python tools/validate_fixtures.py` | 0 manifests validated, confirming the compatibility-fixture gap rather than compatibility |
| `git diff --check` | Passed |

The source-tree check applies focused Ruff diagnostics and an 80% aggregate branch
coverage floor. It does not run a formatter or static type checker. The packaging
check is intentionally separate because it builds and installs an isolated wheel
rather than importing from `src/`.
