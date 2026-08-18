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
For native input, `import SOURCE --native-encoding CODEC` selects the Python codec
used for AMC strings (default `cp1252`) without modifying the source. The option has
no effect on JSON, XML, or CSV input.
Native import also accepts `--max-input-bytes`, `--max-movies`,
`--max-picture-bytes`, `--max-total-picture-bytes`, `--max-string-bytes`,
`--max-custom-fields`, `--max-list-values`, `--max-extras-per-movie`, and
`--max-total-extras`. These options can lower the default parser budgets; an
exceeded or invalid budget returns status 2 before the destination is changed.
Catalogs opened directly from `.amc`, `.xml`, or `.csv` are read-only working
inputs: mutation commands fail with status 2 rather than overwriting interchange
bytes with JSON. Use `import-xml` or another conversion workflow to create a JSON
working catalog first.

The JSON shapes are part of the CLI contract:

- `list` and `search` return arrays of JSON-v1 movie objects.
- `stats` returns an object with `movies`, `checked`, `total_length`,
  `average_rating`, `earliest_year`, and `latest_year`.
- `duplicates` returns an array of movie-object arrays grouped by normalized display
  title and year.
- `inspect` returns a catalog-information object.
- `validate` returns an array of diagnostic objects.

## Safety-sensitive commands

- `export-amc` is explicitly labeled experimental because generated files have not
  been opened and resaved with upstream AMC. It atomically writes source-derived
  AMC 4.2 bytes and preserves an existing destination under the sibling `.bak`
  name; automation should retain the JSON source until compatibility is verified.
- `backup` and `restore` copy to a same-directory temporary file, fsync it,
  validate the copied bytes, and replace the destination only after validation.
- `import-media` fully discovers and inspects its bounded input set before saving;
  directory recursion is opt-in and extension filters are explicit.
- `loan-out` rejects an empty borrower or a movie loaned to a different borrower;
  `loan-in` rejects a movie that is not currently loaned. Both changes are saved
  atomically. Successful state transitions append an immutable timestamped event
  to JSON catalog metadata; repeating `loan-out` for the same borrower does not
  duplicate the event.
- `loan-out NUMBER BORROWER --include-media-label` and
  `loan-in NUMBER --include-media-label` apply the transition to every movie whose
  non-empty media label matches the selected movie case-insensitively. The complete
  group is validated before one atomic save; empty labels never form a group.
- `--include-native-number` expands a loan transition to movies that retained the
  same original native AMC number during import. This covers source catalogs with
  duplicate movie numbers even though AMC Python assigns unique working numbers.
  Both grouping flags may be combined; their union is saved atomically.
- `loan-history [--json]` lists the retained check-out/check-in events. History
  includes the movie number, media label, title, and borrower captured at the time
  of the transition. Interchange exports do not currently carry this Python-owned
  history metadata.
- `loan-history-export DESTINATION [--catalog-name NAME]` atomically writes the
  seven-column, tab-separated history layout used by upstream `loanhistory.pas`,
  including its `MovieLabel` header spelling and `yyyy/mm/dd hh:mm:ss` timestamps.
  Output is UTF-8 with CRLF lines; tabs and line breaks in values are rejected
  because the upstream layout defines no escaping convention.
- `borrower-add NAME` and `borrower-remove NAME` manage the persistent borrower
  list; `borrowers [--json]` combines that list with names on active loans without
  case-insensitive duplicates. An active borrower cannot be removed, avoiding the
  upstream dialog's implicit clearing of every associated loan.
- `inspect-script` and `list-scripts` emit metadata as JSON but never execute the
  inspected Pascal scripts. Static variable values are not returned.
- `configure-script SCRIPT --option NAME=INTEGER --parameter NAME=VALUE` applies
  case-insensitive, source-shaped option and parameter choices and emits the
  resulting metadata as JSON. Named option values are validated against the choices
  declared by the script. `--load SETTINGS` restores a matching JSON settings file,
  command-line overrides take precedence, and `--save SETTINGS` atomically persists
  the resulting public option/parameter values. Pascal is never executed and
  static/session values are never written to the settings file.
- `export-html` escapes modeled movie values. Document and row templates are
  bounded and unknown row markers are rejected before destination replacement.
- `export-amc` atomically writes the source-derived AMC 4.2 layout. It preserves
  supported native metadata retained during import, but remains fixture-unverified
  and does not modify the JSON catalog unless explicitly requested.
  `--encoding` selects the native string codec (default `cp1252`).
  `--max-output-bytes`, `--max-string-bytes`, `--max-picture-bytes`, and
  `--max-total-picture-bytes` lower the writer's byte budgets. `--max-movies`,
  `--max-custom-fields`, `--max-list-values`, `--max-extras-per-movie`, and
  `--max-total-extras` expose the remaining structural budgets. Invalid or exceeded
  budgets return status 2 without replacing an existing destination.
- `picture-set NUMBER SOURCE` stores a linked picture path;
  `picture-set NUMBER SOURCE --embed [--max-bytes N] [--max-pixels N]` verifies a
  Pillow-supported image, bounds encoded bytes and decoded pixels, then base64-retains
  the bytes for native/JSON round trips. `--crop X,Y,WIDTH,HEIGHT` optionally stores a
  validated in-bounds crop using the source image format. Cropping requires `--embed`.
  `picture-export NUMBER DESTINATION` atomically
  writes embedded bytes or copies a linked picture, resolving relative links beside
  the catalog. `picture-clear NUMBER` removes both linked and embedded state.
