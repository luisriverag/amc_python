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
| `storage.py` | JSON, CSV, and XML codecs | User interaction |
| `cli.py` | Argument parsing and terminal presentation | Domain policy |
| `gui.py` | Tk widgets and interaction | Format-specific rules |

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
