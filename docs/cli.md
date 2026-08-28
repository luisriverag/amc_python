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

`inspect` and `validate` also accept `--max-input-bytes` to reject a file larger
than the given size before any format-specific parsing starts (default 1 TiB).
JSON and native inspection load the full file to identify it, so this bounds the
work an untrusted-sized file can force; XML and CSV already inspect via streaming
readers. An exceeded budget is reported as a `validate` diagnostic and as an
`inspect` error, both without partially parsing the file.

## Safety-sensitive commands

- `export-amc` is explicitly labeled experimental because generated files have not
  been opened and resaved with upstream AMC. It atomically writes source-derived
  AMC 4.2 bytes and preserves an existing destination under the sibling `.bak`
  name; automation should retain the JSON source until compatibility is verified.
- `backup` and `restore` copy to a same-directory temporary file, fsync it,
  validate the copied bytes, and replace the destination only after validation.
- `import-media` fully discovers and inspects its bounded input set before saving;
  directory recursion is opt-in and extension filters are explicit. Use
  `--max-depth N` to include at most N subfolder levels (`0` scans only each
  supplied directory); unlike `--recursive`, a maximum depth implies recursion.
  `--merge-parts` combines adjacent, same-directory `CD1`/`CD2`-style names;
  `--disk-tag-regex` can replace that bounded default matching expression.
  `--import-pictures link|embed` attaches a same-stem poster (preferred) or a
  `folder` image beside each media file; `--folder-picture-name` changes that
  fallback base name. Embedded images retain the same byte and pixel limits as
  the catalog picture workflow.
  `--extract full|defer|skip` controls metadata work: `full` performs normal
  codec inspection, `defer` records portable file facts and a pending-analysis
  marker, and `skip` records only naming/path facts and a skipped marker.
  Use `--extensions default` for the built-in common-video extension set, or
  `--title-filter-regex PATTERN` to remove release tags and separators from
  filename-derived titles. Cleanup expressions are bounded to 256 characters.
  `--progress`
  prints `Inspected N/TOTAL file(s)` to stderr as each file is inspected, useful
  for a large tree where inspection itself takes noticeable time. Because the
  catalog is only written once, after every file has been inspected, interrupting
  the command at any point during discovery or inspection — Ctrl+C or any other
  exception — leaves the destination catalog completely untouched; there is
  nothing to explicitly cancel or roll back.
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
  This is AMC Python's own `{{MOVIES}}`-marker template syntax, distinct from
  `export-html-template` below.
- `export-html-template FULL_CATALOG_PAGE_PATH --full-template FILE
  --individual-template FILE` renders Ant Movie Catalog's own `$$TAG_NAME`
  HTML export templates — the same syntax and placeholders real AMC's HTML
  export uses — so a template a user already has keeps working without the
  original Windows application. At least one of `--full-template`/
  `--individual-template` is required; `--individual-dir` sets where
  per-movie pages go (default: the full page's own directory) and
  `--individual-filename` sets their naming pattern (default
  `{number}.html`). See `amc.html_template`'s module docstring for the exact
  tag coverage and documented scope boundaries (no upstream-verified parity
  claim; picture files and rating-icon images are not copied; the
  supplementary-record `$$ITEM_EXTRA_*` loop is not implemented and any such
  block is stripped rather than left as literal template syntax).
- `export-amc` atomically writes the source-derived AMC 4.2 layout. It preserves
  supported native metadata retained during import, but remains fixture-unverified
  and does not modify the JSON catalog unless explicitly requested.
  `--encoding` selects the native string codec (default `cp1252`).
  `--max-output-bytes`, `--max-string-bytes`, `--max-picture-bytes`, and
  `--max-total-picture-bytes` lower the writer's byte budgets. `--max-movies`,
  `--max-custom-fields`, `--max-list-values`, `--max-extras-per-movie`, and
  `--max-total-extras` expose the remaining structural budgets. Invalid or exceeded
  budgets return status 2 without replacing an existing destination.
- Every `export-*` command accepts `--scope {all,checked}` (default `all`) and
  `--sort-by FIELD [--sort-reverse]`, matching upstream's Export dialog's
  "Movies to include" and sort-order controls without changing the catalog
  itself — `checked` scopes to checked movies the same way the desktop's
  Checked view filter does; `--sort-by` accepts any `Movie` field name
  (movies missing a value for it sort last). `selected`/`visible` scopes have
  no CLI equivalent since there is no interactive selection or search here;
  the desktop's own Export dialog offers those two in addition.
- `imdb-lookup NUMBER [--api-key KEY] [--imdb-id ID] [--timeout SECONDS]
  [--apply]` fetches one movie's metadata from the OMDb API
  (https://www.omdbapi.com/, a REST API that legally re-serves a curated
  subset of IMDb's own data) and prints the field-level differences it would
  make — the catalog is left untouched unless `--apply` is also given. This
  is a hand-written, first-party Python provider, not IFPS script execution;
  see `amc.omdb`'s module docstring and `docs/PORT_AUDIT.md` findings 29-31
  for why. Requires an OMDb API key, obtained separately at
  https://www.omdbapi.com/apikey.aspx and never stored by this project: pass
  `--api-key` or set the `OMDB_API_KEY` environment variable. Without
  `--imdb-id`, the lookup uses the movie's own `url` field when it is
  already an `imdb.com` link, otherwise falls back to a title/year search.
  Only fields with a non-"N/A" OMDb value and a matching `Movie` field are
  proposed; poster images are never downloaded (see the Media analysis row
  in `docs/compatibility.md` for that separate, unimplemented capability).
  Network access always uses an explicit, caller-supplied timeout (default
  10 seconds) and never runs during the automated test suite.
- `picture-set NUMBER SOURCE` stores a linked picture path;
  `picture-set NUMBER SOURCE --embed [--max-bytes N] [--max-pixels N]` verifies a
  Pillow-supported image, bounds encoded bytes and decoded pixels, then base64-retains
  the bytes for native/JSON round trips. `--crop X,Y,WIDTH,HEIGHT` optionally stores a
  validated in-bounds crop using the source image format. Cropping requires `--embed`.
  `picture-set-many --assign NUMBER=PATH [--assign NUMBER=PATH ...] [--embed] [--crop
  X,Y,WIDTH,HEIGHT] [--crop-for NUMBER=X,Y,WIDTH,HEIGHT ...]` applies the same
  embed/size settings to a distinct picture source per movie number in one atomic
  write; each movie may reference its own file, or the same file may be repeated
  across assignments to share one picture. `--crop` applies one shared rectangle to
  every embedded picture; `--crop-for` overrides it with a movie-specific rectangle,
  and may be repeated once per movie number that needs its own crop.
  `picture-export NUMBER DESTINATION` atomically
  writes embedded bytes or copies a linked picture, resolving relative links beside
  the catalog. `picture-clear NUMBER [NUMBER ...]` removes both linked and embedded
  state for one or more distinct movie numbers in a single atomic write.
