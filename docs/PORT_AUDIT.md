# Port progress audit

**Audit date:** 2026-08-14
**Audited commit:** `510d171` plus this documentation review

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
fixtures. Safe subsets also exist for HTML export, media discovery, PCM WAV,
FLAC, and AIFF inspection, non-executing script metadata and public settings,
desktop/web presentation, and loans.
Script execution, localization, printing, and full
upstream desktop workflows are not ported. Python-owned borrower/history metadata
is deliberately distinguished from upstream file-format compatibility.

Two progress measures are tracked deliberately:

| Measure | Result | Meaning |
|---|---:|---|
| Prototype implementation | 15 functional package modules, 6 repository tools, 367 passing tests | Python foundation and guarded prototype features exist |
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
| Media prototype | File discovery/facts and PCM WAV/FLAC/AIFF duration/bitrate; CLI `import-media --progress` reporting and a GUI Import Media dialog (file or recursive-folder selection) with the same atomic-after-inspection guarantee | File, WAV, FLAC, AIFF, bounds, filtering, recursive, progress-output, interrupted-scan, and atomic CLI/GUI tests | Moderate for stated subset |
| Script inventory/settings | Bounded non-executing Infos/options/parameters/permissions/static-name parser; validated option/parameter overrides; atomic Python JSON settings | Synthetic metadata, malformed-entry, configuration, persistence, and CLI tests | Moderate for the stated non-executing subset; no runtime parity |
| Application service | Failure-atomic CRUD, merge, media import, loans, undo/redo, backup/restore, and export orchestration | Mutation-failure, persistence, history, and adapter tests | High for tested internal workflows |
| Loan prototype | Single/batch, media-label, and retained-native-number group transitions; managed borrowers; JSON history; source-shaped TSV export | Unit/service/CLI/GUI tests, including atomic conflicts and output preservation | Moderate internally; upstream encoding/behavior unverified |
| Web prototype | Read-only poster table/gallery, expanded details, bounded posters, pagination, search, and safe links | HTTP, escaping, reload, MIME, bounds, and security-header tests | Moderate for stated Python extension; upstream has no corresponding web server |
| Picture prototype | Linked and byte/pixel-bounded validated embedded set/clear/crop, interactive drag-to-select cropping in the desktop edit dialog and each Assign Pictures row, atomic batch set/clear with per-movie crop rectangles across an extended selection (distinct or shared picture/crop per movie), JSON/native retention, and atomic export | Service/CLI/GUI/native tests, including malformed image, crop/bounds, per-movie crop overrides, batch set/clear atomicity, and failure preservation | Moderate internally; upstream path/conversion semantics unverified |
| GUI preferences | Platform-appropriate per-user JSON file for view filter, layout, window size, and configurable undo/redo history depth (editable from a toolbar Preferences dialog and validated through `CatalogService`), atomically written and validated field-by-field on load with default fallback for any missing/invalid data | Round-trip, corrupt-file, invalid-field, platform-path, and history-depth-bounding tests | High internally; AMC Python-only convenience with no upstream counterpart |

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
- Upstream website script compilation/execution, network/provider APIs, result
  selection and merge, license-acceptance workflow, debugging, and static session
  state (metadata and public settings only).
- Full media analysis and codec mapping (portable facts and PCM WAV/FLAC/AIFF only).
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
5. [Partially resolved] CSV dialect, locale, and empty-value behavior is still not
   defined from upstream evidence. Duplicate-header behavior is now defined and
   tested as a Python-owned policy (not an upstream-verified one): `load_csv`
   previously let `csv.DictReader` silently discard a column's data whenever two
   headers collapsed onto the same key (either two identical extras headers, or
   two headers, such as `Title`/`title`, that normalize to the same known movie
   field) — the earlier column's value vanished with no diagnostic. It now raises
   a clear `ValueError` identifying both colliding headers before any row is
   read, mirroring the JSON v1 decoder's duplicate-member rejection policy.
6. [Partially resolved] Inspection still parses complete JSON documents merely to
   count records (Python's standard `json` module has no incremental parser, and
   implementing one was judged not worth the complexity for a counting-only path).
   However, `inspect_catalog`/`validate_catalog` and the CLI `inspect`/`validate`
   `--max-input-bytes` option now reject an oversized file before that parse
   starts, matching the `NativeReadLimits`/`inspect_media` bound precedent used
   elsewhere; the previously-undefined resource bound is now defined and
   configurable (default 1 TiB). True streaming JSON record counting remains
   undone.
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
20. [Resolved] Fixed-record (1.0–3.0) native movie construction now wraps
    `Movie` value errors as `CorruptCatalogError` the same way the modern
    (3.1–4.2) reader already did, so a structural parse failure returns a
    `validate_catalog` diagnostic instead of escaping as an unwrapped
    exception and becoming a generic CLI usage error. Verified with tests
    that force the failure on both readers and confirm the diagnostic
    reaches `validate_catalog`; no currently constructible fixed-record byte
    sequence was found to trigger it under the present `Movie` validation
    rules, so this closes the defensive gap rather than a demonstrated
    exploit.
21. Pre-3.0 picture and borrower sidecars are implemented from
    `TMovieList.ReadPictures`/`ReadBorrowers`, but `ConfigParser` has not been shown
    equivalent to Delphi `TMemIniFile` for duplicate keys, comments, malformed INI,
    or locale-specific decoding. No genuine sidecar fixture exists.
22. [Resolved] JSON content saved under an `.amc` suffix is accepted for
    compatibility with earlier AMC Python releases. This is an internal
    migration behavior, not an Ant Movie Catalog format feature.
    `storage.load()`'s native/JSON content probe now reads the file prefix
    once and reuses it for both the native-header and JSON-start-byte
    checks, instead of opening the file twice. Fixing this also surfaced and
    closed a related bug: a leading UTF-8 BOM was recognized by the JSON
    probe but not stripped before the actual `json.load()` call, so a
    BOM-prefixed JSON catalog (under `.amc` or `.json`) failed to open with a
    confusing `JSONDecodeError` instead of loading; both `storage.load()` and
    `inspection._inspect_json()` now open JSON with `utf-8-sig`, which
    transparently strips a BOM when present and is otherwise identical to
    plain `utf-8`.
23. Script settings use an AMC Python JSON document and basename identity. Upstream
    caches script metadata, license acceptance, options, parameters, and static
    values in its settings INI. Python deliberately excludes license acceptance and
    static values and therefore cannot consume or reproduce that cache.
24. The script reader bounds the first read to 1 MiB, but currently rejects any
    script whose file prefix exceeds that size even when its metadata comment ends
    earlier. It does not compile Pascal, implement IFPS APIs, perform HTTP requests,
    or perform HTTP requests; it can validate isolated field-level merge previews.
25. The read-only web server, its poster table, and retained-file-path display are
    Python extensions. They must not be counted as upstream UI parity. AMC 4.2 file
    path, writer, composer, certification, user-rating, and color-tag values are now
    typed movie fields;
    genuine XML/native fixture comparison remains pending.

## Gap matrix against the original application

This matrix distinguishes a source-located feature from a completed port. “Subset”
means Python implements useful behavior but not the complete upstream workflow.

| Original subsystem | Upstream source | Python coverage | Remaining gap |
|---|---|---|---|
| Native catalog persistence | `movieclass.pas`, `movieclass_old.pas` | Source-derived 1.0–4.2 reads, legacy sidecar lookup, and experimental 4.2 writes | Genuine files for every version; code-page behavior; pre-3.0 sidecar verification; 3.5/4.1 writers; upstream open/save/reopen evidence |
| Movie and custom-field model | `movieclass.pas`, `fields.pas`, `customfieldsmanager.pas`, `extrasedit.pas` | Common scalar fields plus opaque metadata/extras retention | Typed writer/composer/certification/file-path and extra records; duplicate/order/type preservation; custom-field editing semantics and defaults |
| XML/CSV import and export | `movieclass.pas`, `import2*.pas`, `export.pas` | Synthetic XML/CSV codecs | Upstream dialect/locale fixtures, streaming/resource limits, repeated/nested unknown XML, and cross-application round trips |
| Main catalog workflows | `main.pas`, `sort.pas`, `filter*.pas`, forms | CRUD, merge, search, filters, sort, duplicate review, renumber, backup/restore | Full selection/group actions, preferences, progress/cancellation, unsaved-state workflows, and verified behavioral parity |
| Pictures | `TMoviePicture` in `movieclass.pas`, picture forms | Link/embed/clear/export/crop, bounded poster display, and atomic batch set/clear | Upstream import modes, naming/copy/move rules, conversion options, and genuine embedded/linked fixtures |
| Loans | `loan.pas`, `loanhistory.pas` | Atomic loan transitions, grouping options, managed names, history, TSV export | Upstream settings and dialogs, process-code-page TSV verification, deletion semantics, and genuine consumption tests |
| Website scripts | `getscript*.pas`, `ifps/` | Metadata, permissions, option/parameter configuration, Python JSON settings | IFPS compiler/runtime, complete API inventory, HTTP/browser interactions, license acceptance, debugger, results UI, safe merge preview, timeouts/cache/rate limits, and recorded provider tests |
| Media analysis | `getmedia.pas`, `Common/MediaInfo.pas` | Portable file facts and PCM WAV/FLAC/AIFF analysis | MediaInfo integration/version checks, the full tag map, stream selection, filters, and field merge behavior |
| HTML export | `export.pas`, template units | Safe bounded Python table/templates | Upstream template tags, multi-file output, extra/custom-field semantics, and fixture comparison |
| Preferences/localization | `programsettings.pas`, `languages/`, help | No compatible settings or language-resource loader | Settings XML, per-user state, localization resources, translated UI/help, and migration |
| Printing/reports | `printform.pas`, `amcreport/`, `FreeReport/` | Not ported | Report designer/runtime, preview, printing, templates, and dependency/license decision |
| Desktop presentation | `main.pas` and `.dfm` forms | Broad Tk prototype with headless adapter tests | Form/workflow parity, accessibility verification, localization, real-display tests, and platform packaging |
| Web presentation | No upstream server counterpart | Read-only AMC Python extension | Authentication/TLS deployment layer if exposed beyond localhost; it is intentionally outside parity accounting |

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
| Scripts | `scripts.py`, `configure-script` | Synthetic metadata, validation, persistence, and CLI tests | `getscript_readscripts.pas`, `getscript_properties.pas` | Metadata/public-settings subset; no IFPS execution, providers, results, or upstream cache parity |
| Media/HTML | `media.py`, `storage.py` | Synthetic bounded subset tests | `getmedia.pas`, `Common/MediaInfo.pas`, `export.pas` | Prototype subsets; no full codec or template parity |
| Pictures/loans | Linked/embedded picture set/clear/export and native retention; current borrower; managed list; JSON history; TSV export; opt-in loan groups | Synthetic unit/service/CLI/GUI/native tests | `TMoviePicture` in `movieclass.pas`; `loan.pas`; `loanhistory.pas` characterized | Source-derived prototypes pending genuine picture/loan verification |

## Next audited milestone

Do not claim additional AMC compatibility without fixture evidence. The ordered
near-term roadmap is maintained in [`NEXT_SPRINTS.md`](NEXT_SPRINTS.md). Its first
gate requires independently recorded source acquisition, resolution or exclusion of
the remaining redistribution blockers, and provenance manifests for genuine AMC
4.2.3.2 empty and one-movie catalogs plus their XML exports. Codec correction,
lossless interchange work, and release hardening follow only after their preceding
sprint exit checks pass.

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
| `python tools/check.py` | 367 tests passed; 82% aggregate branch coverage; Ruff, compilation, fixture-manifest validation, license-inventory validation, native-expectation verification, and source CLI help passed |
| `python tools/check_package.py` | Source distribution built and checked to exclude historical evidence trees; wheel built and installed into an isolated environment; module and `amc`, `amc-gui`, and `amc-web` entry-point smoke checks passed |
| `python tools/validate_fixtures.py` | 0 manifests validated, confirming the compatibility-fixture gap rather than compatibility |
| `git diff --check` | Passed |

The source-tree check applies focused Ruff diagnostics and an 80% aggregate branch
coverage floor. It does not run a formatter or static type checker. The packaging
check is intentionally separate because it builds and installs an isolated wheel
rather than importing from `src/`.
