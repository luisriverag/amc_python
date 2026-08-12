# Compatibility matrix

Statuses: **unsupported**, **investigating**, **prototype**, **partial**, **verified**,
or **intentionally omitted**. A prototype has local behavior but no upstream
evidence. “Verified” for an upstream format requires an upstream-generated fixture
and a documented cross-application test; synthetic tests alone qualify only as
partial. “Verified (internal only)” applies solely to Python-owned contracts.

| Capability | Status | Evidence | Next action |
|---|---|---|---|
| Internal JSON v1 read/write | verified (internal only) | Format specification and semantic round trip | Add full schema validation |
| Atomic JSON replacement | partial | Success and JSON serialization-failure preservation tests | Test CSV/XML, permissions, durability, concurrency |
| Native `.amc` read | unsupported | None | Inventory upstream native reader |
| Non-destructive inspection/validation | partial | JSON/XML/CSV API and CLI tests | Add upstream-derived `.amc` header probe |
| Native `.amc` write | unsupported | None | Defer until native reader is verified |
| AMC XML read | partial | Synthetic attribute/element tests | Add real 3.x/4.x exports |
| AMC XML write | partial | Synthetic self-round trip | Import generated output in upstream AMC |
| CSV read/write | partial | Synthetic round trip | Add upstream locale/delimiter fixtures |
| Unknown XML fields | partial | Single synthetic element | Preserve repetition/order/type/attributes |
| Pictures | unsupported | Model stores a string only | Determine embedded/external semantics |
| Catalog metadata | unsupported | None | Inventory catalog-level records |
| Custom-field definitions | unsupported | Flat `extras` only | Model upstream definitions and types |
| Website scripts | unsupported | None | Inventory scripting runtime and APIs |
| Media analysis | unsupported | Flat media values only | Map upstream analyzers |
| Loans | unsupported | Current borrower string only | Map loan/history model |
| CLI CRUD | partial | In-process function tests | Add installed subprocess contract tests |
| Desktop GUI | prototype | No automated GUI evidence | Extract services and add controller tests |
| Localization | unsupported | English strings are inline | Inventory upstream language resources |
| Printing/reports | unsupported | None | Decide port/omission after inventory |

## Supported Python environments

Python 3.10 and newer is declared. A Linux and Windows workflow is configured for
Python 3.10–3.13; this repository does not contain evidence of a completed hosted CI
run. Tk is optional at runtime in practice but is not yet modeled as a package extra
or checked before launching the GUI.

The detailed evidence and gap analysis is maintained in
[`PORT_AUDIT.md`](PORT_AUDIT.md).

## Updating this file

Every compatibility change must include:

1. Fixture provenance.
2. Automated tests and exact commands.
3. Supported upstream versions.
4. Known lossy fields or behavior.
5. A status change justified in the pull request.
