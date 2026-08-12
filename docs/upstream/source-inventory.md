# Upstream source inventory

This file is intentionally a fillable inventory. It must be completed from the
actual `amc_sources.rar` archive before source-port claims are made.

## Current acquisition and mapping status

**No upstream source code has been downloaded or extracted in this repository.**
The ignored `upstream/` working directory is absent, there is no archive metadata
or generated file inventory, and the unit table below contains no source units.
Consequently, **none of the Python modules has been mapped to an authoritative
upstream unit yet**. The implementation and compatibility documents describe a
clean-room prototype and a proposed target architecture; they are not evidence of
a completed source-to-source port.

The following artifacts provide an unambiguous completion checklist:

| Artifact | Expected location | Current state |
|---|---|---|
| Downloaded archive | `upstream/amc_sources.rar` | absent |
| Archive provenance and digest | `upstream/archive.json` | absent |
| Extracted source tree | `upstream/source/` | absent |
| Generated file inventory | `upstream/inventory.json` | absent |
| Reviewed unit-to-module map | unit inventory in this document | empty |
| Upstream-derived fixtures | `tests/fixtures/upstream/` | absent |

Do not interpret the acquisition utility, this template, or the compatibility
matrix as proof that acquisition or mapping has occurred.

## Archive identity

| Property | Value |
|---|---|
| Download URL | `https://update.antp.be/amc/amc_sources.rar` |
| Retrieved at | **pending** |
| Byte size | **pending** |
| SHA-256 | **pending** |
| Product version | **pending** |
| Source language/compiler | **pending** |
| License/copyright | **pending review** |
| Redistribution allowed | **pending review** |

The execution environment returned HTTP 403 when the archive was requested. Obtain
it through an allowed channel, verify its digest, and do not guess its contents.
The reproducible acquisition command is:

```console
python tools/acquire_upstream.py --extract-to upstream/source
```

Generated archive metadata and the extracted tree remain ignored until license and
redistribution review is complete.

## Unit inventory

For every extracted unit add a row. Never delete upstream units from this table;
mark them intentionally omitted with a reason instead.

| Upstream path/unit | Responsibility | Python target | Status | Tests/fixtures | Notes |
|---|---|---|---|---|---|
| **pending extraction** | — | — | not started | — | — |

## Required subsystem discovery

- [ ] Application startup and configuration
- [ ] Domain records and field definitions
- [ ] Native `.amc` reader
- [ ] Native `.amc` writer
- [ ] XML import/export
- [ ] CSV import/export
- [ ] Picture storage and conversion
- [ ] Website scripting runtime
- [ ] Media-file analysis
- [ ] Search, filtering, grouping, and sorting
- [ ] Loans/borrowers
- [ ] Printing and templates
- [ ] Localization
- [ ] Preferences and UI state
- [ ] Forms and user workflows
- [ ] Update mechanism

## Behavior characterization template

Copy this section for each behavior:

```markdown
### Behavior name

- Upstream units and symbols:
- Supported upstream versions:
- Inputs and defaults:
- Output/side effects:
- Error behavior:
- Version differences:
- Golden fixtures:
- Python tests:
- Intentional differences:
```
