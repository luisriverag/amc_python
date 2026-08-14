# AMC Python

A dependency-free, cross-platform Python catalog inspired by Ant Movie Catalog.
It provides a reusable model, JSON persistence, import of AMC XML exports, and a
command-line interface. The original Delphi `.amc` binary format is not portable;
export an existing catalog as XML in Ant Movie Catalog before importing it here.

> **Project status: prototype.** This is currently a clean-room partial
> reimplementation, not yet a feature-complete port. Native `.amc` files, upstream
> scripts, catalog-level metadata, and verified cross-version compatibility remain
> planned work. See the [implementation plan](docs/IMPLEMENTATION_PLAN.md),
> [compatibility matrix](docs/compatibility.md), and
> [architecture](docs/architecture.md) before relying on it for migration.
> The current evidence-based progress assessment is in the
> [port audit](docs/PORT_AUDIT.md).
> License and source-snapshot redistribution findings, including unresolved
> release blockers, are tracked in
> [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).
> **Upstream status:** an extracted source snapshot is now checked in under
> `src/original/` with its companion components under `src/antcomponents/`. Its
> two supplied archives, reported source page, sizes, digests, and exact expanded-tree
> comparisons are recorded in the
> [archive provenance record](docs/upstream/archive-provenance.md). The precise
> download time and an independently published checksum are unavailable, so origin
> authentication remains incomplete. Initial source-unit mapping is recorded in the
> [upstream source inventory](docs/upstream/source-inventory.md); no Python codec is
> yet verified against an upstream-generated catalog. Native AMC 1.0–4.2 headers
> can be identified non-destructively. Catalog owner, mail, site, and description
> can be read for versions 3.1–4.2, and custom-field definitions can be read for
> versions 4.0–4.2. Movie records can be read for versions 1.0–4.2, including AMC 4.2 supplementary
> records. Native files can be imported into JSON without modifying the source; exact native
> headers are detected even when the file does not use an `.amc` suffix; catalog metadata,
> embedded pictures, and supplementary records are retained in JSON. Native reads apply
> configurable file, movie-count, individual/cumulative-picture, cumulative-string,
> custom-field/list-value, and per-movie/cumulative supplementary-record limits.
> Genuine-fixture
> validation remains pending.

For porting work, the checked-in Delphi snapshot is treated as the user-designated
authoritative source baseline. Its equality with the checked-in archives is
verified, but the reported download origin is not presented as independent
publisher authentication or compatibility verification.

## Port progress

**23% — 11 of 47 implementation-plan checklist items complete**

`███████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░` **11 / 47**

This bar is calculated from the checked boxes in the
[implementation plan](docs/IMPLEMENTATION_PLAN.md); it is an auditable project-task
indicator, not a claim that 23% of every upstream feature is compatible. A task is
only checked off when its tests, documentation, and required compatibility evidence
are complete. In particular, native AMC support remains **investigating** until
genuine upstream-generated fixtures and cross-application verification exist. See
the [compatibility matrix](docs/compatibility.md) for capability-level status and
the [port audit](docs/PORT_AUDIT.md) for the evidence gaps behind the number.

## Install and use

```console
python -m pip install -e .
amc -c movies.json import-xml MyCatalog.xml
amc -c movies.json import additional.csv
amc -c movies.json import additional.json --collision skip --metadata keep
amc -c movies.json import legacy.amc  # read-only conversion; source is untouched
amc -c movies.json import-media Movie.mkv Trailer.wav
amc -c movies.json import-media MediaFolder/ --recursive
amc -c movies.json import-media MediaFolder/ --recursive --extensions mkv,mp4,wav
amc -c movies.json add "The Apartment" --year 1960 --director "Billy Wilder"
amc -c movies.json list
amc -c movies.json list --json
amc -c movies.json search Wilder
amc -c movies.json remove 2
amc -c movies.json edit 1 --title "The Apartment" --year 1960
amc -c movies.json edit 1 --set 'rating=8.5' --set 'checked=true'
amc -c movies.json export-xml MyCatalog.xml
amc -c movies.json export-csv movies.csv
amc -c movies.json export-html movies.html
amc -c movies.json export-html movies.html --template template.html
amc -c movies.json export-html movies.html --row-template movie-row.html
amc -c movies.json export-amc movies.amc
amc -c movies.json export-amc movies.amc --max-output-bytes 104857600
amc -c movies.json picture-set 12 cover.jpg --embed
amc -c movies.json picture-set 12 cover.jpg --embed --crop 10,10,300,450
amc -c movies.json picture-export 12 exported-cover.jpg
amc -c movies.json stats
amc -c movies.json stats --json
amc -c movies.json duplicates --json
amc -c movies.json renumber
amc -c movies.json backup movies.backup.json
amc -c movies.json restore movies.backup.json
amc -c movies.json loan-out 12 "Sam Bell"
amc -c movies.json loan-in 12
amc -c movies.json loan-out 12 "Sam Bell" --include-media-label
amc -c movies.json loan-out 12 "Sam Bell" --include-native-number
amc -c movies.json loan-history --json
amc -c movies.json loan-history-export "Loans history.csv"
amc -c movies.json borrower-add "Sam Bell"
amc -c movies.json borrowers
amc -c movies.json gui
amc-web movies.json
amc inspect movies.json --json
amc validate movies.json
amc inspect-script scripts/provider.ifs
amc list-scripts scripts/
```

The desktop interface requires Tk. Tk ships with the official Windows and macOS
Python installers, but many Linux distributions package it separately; on
Debian/Ubuntu install it with `sudo apt install python3-tk` before running
`amc-gui` or `amc gui`. `python3-tk` is an operating-system package rather than a
Python distribution, so it cannot correctly be declared as a wheel dependency.
The built wheel exposes both `amc` and `amc-gui`, and the packaging check imports
`tkinter` and `amc.gui` from an isolated wheel installation.

The JSON representation is UTF-8, human-readable, versioned, and written
atomically. Catalog metadata is validated as finite JSON data and isolated from
caller-owned mutable objects. Import accepts both attribute-based AMC XML and element-based exports.
Unknown XML attributes and elements are retained in each movie's `extras` mapping.
Catalog owner/contact properties and custom-field definitions are also retained, so
these supported structures are not discarded during XML/JSON conversion. Structured
movie extras that XML cannot represent losslessly are rejected instead of flattened.
The internal JSON v1 contract and compatibility policy are documented in
[`docs/data-formats/json-v1.md`](docs/data-formats/json-v1.md).

CSV files can also be used as input (`-c movies.csv`) or exported for spreadsheet
editing. Headers may use Python field names (`original_title`) or AMC names
(`OriginalTitle`), and a UTF-8 byte-order mark is emitted for Excel compatibility.
The generic `import` command merges JSON, XML, or CSV input and automatically
renumbers duplicate movie numbers by default. Use `--collision error`, `skip`,
`replace`, or `renumber` to select movie-number behavior, and `--metadata error`,
`keep`, `replace`, or `namespace` for conflicting catalog metadata. `namespace`
stores each complete incoming metadata object under a deterministic
`amc_python_merge_namespaces.import_N` key. Failed `error` merges leave
the in-memory destination unchanged. JSON, XML, and CSV output files are replaced
atomically so a failed write does not truncate an existing catalog.
HTML export produces a dependency-free, self-contained table and escapes all
catalog text. A bounded UTF-8 template may contain exactly one `{{MOVIES}}` marker;
a bounded row template supports escaped uppercase modeled-field markers such as
`{{NUMBER}}`, `{{ORIGINAL_TITLE}}`, and `{{DESCRIPTION}}`, plus
`{{DISPLAY_TITLE}}`. Upstream AMC's full template/tag compatibility remains pending.
`import-media` records portable path/name/extension/size facts. PCM WAV files also
provide duration and audio bitrate using Python's standard library; broader codec
inspection remains an optional-provider gap. Directory expansion is deterministic,
opt-in recursive, optionally extension-filtered, and bounded to 100,000 files per
invocation.
Legacy `.ifs` script metadata can be inspected and inventoried without executing
Pascal code. Script execution and network providers remain intentionally disabled
until a sandboxed, timeout-bound provider boundary is implemented.

`list`, `search`, `stats`, and `duplicates` accept `--json` for stable
machine-readable output. Duplicate groups use normalized display title plus year;
untitled entries are excluded.
The output shapes and stable exit statuses are documented in the
[`command-line contract`](docs/cli.md).
`backup` and `restore` validate the source catalog, copy its original bytes through
an fsynced temporary file, validate those exact copied bytes, and atomically replace
the destination only on success.
`edit --set FIELD=JSON` can update any modeled field except the catalog number and
applies the same type/range validation as JSON loading before saving.

The optional desktop interface uses Python's built-in Tk toolkit. It provides a
searchable, sortable movie list, file import/export, open/save-as, validated
backup/restore, loan controls, and catalog review tools. Setup, supported workflows,
and explicit limitations are documented in the [desktop guide](docs/gui.md).

AMC Python also includes a read-only web interface at `http://0.0.0.0:6910/` via
`amc-web movies.json`. This is a new convenience interface beyond the upstream port,
but its searchable table, All/Loaned/Available/Checked/Unchecked views, details, and
poster presentation intentionally mirror the desktop/original GUI vocabulary. The
default bind exposes the catalog to every network interface; use
`amc-web movies.json --host 127.0.0.1` for local-only access. See the
[web interface guide](docs/web.md).

## Development

Work is source-driven and test-first. The next milestone is provenance recovery,
detailed native-format analysis, and read-only native-format inspection—not
additional unrelated CRUD features. See
[`CONTRIBUTING.md`](CONTRIBUTING.md) for checks, fixture requirements, and the
definition of an acceptable compatibility change.

Install the project together with its development checks, then run both canonical
commands from the repository root:

```console
python -m pip install -e .[dev]
python tools/check.py
python tools/check_package.py
```

`check.py` runs the focused Ruff rule set, the complete test suite with branch
coverage (minimum 80%), bytecode compilation, fixture-manifest validation, a
source-tree CLI smoke test, and whitespace checks. `check_package.py` separately
builds a wheel, installs it into an isolated virtual environment, and exercises the
installed console entry points. Formatting and static type checking are not yet
canonical gates; see the engineering baseline in the implementation plan.
