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
| Native `.amc` read | investigating | User-designated source baseline drives fixed-record 1.0–3.0 and modern 3.1–4.2 parsing, typed 4.2 writer/composer/certification/file-path/user-rating/color-tag fields, pre-3.0 linked-picture and borrower sidecars, bounded collections with CLI-configurable import budgets, exhaustive synthetic record-truncation checks for 1.0–3.0 and 4.2, deterministic byte-mutation checks, native→JSON retention, preservation of undefined CP-1252 bytes, and explicit caller-selected codecs during import; no genuine fixtures | Generate genuine fixtures (including legacy sidecars), determine real catalog code pages, cross-check every version, and add property-framework fixture mutation coverage |
| Non-destructive inspection/validation | partial | JSON/XML/CSV inspection plus source-derived native 1.0–4.2 header probe | Validate native records after genuine fixtures exist |
| Native `.amc` write | investigating | Explicit, atomic AMC 4.2 export with synthetic byte round trips for metadata, custom values, pictures, and supplementary records; existing destinations receive an fsynced, atomically replaced `.bak` copy before replacement; POSIX directory entries are fsynced after both replacements; injected serialization, backup-copy, and final-replacement interruptions preserve the destination; strict retained-rating, custom-field, separator, and structural metadata validation; configurable budgets exposed by CLI | Cross-check files in upstream 4.2.3.2 before compatibility claims |
| AMC XML read | partial | Synthetic movie, catalog-property, and custom-field-definition tests | Add real 3.x/4.x exports |
| AMC XML write | partial | Synthetic movie and metadata self round trip | Import generated output in upstream AMC |
| CSV read/write | partial | Synthetic round trip | Add upstream locale/delimiter fixtures |
| HTML export | prototype | Atomic escaped table export with bounded document templates and all modeled scalar fields in row templates | Characterize and implement upstream multi-document/extra-field template compatibility |
| Unknown XML fields | partial | Scalar custom values round trip; structured values are rejected rather than flattened | Preserve repetition/order/type/attributes |
| Pictures | investigating | Service/CLI can link, byte/pixel-bound validate/embed, crop, clear, and atomically export movie pictures, including atomic batch clearing and batch set with per-movie crop rectangles (one distinct picture and crop per movie, or one shared picture/crop across several movies) from the CLI (`picture-clear`, `picture-set-many --crop`/`--crop-for`) and the desktop **Set Pictures**/**Assign Pictures**/**Clear Pictures** toolbar actions; the desktop edit dialog and each **Assign Pictures** row offer interactive drag-to-select cropping (`crop_box_from_canvas`/`crop_image_bytes`) instead of numeric coordinates; native read/write retains embedded bytes in JSON; synthetic service/CLI/GUI/native tests | Verify external-path resolution, crop/conversion behavior, and embedded/link semantics with genuine upstream fixtures |
| Catalog metadata | investigating | Native/XML properties retained in validated, deep-copied JSON metadata; explicit error/keep/replace/namespace merge policies | Cross-check policies with genuine fixtures and define typed long-term models |
| Catalog merging | partial | Movie-number `error`/`skip`/`replace`/`renumber` and metadata `error`/`keep`/`replace`/`namespace` policies are available in the model and CLI | Verify policies with genuine interchange fixtures |
| Custom-field definitions | investigating | Native and XML definitions retained in JSON metadata; every native value is additionally retained as an ordered tag/value list so duplicates and reserved-key collisions survive | Cross-check genuine fixtures and typed-value behavior |
| Website scripts | investigating | Bounded, non-executing `.ifs` metadata/permissions/static-name inspection with malformed-entry diagnostics, source-shaped field exclusion delimiters, validated option/parameter configuration, atomic JSON settings persistence, and isolated field-level merge previews that enforce declared movie/picture/extra permissions; static values are not exposed or persisted | Design sandboxed timeout/rate-limit/cache provider execution and map remaining runtime APIs |
| Media analysis | prototype | Portable file facts and dependency-free PCM WAV, FLAC, and AIFF/AIFF-C duration/audio data can create movie entries | Add bounded optional codec providers for compressed/lossy formats (MP3, MP4, OGG) and map upstream field/filter semantics |
| Loans | prototype | Source-derived atomic single/multi-movie transitions with opt-in case-insensitive media-label and retained-native-number grouping, validated JSON-retained history, managed/active borrower lists, and atomic source-shaped TSV export; synthetic service/CLI/GUI tests | Verify grouping and TSV encoding/consumer behavior with upstream AMC |
| CLI CRUD | partial | In-process function tests, explicit import policies, shared application services for failure-atomic mutations, exports, and validated backup/restore, read-only protection for native/XML/CSV interchange paths, plus an installed empty-list JSON contract | Expand installed end-to-end command behavior contracts |
| Desktop GUI | prototype | File workflows, responsive multi-row controls, selection/history/read-only/data-aware action states, keyboard search clearing, borrower suggestions, retained loan-history review/export, safe HTTP(S) movie URL launching, atomic multi-row removal and checked-state updates, bounded failure-atomic undo/redo, bidirectional column sorting, validated scalar and multiline description/comment editing, checked/loan filters, table/details/poster layouts, scaled Pillow decoding plus linked/embedded poster editing, interactive drag-to-select picture cropping, atomic batch picture set/assign/clear across an extended selection (shared or per-movie distinct pictures), persisted view/layout/window-size/undo-redo-depth preferences editable from a toolbar **Preferences** dialog (`amc.preferences`, separate from any catalog file), statistics, duplicates, shortcuts, and catalog-path entry point have headless tests; native export warns that compatibility is unverified and identifies the replacement backup | Add accessibility and widget/display tests, including a real-display smoke run of the crop, Assign Pictures, Preferences, and other multi-widget dialogs |
| Web interface (Python extension) | prototype | Read-only responsive table/poster-gallery/details UI with search, bounded pagination, sortable headings, failure-safe external-change reload, desktop-aligned views, security headers, size/pixel-bounded decoded-image MIME handling, HTML escaping, and safe-link tests; independent of Tk | Add authentication/TLS deployment guidance before any mutation support |
| Localization | unsupported | Upstream language/help assets located; Python strings are inline English | Inventory resource formats and supported locales |
| Printing/reports | unsupported | `printform.pas`, `amcreport/`, and bundled FreeReport located | Decide port/omission after behavior and license review |

## Parity accounting notes

The web server, internal JSON format, JSON script-settings files, strict corrupt-file
diagnostics, and safer active-borrower deletion behavior are AMC Python features or
intentional divergences. They are tested functionality, but they do not increase
the count of upstream-verified subsystems. Likewise, accepting an internal JSON
catalog with an `.amc` filename is a migration aid for earlier AMC Python releases,
not support for another native AMC header. The detailed source-by-source gaps are
tracked in the [port audit](PORT_AUDIT.md#gap-matrix-against-the-original-application).

## Supported Python environments

Python 3.10 and newer is declared. A Linux and Windows workflow is configured for
Python 3.10–3.13; this repository does not contain evidence of a completed hosted CI
run. The workflow installs the `dev` extra and runs focused Ruff linting, the full
test suite with an 80% aggregate branch-coverage floor, compilation and source CLI
checks, plus isolated wheel/entry-point smoke tests. Formatting and static type
checking are not yet configured gates. Tk comes from the Python/operating-system
installation rather than a wheel extra; the isolated packaging check explicitly
imports both `tkinter` and `amc.gui` before exercising the GUI entry point.

The detailed evidence and gap analysis is maintained in
[`PORT_AUDIT.md`](PORT_AUDIT.md).

## Updating this file

Every compatibility change must include:

1. Fixture provenance.
2. Automated tests and exact commands.
3. Supported upstream versions.
4. Known lossy fields or behavior.
5. A status change justified in the pull request.
