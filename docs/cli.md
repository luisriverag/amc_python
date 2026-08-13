# Command-line contract

The `amc` console script and `python -m amc.cli` expose the same interface.
Commands write ordinary results to standard output and operational diagnostics to
standard error. `inspect --json`, `validate --json`, `list --json`, `search
--json`, `stats --json`, and `duplicates --json` each emit one complete JSON value
followed by a newline.

## Exit statuses

| Status | Meaning |
|---:|---|
| `0` | The command completed. Validation warnings, including unverified native structure, do not make validation fail. |
| `1` | `validate` recognized an invalid catalog and emitted one or more error diagnostics. |
| `2` | Command-line usage was invalid, or an operational/catalog error prevented the requested command. |

Import policy failures use status 2 and do not save the destination. Output files
are atomically replaced only after successful serialization.

The JSON shapes are part of the CLI contract:

- `list` and `search` return arrays of JSON-v1 movie objects.
- `stats` returns an object with `movies`, `checked`, `total_length`,
  `average_rating`, `earliest_year`, and `latest_year`.
- `duplicates` returns an array of movie-object arrays grouped by normalized display
  title and year.
- `inspect` returns a catalog-information object.
- `validate` returns an array of diagnostic objects.

## Safety-sensitive commands

- `backup` and `restore` copy to a same-directory temporary file, fsync it,
  validate the copied bytes, and replace the destination only after validation.
- `import-media` fully discovers and inspects its bounded input set before saving;
  directory recursion is opt-in and extension filters are explicit.
- `inspect-script` and `list-scripts` emit metadata as JSON but never execute the
  inspected Pascal scripts. Static variable values are not returned.
- `export-html` escapes modeled movie values. Document and row templates are
  bounded and unknown row markers are rejected before destination replacement.
- `export-amc` atomically writes the source-derived AMC 4.2 layout. It preserves
  supported native metadata retained during import, but remains fixture-unverified
  and does not modify the JSON catalog unless explicitly requested.
