# Compatibility matrix

Statuses: **unsupported**, **investigating**, **prototype**, **partial**, **verified**,
or **intentionally omitted**. A prototype has local behavior but no upstream
evidence. “Verified” for an upstream format requires an upstream-generated fixture
and a documented cross-application test; synthetic tests alone qualify only as
partial. “Verified (internal only)” applies solely to Python-owned contracts.

| Capability | Status | Evidence | Next action |
|---|---|---|---|
| Internal JSON v1 read/write | verified (internal only) | Format specification, semantic round trip, strict envelope/row validation, duplicate-key rejection, and finite JSON enforcement | Add an explicit version-migration framework before a v2 format is needed |
| Atomic output replacement | partial | JSON, CSV, and XML serialization failures plus an injected replacement failure | Test permissions, durability, and concurrency |
| Native `.amc` read | investigating | User-designated source baseline drives fixed-record 1.0–3.0 and modern 3.1–4.2 parsing, bounded collections, truncation checks, and native→JSON retention; no genuine fixtures | Generate genuine fixtures, cross-check every version, and broaden fuzz/property coverage |
| Non-destructive inspection/validation | partial | JSON/XML/CSV inspection plus source-derived native 1.0–4.2 header probe | Validate native records after genuine fixtures exist |
| Native `.amc` write | investigating | Explicit, atomic AMC 4.2 export with synthetic byte round trips for metadata, custom values, pictures, and supplementary records | Cross-check files in upstream 4.2.3.2 before compatibility claims |
| AMC XML read | partial | Synthetic movie, catalog-property, and custom-field-definition tests | Add real 3.x/4.x exports |
| AMC XML write | partial | Synthetic movie and metadata self round trip | Import generated output in upstream AMC |
| CSV read/write | partial | Synthetic round trip | Add upstream locale/delimiter fixtures |
| HTML export | prototype | Atomic escaped table export with bounded document templates and all modeled scalar fields in row templates | Characterize and implement upstream multi-document/extra-field template compatibility |
| Unknown XML fields | partial | Scalar custom values round trip; structured values are rejected rather than flattened | Preserve repetition/order/type/attributes |
| Pictures | unsupported | `TMoviePicture` source located; Python model stores a string only | Characterize embedded/external semantics from source and fixtures |
| Catalog metadata | investigating | Native/XML properties retained in validated, deep-copied JSON metadata; explicit error/keep/replace/namespace merge policies | Cross-check policies with genuine fixtures and define typed long-term models |
| Catalog merging | partial | Movie-number `error`/`skip`/`replace`/`renumber` and metadata `error`/`keep`/`replace`/`namespace` policies are available in the model and CLI | Verify policies with genuine interchange fixtures |
| Custom-field definitions | investigating | Native and XML definitions retained in JSON metadata; every native value is additionally retained as an ordered tag/value list so duplicates and reserved-key collisions survive | Cross-check genuine fixtures and typed-value behavior |
| Website scripts | investigating | Bounded, non-executing `.ifs` metadata/permissions/static-name inspection with malformed-entry diagnostics; static values are not exposed | Design sandboxed provider execution and map runtime APIs |
| Media analysis | prototype | Portable file facts and dependency-free PCM WAV duration/audio data can create movie entries | Add bounded optional codec providers and map upstream field/filter semantics |
| Loans | unsupported | `loan.pas` and `loanhistory.pas` located; current borrower string only | Map loan/history model |
| CLI CRUD | partial | In-process function tests, explicit import policies, documented exit statuses, atomic validated backup/restore, and an installed empty-list JSON contract | Expand installed end-to-end command behavior contracts |
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
