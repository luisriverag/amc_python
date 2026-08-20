# Upstream source inventory

This file is intentionally a fillable inventory. It must be completed from the
actual `amc_sources.rar` archive before source-port claims are made.

## Current acquisition and mapping status

An extracted source snapshot is checked in at `src/original/`, with companion
components at `src/antcomponents/`. The two trees contain 952 files: 418 belong to
`Movie Catalog`, while the rest are shared units, bundled/modified dependencies,
help, resources, and components. This corrects the previous statement that no
upstream source was present.

The contributor later supplied the original RAR and companion ZIP. Their byte
sizes and digests are recorded in `archive-provenance.md`, and clean extraction
confirmed that all 952 expanded paths and content digests match the checked-in
trees. Treat this as **archive/tree identity with incomplete publisher
authentication**: the precise retrieval time and an independently published digest
are unavailable, and source availability does not prove behavioral compatibility.

**Project decision:** the user has designated this checked-in snapshot as correct
and authoritative for continued source-driven porting. Exact equality with the
supplied archives is now established; publisher origin and compatibility remain
separate evidence questions.

| Artifact | Expected location | Current state |
|---|---|---|
| Checked-in source | `src/original/` | present (876 files) |
| Companion components | `src/antcomponents/` | present (76 files) |
| Supplied application archive | `src/original_compressed/amc_sources.rar` | present; digest recorded |
| Supplied component archive | `src/components_compressed/antcomponents.zip` | present; digest recorded |
| Archive provenance and digest | `docs/upstream/archive-provenance.md` | present for both supplied archives |
| Extracted acquisition workspace | `upstream/source/` | absent |
| Generated file inventory | `upstream/inventory.json` | absent |
| Reviewed unit-to-module map | table below | initial map only |
| Upstream-derived fixtures | `tests/fixtures/upstream/` | absent |

## Snapshot identity

| Property | Evidence/value |
|---|---|
| Published URL | `https://update.antp.be/amc/amc_sources.rar` (acquisition-tool default; not proven as snapshot origin) |
| Retrieved at / byte size / SHA-256 | Precise retrieval time unknown; sizes and SHA-256 values recorded in `archive-provenance.md` |
| Product version | `MovieCatalog.dof` declares file version **4.2.3.2** |
| Source language/compiler | Delphi; bundled readme requires Delphi 7 with Update 1 and mentions possible Delphi 6 support |
| Copyright | bundled readme: 2000–2023 Antoine Potten and Mickaël Vanneufville |
| Application license | bundled readme says GPL; application units contain GPL-2.0-or-later notices; GPLv2 text exists under `Movie Catalog/dev/` |
| Third-party licensing | **review required**; several bundled dependency license files exist |
| Snapshot/archive equivalence | **verified** for all 952 files in the two supplied archives |

Reproduce the supplied RAR comparison with:

```console
python tools/acquire_upstream.py \
  --url file://$PWD/src/original_compressed/amc_sources.rar \
  --expected-sha256 96ac957a892094f2b97c9eebcbe31d4f0d78f2557800dcae276ffe551952cfb7 \
  --extract-to upstream/source \
  --strip-root \
  --compare-to src/original
```

This writes `upstream/comparison.json` with matched, changed, missing, and
unexpected paths, and records the boolean result in `archive.json`. The
`--strip-root` option removes the RAR's sole `amc_sources/` packaging directory.
The same tool extracts ZIP files directly, so the component archive can be compared
without that option against `src/antcomponents/`. A `true` result proves tree
equality for the supplied bytes; it does not authenticate their publisher origin.
If an independently published digest becomes available, use it with
`--expected-sha256` when performing a fresh network acquisition.

## Initial unit inventory

This is a subsystem-level map, not an exhaustive 952-file review. “Mapped” means a
source location has been identified; it does not mean the Python behavior matches.

| Upstream path/unit | Responsibility | Python target | Status | Tests/fixtures | Notes |
|---|---|---|---|---|---|
| `Movie Catalog/MovieCatalog.dpr` | Application startup and form wiring | `amc.cli`, `amc.gui` | mapped, not compared | none upstream-derived | Delphi desktop startup is not a CLI analogue |
| `Movie Catalog/movieclass.pas` | Movies, catalog, native and XML persistence, pictures | `amc.model`, `amc.catalog`, `amc.storage`, `amc.inspection` | priority mapping | synthetic only | Defines native headers 1.0–4.2 and `TMovieList.LoadFromFile`/`SaveToFile`; import callers can select the native string codec while automatic code-page behavior remains unverified |
| `Movie Catalog/movieclass_old.pas` | Legacy movie/catalog representations | future native codec | mapped, not reviewed | none | Required for old native versions |
| `Movie Catalog/fields.pas` | Built-in field identifiers and metadata | `amc.model` | mapped, not compared | internal and synthetic interchange tests | Writer, composer, certification, file path, user rating, and color tag now join the original flat modeled subset; remaining field/type behavior is incomplete |
| `Movie Catalog/main.pas` | Main workflows, open/save, search, UI actions | future services; `amc.cli`, `amc.gui` | mapped, not compared | none upstream-derived | Selects AMC 3.5, 4.1, and current save formats |
| `Movie Catalog/import2*.pas` | Import workflow and engines, including CSV | `amc.storage` | mapped, not reviewed | synthetic CSV | Dialect behavior still unverified |
| `Movie Catalog/export.pas` | AMC/XML/CSV/HTML/SQL export workflow | `amc.storage` | mapped, not reviewed | synthetic XML/CSV | Python implements only JSON/XML/CSV |
| `Movie Catalog/getscript*.pas`, `ifps/` | Website scripts and Pascal runtime | `amc.scripts` | metadata/configuration/merge-preview prototype; execution intentionally omitted | synthetic header, configuration, persistence, permission, isolation, and validation tests | `TScriptInfo.Load` reads bracketed metadata from the leading Pascal comment; `TScriptOptions` and `TScriptParameters` provide source-shaped configurable inputs; registered `CanSetField`, `CanSetPicture`, and extra permission APIs shape an isolated field-level merge preview; Python validates and atomically stores public settings but never persists static state or executes IFPS code |
| `Common/MediaInfo.pas`, `Movie Catalog/getmedia.pas` | Media metadata extraction | `amc.media` | prototype, not compared | synthetic file/WAV/FLAC tests | Portable path/name/extension/size and WAV/FLAC audio facts only, parsed directly from each format's own header without MediaInfo; upstream exposes 28 media tags and filtering/merge behavior |
| `Movie Catalog/loan.pas`, `loanhistory.pas` | Borrower and loan-history workflows | `amc.application`, `amc.loans`, `amc.cli` | prototype subset | synthetic service/CLI tests | Atomic single/multi-movie transitions follow `strBorrower`; opt-in media-label and retained-native-number expansion follow `ActionOptionsIncLab`/`ActionOptionsIncNum`; empty labels are not grouped; managed names combine with active values case-insensitively; unlike upstream deletion, active names cannot be removed implicitly; Python retains ISO-8601 events and exports the seven-column TSV layout as UTF-8; upstream verification remains pending |
| `Movie Catalog/programsettings.pas` | Preferences and settings XML | none | mapped, not ported | none | Separate from catalog data |
| `Movie Catalog/printform.pas`, `amcreport/`, `FreeReport/` | Printing/report design | none | mapped, not ported | none | Bundled modified report dependency |
| `Movie Catalog/languages/`, `help/` | Localization and user documentation | none | mapped, not ported | none | Multiple language assets are present |

## Required subsystem discovery

- [x] Application startup and configuration (initial units identified)
- [x] Domain records and field definitions (initial units identified)
- [x] Native `.amc` reader (`TMovieList.LoadFromFile`)
- [x] Native `.amc` writer (`TMovieList.SaveToFile`)
- [x] XML import/export (`movieclass.pas`)
- [x] CSV import/export (`import2*`, `export.pas`; detailed review pending)
- [x] Picture storage and conversion (`TMoviePicture` in `movieclass.pas`)
- [x] Website scripting runtime (`getscript*`, `ifps/`)
- [x] Media-file analysis (`getmedia.pas`, `Common/MediaInfo.pas`)
- [x] Search, filtering, grouping, and sorting (`main.pas`, `filter*`, `sort.pas`)
- [x] Loans/borrowers (`loan.pas`, `loanhistory.pas`)
- [x] Printing and templates (`printform.pas`, `amcreport/`, `FreeReport/`)
- [x] Localization (`languages/`, `help/`)
- [x] Preferences and UI state (`programsettings.pas`)
- [x] Forms and user workflows (`*.dfm` and paired units)
- [x] Update mechanism (no application self-update subsystem located; `CheckVersion`
  in `getscript.pas` exposes the running application version to scripts, while
  `TMediaInfo.Create(..., CheckVersion)` checks the MediaInfo DLL API version)

Discovery checkmarks only mean likely source locations were found. Detailed symbol
mapping, behavior characterization, licensing, and tests remain open.

## Native catalog behavior characterized so far

- **Authoritative unit/symbols:** `Movie Catalog/movieclass.pas` defines
  `TMovieList.LoadFromFile`, `ReadHeader`, `ReadData`, and `SaveToFile`.
- **Save backup workflow:** `Movie Catalog/main.pas` deletes the previous `.bak`
  and renames the destination to `.bak` before `TMovieList.SaveToFile`; AMC Python
  copies the old bytes through an fsynced temporary backup only after the new
  catalog has serialized successfully, preserving the destination on either
  serialization or backup failure.
- **Recognized versions:** `LoadFromFile` dispatches headers 1.0, 1.1, 2.1, 3.0,
  3.1, 3.3, 3.5, 4.0, 4.1, and 4.2. Versions through 3.0 use fixed legacy records;
  versions 3.1 and later use `ReadData`.
- **Header probe caveat:** upstream `ReadHeader` reads a fixed header-length prefix,
  trims it at a line break, and returns total file size. It does not identify or
  validate the version by itself.
- **Catalog metadata:** modern native data begins with owner, mail, site, and
  description strings; versions before 3.5 also contain a removed ICQ string.
  Version 4.0 and later then include custom-field definitions.
- **Record termination/error behavior:** modern records continue until end of file,
  but the upstream loop catches a record exception and stops without propagating
  it. This needs fixture-backed characterization before choosing compatible versus
  stricter Python behavior.
- **Legacy sidecars:** versions before 3.0 can read pictures from an extensionless
  filename prefix (`<catalog>_<movie number>.jpg`, then GIF, then PNG) and borrowers
  from sections and movie-number keys in an `.amcl` INI sidecar. AMC Python now
  applies both source-derived sidecars and rejects malformed borrower numbers;
  genuine legacy fixtures remain unavailable.
- **Python progress:** exact source-derived 65-byte headers for versions 1.0–4.2
  are recognized by `amc inspect`; truncated and unknown headers are rejected. The
  length-prefixed owner, mail, site, and description fields can be read for versions
  3.1–4.2, including the removed pre-3.5 ICQ slot. Version 4.0–4.2
  custom-field definitions, list values, flags, and GUI metadata are also parsed.
  Fixed records declared in `movieclass_old.pas`, including inline 3.0 pictures,
  are parsed for versions 1.0–3.0. Modern movie rows, pictures, and per-movie
  custom values are parsed for versions 3.1–4.2. AMC 4.2 supplementary records
  and their safely skipped embedded pictures are represented separately. Generic
  storage dispatch and CLI import can convert supported native catalogs to JSON,
  retaining catalog metadata and embedded picture bytes. Explicit `export-amc`
  output serializes source-derived 4.2 properties, custom definitions and values,
  movie pictures, and supplementary records. Configurable read bounds cover
  file size, movie count, individual pictures, and cumulative picture bytes.
- **Evidence still missing:** no genuine empty, one-record, corrupt, picture, or
  sidecar fixture is committed, so header recognition has not been cross-checked and
  no record-level Python behavior is verified.

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
