# Port progress audit

**Audit date:** 2026-08-12  
**Audited commit:** `bb58fd7` plus this review

**Method:** source review, documentation-claim comparison, CLI enumeration, the
complete automated test suite, and inspection of the checked-in Delphi source
snapshot. Archive-level provenance and upstream-generated fixtures were not
available, so no claim of behavioral parity with Ant Movie Catalog can be verified.

## Executive conclusion

The repository is a functioning **prototype catalog application**, but the actual
Ant Movie Catalog port is still at the source-analysis stage. Internal JSON
behavior and
basic in-memory operations have useful automated coverage. XML and CSV support are
based on synthetic examples. Native `.amc` parsing, catalog metadata, and
embedded-picture retention are implemented from the checked-in source but remain
unverified. Scripts, media inspection, loans, localization, printing, and upstream
GUI workflows are not ported.

Two progress measures are tracked deliberately:

| Measure | Result | Meaning |
|---|---:|---|
| Prototype implementation | 9 package modules, 1 acquisition tool, 70 passing tests | Python foundation exists |
| Source-analysis progress | 952 checked-in upstream/component files; 13 initial unit mappings | Source is available for study, but provenance is incomplete |
| Upstream port verification | 0 upstream-derived fixtures; 0 verified upstream subsystems | Port parity is not established |

Line count and test count must not be used as a substitute for upstream
compatibility evidence.

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

### Present but inadequately tested

| Area | Current state | Missing evidence |
|---|---|---|
| GUI | Minimal Tk list and six-field editor | No controller/widget tests; no display smoke run |
| Installed CLI | Entry point declared; functions tested in-process | No subprocess contract tests from an installed wheel |
| Packaging | Setuptools metadata and `py.typed` | No wheel/sdist build-and-install test |
| CI | Workflow configured for Linux/Windows and Python 3.10–3.13 | No run result is stored in the repository |
| Atomic CSV/XML | Shared atomic writer | Injected codec-failure preservation tests cover both formats |
| Large-file behavior | XML uses iterative inspection | No resource-limit or performance tests |

### Not ported

- Native `.amc` write and fixed-record 1.0–3.0 read.
- Verified native read compatibility for any version.
- Catalog preferences beyond retained catalog/custom-field metadata.
- Lossless preservation of repeated/ordered/typed unknown fields.
- Verified external picture copy/link semantics.
- Upstream website scripts and scripting runtime.
- Media-file analysis.
- Loan history and borrower workflows.
- Localization resources.
- Printing and reports.
- Full desktop workflows and upstream UI parity.

## Findings requiring correction

### Critical blockers

1. **The checked-in source snapshot has incomplete provenance.** Its original
   archive URL, retrieval time, byte size, and digest were not committed. The
   project metadata identifies version 4.2.3.2 and the bundled readme says the
   application source is GPL, but the snapshot identity cannot be independently
   tied to a downloaded archive.
2. **Repository licensing remains incomplete.** `pyproject.toml` declares
   GPL-2.0-or-later and the upstream tree contains GPL notices and a GPLv2 text, but
   there is no root `LICENSE`, attribution review, or dependency-license summary.
3. **There are no upstream-generated fixtures.** Consequently XML/CSV compatibility
   and all upstream parity claims remain unverified.
4. **Native `.amc` verification is blocked, not implementation.** A source-derived
   3.1–4.2 reader now exists, but it has only synthetic byte fixtures. Encoding,
   compiler-layout assumptions, version behavior, and malformed-file compatibility
   cannot be claimed until upstream-generated catalogs are registered.

### Design and quality debt

1. `storage.py` combines dispatch, three codecs, and atomic filesystem behavior; it
   should be split after genuine fixtures establish codec contracts.
2. CLI and GUI directly implement mutations and persistence rather than sharing an
   application service layer.
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
13. Native reads now bound file size, movie count, individual pictures, and
    cumulative picture bytes. Strings are individually bounded, but cumulative
    string/metadata memory and base64 amplification remain unbounded.
14. Native-only fields and supplementary records use reserved dictionary keys rather
    than typed format-neutral models, making collisions and merge semantics unclear.
15. `Catalog.metadata` is now JSON-validated, deep-copied, and merged atomically,
    but conflict policy remains top-level `error` only; namespace/keep/replace and
    nested merge semantics are not defined.
16. `storage.py` now combines JSON, CSV, XML, native dispatch, metadata translation,
    and atomic writes. Codec separation is urgent once genuine fixtures lock contracts.
17. Review fixed native validation so structural parse failures return diagnostics
    instead of escaping `validate_catalog` and becoming CLI usage errors.

## Requirement traceability

| Port requirement | Code | Tests | Upstream evidence | Status |
|---|---|---|---|---|
| Acquire/inventory source | `tools/acquire_upstream.py` | `test_acquire_upstream.py` | Unauthenticated source snapshot checked in | Tool complete; reproducible acquisition/provenance pending |
| Native header probe | Source-derived 1.0–4.2 recognition in `inspection.py` | All ten headers, truncation, unknown-version, CLI, and warning tests | Constants and dispatch in `movieclass.pas` | Implemented from source; genuine fixtures pending |
| Native catalog reader | `native.py`, storage/CLI import | Source-derived synthetic happy/error tests | `TMovieList.LoadFromFile`, `ReadData`, `ReadString`, picture/custom/extra readers | 3.1–4.2 implemented; no genuine verification |
| Native catalog writer | None | None | `TMovieList.SaveToFile` located | Not started |
| Internal working format | `storage.py`, JSON v1 spec | `test_amc.py` | Not applicable | Implemented |
| AMC XML reader/writer | `storage.py` | Synthetic tests | None | Prototype only |
| AMC CSV reader/writer | `storage.py` | Synthetic tests | None | Prototype only |
| Catalog operations | `catalog.py` | Direct tests | None | Prototype only |
| CLI adapter | `cli.py` | In-process tests | None | Partial |
| Desktop adapter | `gui.py` | None | None | Prototype only |
| Scripts/media/pictures/loans | Flat placeholders or none | None | None | Not started |

## Next audited milestone

Do not expand CRUD or claim additional AMC compatibility. The next milestone is:

1. Reacquire the published archive with `tools/acquire_upstream.py` and record its
   URL, retrieval time, size, and SHA-256 digest.
2. Compare its extracted inventory with `src/original/` and `src/antcomponents/`;
   document or remove every discrepancy.
3. Complete license and attribution review and add repository-level notices.
4. Produce empty and one-movie catalogs with upstream 4.2.3.2.
5. Register fixture provenance and hashes.
6. Derive signature, version, and truncation tests from `movieclass.pas`.
7. Cross-check the completed read-only native header probe against those fixtures.

## Audit reproduction

```console
git status --short --branch
git log --oneline --decorate -8
python -m pytest -q
python -m compileall -q src tests tools
PYTHONPATH=src python -m amc.cli --help
git diff --check
```
