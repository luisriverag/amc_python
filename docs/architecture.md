# Architecture

## Principles

- **Source-driven:** upstream source and generated fixtures define compatibility.
- **Lossless by default:** unknown data is retained or explicitly rejected.
- **One application core:** CLI and GUI are adapters, not separate implementations.
- **Read before write:** a format reader must be mature before its writer is enabled.
- **Safe persistence:** writes use a same-directory temporary file and atomic replace.
- **Deterministic tests:** routine tests do not depend on websites or live services.

## Current modules

| Module | Responsibility | Must not own |
|---|---|---|
| `model.py` | Movie values and validation | Filesystem or UI behavior |
| `catalog.py` | In-memory collection operations | Serialization details |
| `application.py` | Persistent, failure-atomic user-interface mutations | Presentation or format-specific rules |
| `storage.py` | JSON, CSV, XML, static HTML, dispatch, and atomic persistence | User interaction |
| `native.py` | Native AMC parsing, resource limits, and explicit experimental 4.2 serialization | UI behavior or compatibility claims without upstream fixtures |
| `media.py` | Bounded media discovery and dependency-free file/WAV/FLAC/AIFF/MP3 facts | Network access or UI behavior |
| `html_template.py` | Renders upstream's own `$$TAG_NAME` HTML export template syntax against `Movie`/`Catalog` | Reading/writing files (done via `storage._atomic_text`) |
| `scripts.py` | Bounded legacy script metadata inspection | Script execution or network access |
| `preferences.py` | Atomic per-user desktop GUI preferences, separate from any catalog | Catalog data or format-specific rules |
| `cli.py` | Argument parsing and terminal presentation | Domain policy |
| `gui.py` | Tk widgets and interaction | Format-specific rules |

`CatalogService` is the first shared application boundary. It opens and reloads a
catalog and performs add, batch add, replace, remove, merge, sort, and renumber
operations against an isolated copy.
The copy is published to the UI only after atomic persistence succeeds, so a failed
write cannot leave an adapter displaying state that was never saved. The CLI uses
this boundary for its mutating CRUD, media-import, catalog-merge, and renumber
workflows, interchange-to-JSON conversion, exports, and validated backup/restore.
Storage dispatch remains a repository concern used behind this boundary.

## Target boundaries

```text
UI adapters (CLI, Tk)
          |
Application services (catalog, import, export, pictures, loans, scripts)
          |
Domain model (catalog, movie, media, custom fields)
          |
Format/provider adapters (AMC binary, XML, CSV, JSON, web providers)
```

Dependencies point downward. Format adapters may construct domain objects but must
not import UI modules. UI adapters call services and must not duplicate persistence
or conflict-resolution rules.

## Error model

Introduce explicit exception types before format work expands:

- `CatalogError`: public base exception.
- `UnsupportedFormatError`: unknown signature or extension.
- `UnsupportedVersionError`: recognized but unsupported version.
- `CorruptCatalogError`: invalid lengths, truncation, or inconsistent records.
- `ValidationError`: domain rule violation.
- `ConflictError`: merge identity/number conflict.

Exceptions should carry a stable diagnostic code, user-facing message, file offset
when relevant, and the causal exception. CLI converts them to documented exit codes;
GUI converts them to dialogs. Libraries never print directly.

### The `CatalogError` / built-in split is deliberate and permanent

`Movie`, `Catalog`, `CatalogService`, and `loans.py` raise plain `ValueError`,
`TypeError`, and `KeyError` far more often than they raise a `CatalogError`
subclass — `catalog.py`, `application.py`, `model.py`, and `loans.py` alone
account for over 60 raw built-in `raise` sites, against five `CatalogError`
subclasses used almost entirely by `inspection.py` (`inspect_catalog`/
`validate_catalog`'s `Diagnostic` output) and `native.py` (the binary `.amc`
reader/writer). `docs/PORT_AUDIT.md` design-debt item 8 originally left open
whether this split should collapse into one hierarchy. It should not, and
this section is that decision, made permanent rather than left undocumented:

- **`CatalogError` subclasses are for structured, diagnosable catalog-content
  problems** — a corrupt, wrong-format, or wrong-version file; a validation
  rule violated by data already on disk; a merge/renumber conflict — the
  cases where a stable `.code` and an optional byte `.offset` add real value
  to a diagnostic consumer, chiefly `validate_catalog`'s `Diagnostic` list
  and the native reader/writer's truncation/mutation reporting.
- **Plain `ValueError`/`TypeError` are for local API argument-contract
  violations** — a bad type, an out-of-range value, an invalid keyword
  combination passed directly to `Movie(...)`, `Catalog.sort(...)`,
  `CatalogService.set_picture(...)`, and similar — the same convention the
  Python standard library and most Python APIs already use for "you called
  me wrong." These are caller mistakes, not catalog data problems, and have
  no meaningful diagnostic code or file offset to attach.
- **Plain `KeyError` is for dict-like lookup failures** — `Catalog.get()`'s
  signal for a movie number that no longer exists, `remove_borrower`'s
  signal for an unknown borrower — mirroring how `dict[missing_key]` already
  behaves in Python, rather than inventing a `CatalogError` subclass to
  duplicate a lookup-failure signal the language already provides.

This split is invisible to both built-in user-facing boundaries, which is
why leaving it in place costs nothing there: the CLI's `main()` catches
`(CatalogError, OSError, TypeError, ValueError, LookupError)` in one block
(`cli.py`), and the desktop GUI's `_SERVICE_ERRORS` tuple catches
`(CatalogError, OSError, TypeError, ValueError, KeyError)` at every
`CatalogService` call boundary (`gui.py`) — both already treat every
exception in this document as one expected-failure family and present the
same generic error (exit status / dialog) regardless of which member raised
it. Migrating the 60+ built-in-`raise` sites to dedicated `CatalogError`
subclasses would not change CLI or GUI behavior at all; it would only make
`Movie`/`Catalog`/`CatalogService` argument validation less idiomatic for
any future direct-API (non-CLI, non-GUI) consumer, who would otherwise
expect ordinary Python argument errors to be ordinary Python exceptions.
The split stays.

## Format adapter contract

Every format adapter provides, as applicable:

```python
probe(stream) -> confidence/version
load(stream, options) -> Catalog
dump(catalog, stream, options) -> None
validate(stream) -> list[Diagnostic]
```

Adapters receive binary or text streams so tests do not require filesystem access.
Path dispatch belongs in a repository/storage facade. Atomic replacement belongs in
that facade, not in individual codecs.

## Compatibility evidence

Each golden fixture must have adjacent metadata containing its producer version,
creation steps, SHA-256 digest, expected capabilities, license/provenance, and
whether redistribution is permitted. Synthetic fixtures must be clearly labeled.

## Security and resource limits

- XML must not resolve external entities.
- Binary lengths and record counts must be bounded before allocation.
- Images and downloaded responses must have size limits.
- Network providers require timeouts and must not run in normal unit tests.
- Existing destination data must remain intact after failed serialization.
- Plugins/scripts are untrusted and must not receive unrestricted execution by
  default.

## Deliberate prototype boundaries

- `scripts.py` reads leading metadata comments only. It never invokes IFPS or
  executes Pascal source, and static values are deliberately omitted.
- `media.py` provides portable filesystem facts and PCM WAV/FLAC/AIFF/MP3/
  MP4/OGG metadata, parsed directly from each format's own public
  specification using only the standard library (AIFF deliberately
  reimplements its 80-bit extended-float sample rate rather than using the
  deprecated, Python-3.13-removed `aifc` module; MP3 duration/bitrate comes
  from the first MPEG audio frame header, exact for CBR and an approximation
  for VBR files without a parsed Xing/VBRI header; MP4 duration/bitrate comes
  from the `moov/mvhd` ISOBMFF box, skipping every other top-level box's
  payload via `seek` rather than reading it since `mdat` can be arbitrarily
  large, with only a whole-file average bitrate since there is no per-codec
  bitrate at this level; OGG duration/bitrate comes from the Vorbis
  identification header plus a backward search for the stream's last page,
  rejecting multiplexed streams and Opus with a clear error rather than
  guessing). Real codec inspection — video-track resolution, framerate, and
  a genuine codec name distinct from the container — remains unimplemented
  for all of these and belongs behind a future optional provider with
  timeouts and bounds if dependency-free parsing isn't added first.
- `preferences.py` is deliberately the one place in the codebase that treats
  a missing, corrupt, or unwritable file as "use the defaults" rather than a
  reportable error. It stores no catalog data, so silently falling back
  never causes data loss the way it would in `storage.py`.
- Static HTML export (`storage.save_html`) escapes every modeled value and
  accepts only bounded, allow-listed `{{MOVIES}}`-style templates. It is
  AMC Python's own template syntax and does not claim AMC template-language
  compatibility. `html_template.py` is the separate module that does render
  AMC's own `$$TAG_NAME` syntax; even there, tag *values* are computed from
  `Movie`/`Catalog`, not cross-checked against genuine upstream output, and
  several behaviors are explicitly out of scope (see its module docstring) —
  picture/rating-icon file copying and the `$$ITEM_EXTRA_*`
  supplementary-record loop, most notably.
- `storage.py` remains too broad; codec separation should follow genuine fixture
  contracts rather than moving unverified behavior between modules prematurely.
- Localization has no Python code at all, deliberately. Upstream's `.lng`
  mechanism (`Common/AntTranslator.pas`) is a runtime Delphi RTTI
  object-graph patcher tied to live VCL form/component instances — it has no
  Tk equivalent, so porting the format itself was never on the table. A
  Python-owned i18n layer (externalize `gui.py`'s hardcoded strings behind a
  key→string lookup, add a loader) is possible but not built: there is no
  actual translated content anywhere in this repository to load, so building
  the scaffolding now would ship untested, empty infrastructure. This is a
  timing decision, not a permanent one — revisit once real translated
  strings exist to load.
- Printing/reports has no Python code at all, permanently. FreeReport's
  license (LGPLv2, in `src/original/FreeReport/license.txt`) is
  redistributable under this repository's GPLv2 posture, so licensing was
  never the blocker; porting it would mean reimplementing a complete
  standalone report designer and renderer (its own binary report format, a
  design-time UI, print preview) — an application-sized project, not a
  bounded slice, disproportionate to the rest of this port.
  `export-html-template`/`html_template.py` already covers "produce a
  formatted report from the catalog" as a non-compatible baseline.
