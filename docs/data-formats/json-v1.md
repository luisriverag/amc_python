# Internal JSON catalog format, version 1

## Purpose

JSON v1 is the lossless internal working format for the Python application. It is
not an upstream Ant Movie Catalog format and must not be presented as `.amc`
compatibility. Files are UTF-8 text and conventionally use the `.json` suffix.

## Envelope

```json
{
  "format": "amc-python",
  "version": 1,
  "movies": []
}
```

`format` and `version` are required in files written by this application. Readers
also accept a bare movie array for early-prototype compatibility. Unknown envelope
members are ignored. A recognized `amc-python` envelope with a version other than
`1` is rejected rather than guessed.

## Movie object

The same validation applies whether a movie is decoded from JSON or constructed
through the Python API. String fields must be strings, integer fields do not accept
Booleans or numeric strings, `checked` must be a Boolean, and floating-point fields
must be finite numbers. `rating`, when present, is restricted to the inclusive range
0 through 10. Ambiguous values are rejected rather than silently coerced.

Movie keys use the Python field names documented by `Movie`. Missing keys receive
their model defaults. Unknown keys are moved into `extras`. The explicit `extras`
member must be an object and is merged with unknown keys.

Important invariants:

- `number` is an integer greater than or equal to zero. Zero means unassigned.
- `year`, `length`, media counts, bitrates, and file size are integers or null.
- `rating` and `framerate` are numbers or null.
- `rating`, when present, is between 0 and 10 inclusive.
- `checked` is a Boolean.
- `extras` is an object with string keys and JSON-compatible values.

The implementation enforces these primitive type invariants for every declared
field. Additional semantic rules (for example upstream-supported year ranges) will
only be added after they are established from authoritative upstream evidence.

## Persistence guarantees

Writes occur through a temporary file in the destination directory. The temporary
file is flushed and synchronized before atomic replacement. If serialization fails,
the previous destination remains unchanged and the temporary file is removed.

Atomic replacement protects against partial application writes but does not provide
multi-process locking. Concurrent writers remain unsupported.

## Compatibility policy

- Additive optional movie fields may be introduced without changing the envelope
  version when old readers already retain them in `extras`.
- Changes that reinterpret or remove existing fields require a new format version.
- Writers emit version 1 until an explicit migration strategy exists.
- Future-version files are never silently downgraded.
