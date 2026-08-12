# Upstream source inventory

This file is intentionally a fillable inventory. It must be completed from the
actual `amc_sources.rar` archive before source-port claims are made.

## Current acquisition and mapping status

An extracted source snapshot is checked in at `src/original/`, with companion
components at `src/antcomponents/`. The two trees contain 952 files: 418 belong to
`Movie Catalog`, while the rest are shared units, bundled/modified dependencies,
help, resources, and components. This corrects the previous statement that no
upstream source was present.

The snapshot did not arrive through `tools/acquire_upstream.py`: no archive,
`archive.json`, retrieval timestamp, byte size, digest, or generated inventory was
committed. Treat it as **source available with incomplete provenance**, not as an
authenticated archive. Do not regenerate those facts from the Git tree or imply
that source availability proves behavioral compatibility.

| Artifact | Expected location | Current state |
|---|---|---|
| Checked-in source | `src/original/` | present (876 files) |
| Companion components | `src/antcomponents/` | present (76 files) |
| Downloaded archive | `upstream/amc_sources.rar` | absent |
| Archive provenance and digest | `upstream/archive.json` | absent |
| Extracted acquisition workspace | `upstream/source/` | absent |
| Generated file inventory | `upstream/inventory.json` | absent |
| Reviewed unit-to-module map | table below | initial map only |
| Upstream-derived fixtures | `tests/fixtures/upstream/` | absent |

## Snapshot identity

| Property | Evidence/value |
|---|---|
| Published URL | `https://update.antp.be/amc/amc_sources.rar` (acquisition-tool default; not proven as snapshot origin) |
| Retrieved at / byte size / SHA-256 | **not recorded** |
| Product version | `MovieCatalog.dof` declares file version **4.2.3.2** |
| Source language/compiler | Delphi; bundled readme requires Delphi 7 with Update 1 and mentions possible Delphi 6 support |
| Copyright | bundled readme: 2000–2023 Antoine Potten and Mickaël Vanneufville |
| Application license | bundled readme says GPL; application units contain GPL-2.0-or-later notices; GPLv2 text exists under `Movie Catalog/dev/` |
| Third-party licensing | **review required**; several bundled dependency license files exist |
| Snapshot/archive equivalence | **unverified** |

Reacquire the archive reproducibly, then compare the resulting file inventory to
the checked-in trees:

```console
python tools/acquire_upstream.py --extract-to upstream/source
```

## Initial unit inventory

This is a subsystem-level map, not an exhaustive 952-file review. “Mapped” means a
source location has been identified; it does not mean the Python behavior matches.

| Upstream path/unit | Responsibility | Python target | Status | Tests/fixtures | Notes |
|---|---|---|---|---|---|
| `Movie Catalog/MovieCatalog.dpr` | Application startup and form wiring | `amc.cli`, `amc.gui` | mapped, not compared | none upstream-derived | Delphi desktop startup is not a CLI analogue |
| `Movie Catalog/movieclass.pas` | Movies, catalog, native and XML persistence, pictures | `amc.model`, `amc.catalog`, `amc.storage`, `amc.inspection` | priority mapping | synthetic only | Defines native headers 1.0–4.2 and `TMovieList.LoadFromFile`/`SaveToFile` |
| `Movie Catalog/movieclass_old.pas` | Legacy movie/catalog representations | future native codec | mapped, not reviewed | none | Required for old native versions |
| `Movie Catalog/fields.pas` | Built-in field identifiers and metadata | `amc.model` | mapped, not compared | internal tests | Python model is only a small flat subset |
| `Movie Catalog/main.pas` | Main workflows, open/save, search, UI actions | future services; `amc.cli`, `amc.gui` | mapped, not compared | none upstream-derived | Selects AMC 3.5, 4.1, and current save formats |
| `Movie Catalog/import2*.pas` | Import workflow and engines, including CSV | `amc.storage` | mapped, not reviewed | synthetic CSV | Dialect behavior still unverified |
| `Movie Catalog/export.pas` | AMC/XML/CSV/HTML/SQL export workflow | `amc.storage` | mapped, not reviewed | synthetic XML/CSV | Python implements only JSON/XML/CSV |
| `Movie Catalog/getscript*.pas`, `ifps/` | Website scripts and Pascal runtime | none | mapped, not ported | none | Includes modified IFPS dependency |
| `Common/MediaInfo.pas`, `Movie Catalog/getmedia.pas` | Media metadata extraction | none | mapped, not ported | none | Python fields are passive values |
| `Movie Catalog/loan.pas`, `loanhistory.pas` | Borrower and loan-history workflows | none | mapped, not ported | none | Python stores only current borrower text |
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
- [ ] Update mechanism (not yet located/reviewed)

Discovery checkmarks only mean likely source locations were found. Detailed symbol
mapping, behavior characterization, licensing, and tests remain open.

## Native catalog behavior characterized so far

- **Authoritative unit/symbols:** `Movie Catalog/movieclass.pas` defines
  `TMovieList.LoadFromFile`, `ReadHeader`, `ReadData`, and `SaveToFile`.
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
  sidecar and borrowers from an `.amcl` sidecar.
- **Python progress:** exact source-derived 65-byte headers for versions 1.0–4.2
  are recognized by `amc inspect`; truncated and unknown headers are rejected. The
  length-prefixed owner, mail, site, and description fields can be read for versions
  3.1–4.2, including the removed pre-3.5 ICQ slot. Version 4.0–4.2
  custom-field definitions, list values, flags, and GUI metadata are also parsed.
  Movie rows, pictures (path plus safely skipped embedded bytes), and per-movie
  custom values are parsed for versions 3.1–4.2. AMC 4.2 supplementary records
  and their safely skipped embedded pictures are represented separately. Generic
  storage dispatch and CLI import can convert supported native catalogs to JSON,
  retaining catalog metadata and embedded picture bytes. Configurable bounds cover
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
