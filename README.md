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
> **Upstream status:** an extracted source snapshot is now checked in under
> `src/original/` with its companion components under `src/antcomponents/`. Its
> archive URL, retrieval timestamp, size, and digest were not recorded, so snapshot
> provenance is incomplete. Initial source-unit mapping is recorded in the
> [upstream source inventory](docs/upstream/source-inventory.md); no Python codec is
> yet verified against an upstream-generated catalog. Native AMC 1.0–4.2 headers
> can be identified non-destructively. Catalog owner, mail, site, and description
> can be read for versions 3.1–4.2, and custom-field definitions can be read for
> versions 4.0–4.2. Movie records can be read for versions 3.1–4.2, including AMC 4.2 supplementary
> records. Native files can be imported into JSON without modifying the source; exact native
> headers are detected even when the file does not use an `.amc` suffix; catalog metadata,
> embedded pictures, and supplementary records are retained in JSON. Native reads apply
> configurable file, movie-count, individual-picture, and cumulative-picture limits.
> Genuine-fixture
> validation remains pending.

## Install and use

```console
python -m pip install -e .
amc -c movies.json import-xml MyCatalog.xml
amc -c movies.json import additional.csv
amc -c movies.json import legacy.amc  # read-only conversion; source is untouched
amc -c movies.json add "The Apartment" --year 1960 --director "Billy Wilder"
amc -c movies.json list
amc -c movies.json search Wilder
amc -c movies.json remove 2
amc -c movies.json edit 1 --title "The Apartment" --year 1960
amc -c movies.json export-xml MyCatalog.xml
amc -c movies.json export-csv movies.csv
amc -c movies.json stats
amc -c movies.json renumber
amc -c movies.json gui
amc inspect movies.json --json
amc validate movies.json
```

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
resolves duplicate movie numbers. JSON, XML, and CSV output files are replaced
atomically so a failed write does not truncate an existing catalog.

The optional desktop interface uses Python's built-in Tk toolkit. It provides a
searchable, sortable movie list and dialogs for adding and editing catalog entries.

## Development

Work is source-driven and test-first. The next milestone is provenance recovery,
detailed native-format analysis, and read-only native-format inspection—not
additional unrelated CRUD features. See
[`CONTRIBUTING.md`](CONTRIBUTING.md) for checks, fixture requirements, and the
definition of an acceptable compatibility change.
