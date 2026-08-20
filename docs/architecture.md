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
- `media.py` provides portable filesystem facts and PCM WAV/FLAC/AIFF/MP3
  metadata, parsed directly from each format's own public specification using
  only the standard library (AIFF deliberately reimplements its 80-bit
  extended-float sample rate rather than using the deprecated, Python-3.13-
  removed `aifc` module; MP3 duration/bitrate comes from the first MPEG audio
  frame header, exact for CBR and an approximation for VBR files without a
  parsed Xing/VBRI header). MP4 and OGG remain unimplemented; full codec
  inspection for those, and any other compressed/lossy format, belongs behind
  a future optional provider with timeouts and bounds if dependency-free
  parsing isn't added first.
- `preferences.py` is deliberately the one place in the codebase that treats
  a missing, corrupt, or unwritable file as "use the defaults" rather than a
  reportable error. It stores no catalog data, so silently falling back
  never causes data loss the way it would in `storage.py`.
- Static HTML export escapes every modeled value and accepts only bounded,
  allow-listed templates. It does not claim AMC template-language compatibility.
- `storage.py` remains too broad; codec separation should follow genuine fixture
  contracts rather than moving unverified behavior between modules prematurely.
