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
> **Upstream status:** the original archive has not been downloaded or extracted,
> and no source units have been mapped to Python modules. The exact artifact
> checklist is recorded in the
> [upstream source inventory](docs/upstream/source-inventory.md).

## Install and use

```console
python -m pip install -e .
amc -c movies.json import-xml MyCatalog.xml
amc -c movies.json import additional.csv
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
atomically. Import accepts both attribute-based AMC XML and element-based exports.
Unknown XML attributes and elements are retained in each movie's `extras` mapping
so custom data is not discarded.
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

Work is source-driven and test-first. The next milestone is upstream inventory and
read-only native-format inspection, not additional unrelated CRUD features. See
[`CONTRIBUTING.md`](CONTRIBUTING.md) for checks, fixture requirements, and the
definition of an acceptable compatibility change.
