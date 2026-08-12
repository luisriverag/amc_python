# Port progress audit

**Audit date:** 2026-08-12  
**Audited commit:** `ba6cb42`  
**Method:** source review, documentation-claim comparison, CLI enumeration, and the
complete automated test suite. The upstream archive was not available to the audit,
so no claim of behavioral parity with Ant Movie Catalog can be verified.

## Executive conclusion

The repository is a functioning **prototype catalog application**, but the actual
Ant Movie Catalog port is still at the preparation stage. Internal JSON behavior and
basic in-memory operations have useful automated coverage. XML and CSV support are
based on synthetic examples. Native `.amc`, catalog metadata, pictures, scripts,
media inspection, loans, localization, printing, and upstream GUI workflows are not
ported.

Two progress measures are tracked deliberately:

| Measure | Result | Meaning |
|---|---:|---|
| Prototype implementation | 10 modules/tools, 25 passing tests | Python foundation exists |
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
| XML prototype | Selected attributes/elements, primitive conversion, export | Synthetic import and self-round-trip tests | Low for AMC compatibility |
| Inspection | JSON/XML/CSV identification and counts | API and CLI tests | Moderate for tested formats |
| Validation | Stable diagnostics and CLI exit status | API and CLI tests | Moderate for tested failures |
| Source acquisition tool | Streaming download, digest, extraction selection, inventory | Local HTTP and synthetic inventory tests | High for tested behavior |

### Present but inadequately tested

| Area | Current state | Missing evidence |
|---|---|---|
| GUI | Minimal Tk list and six-field editor | No controller/widget tests; no display smoke run |
| Installed CLI | Entry point declared; functions tested in-process | No subprocess contract tests from an installed wheel |
| Packaging | Setuptools metadata and `py.typed` | No wheel/sdist build-and-install test |
| CI | Workflow configured for Linux/Windows and Python 3.10–3.13 | No run result is stored in the repository |
| Atomic CSV/XML | Shared atomic writer | No injected serialization or replacement failure tests |
| Large-file behavior | XML uses iterative inspection | No resource-limit or performance tests |

### Not ported

- Native `.amc` read or write.
- Catalog-level records, preferences, and user-defined field definitions.
- Lossless preservation of repeated/ordered/typed unknown fields.
- Embedded and external picture semantics.
- Upstream website scripts and scripting runtime.
- Media-file analysis.
- Loan history and borrower workflows.
- Localization resources.
- Printing and reports.
- Full desktop workflows and upstream UI parity.

## Findings requiring correction

### Critical blockers

1. **The authoritative source archive is unavailable.** Its version, checksum,
   license, source units, and native format implementation remain unknown.
2. **The declared package license is unverified.** `pyproject.toml` declares
   GPL-2.0-or-later, but no reviewed upstream license or repository `LICENSE` exists.
3. **There are no upstream-generated fixtures.** Consequently XML/CSV compatibility
   and all upstream parity claims remain unverified.
4. **Native `.amc` behavior is intentionally blocked.** This is correct until the
   source or genuine fixtures establish its signature and structure.

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
7. Atomic replacement is tested for JSON serialization failure only. Directory
   durability, permission errors, concurrent writers, and CSV/XML failures remain
   untested.
8. Expected errors are partly represented by public exceptions and partly by built-in
   `ValueError`, `TypeError`, and `KeyError`; the documented error model is incomplete.

## Requirement traceability

| Port requirement | Code | Tests | Upstream evidence | Status |
|---|---|---|---|---|
| Acquire/inventory source | `tools/acquire_upstream.py` | `test_acquire_upstream.py` | Download blocked | Tool complete; acquisition blocked |
| Native header probe | Explicit refusal in `inspection.py` | Refusal test | None | Blocked |
| Native catalog reader | None | None | None | Not started |
| Native catalog writer | None | None | None | Not started |
| Internal working format | `storage.py`, JSON v1 spec | `test_amc.py` | Not applicable | Implemented |
| AMC XML reader/writer | `storage.py` | Synthetic tests | None | Prototype only |
| AMC CSV reader/writer | `storage.py` | Synthetic tests | None | Prototype only |
| Catalog operations | `catalog.py` | Direct tests | None | Prototype only |
| CLI adapter | `cli.py` | In-process tests | None | Partial |
| Desktop adapter | `gui.py` | None | None | Prototype only |
| Scripts/media/pictures/loans | Flat placeholders or none | None | None | Not started |

## Next audited milestone

Do not expand CRUD or claim additional AMC compatibility. The next milestone is:

1. Run `python tools/acquire_upstream.py --extract-to upstream/source` from a network
   permitted to access the supplied server.
2. Record archive provenance and review the license before copying upstream code.
3. Complete the source-unit inventory and locate native persistence code.
4. Produce an empty and a one-movie catalog with the matching upstream release.
5. Register fixture provenance and hashes.
6. Write signature, version, and truncation tests from that evidence.
7. Implement only a read-only native header probe and update this audit.

## Audit reproduction

```console
git status --short --branch
git log --oneline --decorate -8
python -m pytest -q
python -m compileall -q src tests tools
PYTHONPATH=src python -m amc.cli --help
git diff --check
```
