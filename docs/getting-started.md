# Getting started

This guide takes a new user from a source checkout to a small, backed-up catalog.
AMC Python is currently a prototype, so work on copies when migrating an existing
collection.

## Requirements and installation

AMC Python requires Python 3.10 or newer. From the repository root, create an
isolated environment and install the package:

```console
python -m venv .venv
source .venv/bin/activate
python -m pip install -e .
amc --help
```

On Windows PowerShell, activate the environment with
`.venv\Scripts\Activate.ps1`. Pillow is installed automatically. The desktop
interface additionally requires Tk; see the [desktop guide](gui.md#tk-installation)
for operating-system-specific details.

## Create and inspect a catalog

The `--catalog`/`-c` option selects the working catalog. A command that changes a
missing JSON catalog creates it:

```console
amc -c movies.json add "The Apartment" --year 1960 --director "Billy Wilder"
amc -c movies.json add "Alien" --year 1979 --director "Ridley Scott"
amc -c movies.json list
amc -c movies.json search alien
amc -c movies.json stats
```

Run `amc COMMAND --help` before using an unfamiliar operation. Commands report
usage errors with exit status 2 and catalog or I/O failures with exit status 1;
automation should follow the complete [command-line contract](cli.md).

## Import an existing collection

Keep the original file unchanged and import into a new JSON catalog. Choose the
command based on the source:

| Source | Recommended command | Notes |
| --- | --- | --- |
| Ant Movie Catalog XML export | `amc -c movies.json import-xml catalog.xml` | Preferred migration path. |
| Another JSON, XML, or CSV catalog | `amc -c movies.json import catalog.xml` | Merges into the destination; collision policies are configurable. |
| Native `.amc` catalog | `amc -c movies.json import catalog.amc` | Read-only conversion; support is still being verified. |
| A directory of media files | `amc -c movies.json import-media Movies/ --recursive` | Creates entries from filenames and portable media facts. |

Inspect or validate a source without changing it first:

```console
amc inspect catalog.amc
amc validate catalog.xml
```

Native `.amc` export is experimental. Prefer keeping JSON as the working format and
exporting XML or CSV for interchange. Consult the [compatibility matrix](compatibility.md)
before relying on round trips with Ant Movie Catalog.

## Back up and restore

Create a validated backup before bulk imports, renumbering, or format experiments:

```console
amc -c movies.json backup movies.backup.json
amc -c movies.json restore movies.backup.json
```

`restore` replaces the selected catalog. Keep an additional copy outside the
project directory; the command is not a substitute for versioned or off-device
backups.

## Choose an interface

- Continue with `amc -c movies.json COMMAND` for scripting and complete command
  coverage.
- Run `amc-gui movies.json` (or `amc -c movies.json gui`) for the editable desktop
  interface described in the [desktop guide](gui.md).
- Run `amc-web movies.json --host 127.0.0.1` for a local, read-only browser view.
  Binding to `0.0.0.0` exposes the catalog on every network interface; review the
  [web guide](web.md) before doing so.

## Next steps

- Use `amc -c movies.json export-xml catalog.xml` to create an interchange copy.
- Read the [JSON v1 contract](data-formats/json-v1.md) before producing JSON from
  another program.
- Use the [documentation index](README.md) to find format, architecture, and
  contribution references.
