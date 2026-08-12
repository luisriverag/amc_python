# Compatibility matrix

Statuses: **unsupported**, **investigating**, **prototype**, **partial**, **verified**,
or **intentionally omitted**. A prototype has local behavior but no upstream
evidence. “Verified” for an upstream format requires an upstream-generated fixture
and a documented cross-application test; synthetic tests alone qualify only as
partial. “Verified (internal only)” applies solely to Python-owned contracts.

| Capability | Status | Evidence | Next action |
|---|---|---|---|
| Internal JSON v1 read/write | verified (internal only) | Format specification and semantic round trip | Add full schema validation |
| Atomic output replacement | partial | JSON, CSV, and XML serialization failures plus an injected replacement failure | Test permissions, durability, and concurrency |
| Native `.amc` read | investigating | Source-derived headers/properties, 4.0–4.2 custom fields, 3.1–4.2 rows/extras, and metadata/image-preserving native→JSON import with header-based detection; no genuine fixtures | Generate authenticated fixtures, cross-check every version, and add remaining cumulative limits |
| Non-destructive inspection/validation | partial | JSON/XML/CSV inspection plus source-derived native 1.0–4.2 header probe | Validate native records after genuine fixtures exist |
| Native `.amc` write | unsupported | `TMovieList.SaveToFile` located; no Python implementation or fixtures | Defer until native reader is verified |
| AMC XML read | partial | Synthetic movie, catalog-property, and custom-field-definition tests | Add real 3.x/4.x exports |
| AMC XML write | partial | Synthetic movie and metadata self round trip | Import generated output in upstream AMC |
| CSV read/write | partial | Synthetic round trip | Add upstream locale/delimiter fixtures |
| Unknown XML fields | partial | Scalar custom values round trip; structured values are rejected rather than flattened | Preserve repetition/order/type/attributes |
| Pictures | unsupported | `TMoviePicture` source located; Python model stores a string only | Characterize embedded/external semantics from source and fixtures |
| Catalog metadata | investigating | Native/XML properties retained in validated, deep-copied JSON metadata | Cross-check fixtures and define configurable merge policies |
| Custom-field definitions | investigating | Native and XML definitions retained in JSON metadata | Cross-check genuine fixtures and typed-value behavior |
| Website scripts | unsupported | `getscript*` and bundled IFPS units located | Inventory exposed APIs and decide compatibility boundary |
| Media analysis | unsupported | `getmedia.pas` and `Common/MediaInfo.pas` located; flat Python values only | Map upstream analyzers |
| Loans | unsupported | `loan.pas` and `loanhistory.pas` located; current borrower string only | Map loan/history model |
| CLI CRUD | partial | In-process function tests | Add installed subprocess contract tests |
| Desktop GUI | prototype | No automated GUI evidence | Extract services and add controller tests |
| Localization | unsupported | Upstream language/help assets located; Python strings are inline English | Inventory resource formats and supported locales |
| Printing/reports | unsupported | `printform.pas`, `amcreport/`, and bundled FreeReport located | Decide port/omission after behavior and license review |

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
