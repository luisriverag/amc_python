"""Command-line interface for managing catalogs."""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import asdict
from pathlib import Path

from .catalog import Catalog
from .errors import CatalogError
from .inspection import inspect_catalog, validate_catalog
from .model import Movie
from .storage import load, save, save_csv, save_xml


def _catalog(path: Path) -> Catalog:
    return load(path) if path.exists() else Catalog()


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(prog="amc", description="Portable Ant Movie Catalog")
    result.add_argument("--catalog", "-c", type=Path, default=Path("catalog.json"))
    commands = result.add_subparsers(dest="command", required=True)
    commands.add_parser("list", help="list movies")
    find = commands.add_parser("search", help="search movie metadata")
    find.add_argument("query")
    add = commands.add_parser("add", help="add a movie")
    add.add_argument("title")
    add.add_argument("--year", type=int)
    add.add_argument("--director", default="")
    remove = commands.add_parser("remove", help="remove a movie")
    remove.add_argument("number", type=int)
    edit = commands.add_parser("edit", help="edit a movie")
    edit.add_argument("number", type=int)
    edit.add_argument("--title")
    edit.add_argument("--year", type=int)
    edit.add_argument("--director")
    convert = commands.add_parser("import-xml", help="convert an AMC XML export to JSON")
    convert.add_argument("source", type=Path)
    merge = commands.add_parser("import", help="merge a JSON, XML, or CSV catalog")
    merge.add_argument("source", type=Path)
    export = commands.add_parser("export-xml", help="write an AMC-compatible XML catalog")
    export.add_argument("destination", type=Path)
    csv_export = commands.add_parser("export-csv", help="write a spreadsheet-compatible CSV")
    csv_export.add_argument("destination", type=Path)
    commands.add_parser("renumber", help="assign consecutive movie numbers")
    commands.add_parser("stats", help="show catalog statistics")
    commands.add_parser("gui", help="open the desktop catalog manager")
    inspect = commands.add_parser("inspect", help="identify a catalog without modifying it")
    inspect.add_argument("path", type=Path)
    inspect.add_argument("--json", action="store_true", dest="as_json")
    validate = commands.add_parser("validate", help="validate a catalog without modifying it")
    validate.add_argument("path", type=Path)
    validate.add_argument("--json", action="store_true", dest="as_json")
    return result


def main(argv: list[str] | None = None) -> int:
    args = parser().parse_args(argv)
    try:
        return _run(args)
    except (CatalogError, OSError, ValueError, KeyError) as error:
        print(f"amc: {error}", file=sys.stderr)
        return 2


def _run(args: argparse.Namespace) -> int:
    if args.command == "validate":
        diagnostics = validate_catalog(args.path)
        if args.as_json:
            print(json.dumps([asdict(item) for item in diagnostics], ensure_ascii=False, sort_keys=True))
        else:
            for item in diagnostics:
                location = f" at byte {item.offset}" if item.offset is not None else ""
                print(f"{item.severity.upper()} {item.code}{location}: {item.message}")
        return 1 if any(item.severity == "error" for item in diagnostics) else 0
    if args.command == "inspect":
        info = inspect_catalog(args.path)
        if args.as_json:
            print(json.dumps(info.to_dict(), ensure_ascii=False, sort_keys=True))
        else:
            for label, value in info.to_dict().items():
                print(f"{label.replace('_', ' ').title()}: {value if value is not None else '-'}")
        return 0
    if args.command == "import-xml":
        save(load(args.source), args.catalog)
        return 0
    if args.command == "gui":
        from .gui import run

        run(args.catalog)
        return 0
    catalog = _catalog(args.catalog)
    if args.command == "import":
        count = catalog.merge(load(args.source))
        save(catalog, args.catalog)
        print(f"Imported {count} movie(s)")
    elif args.command == "add":
        movie = catalog.add(Movie(title=args.title, year=args.year, director=args.director))
        save(catalog, args.catalog)
        print(f"Added #{movie.number}: {movie.display_title()}")
    elif args.command == "remove":
        movie = catalog.remove(args.number)
        save(catalog, args.catalog)
        print(f"Removed #{movie.number}: {movie.display_title()}")
    elif args.command == "edit":
        movie = catalog.get(args.number)
        for field in ("title", "year", "director"):
            value = getattr(args, field)
            if value is not None:
                setattr(movie, field, value)
        save(catalog, args.catalog)
        print(f"Updated #{movie.number}: {movie.display_title()}")
    elif args.command == "export-xml":
        save_xml(catalog, args.destination)
    elif args.command == "export-csv":
        save_csv(catalog, args.destination)
    elif args.command == "renumber":
        catalog.renumber()
        save(catalog, args.catalog)
    elif args.command == "stats":
        for label, value in catalog.statistics().items():
            print(f"{label.replace('_', ' ').title()}: {value if value is not None else '-'}")
    else:
        movies = catalog.search(args.query) if args.command == "search" else list(catalog)
        for movie in movies:
            year = f" ({movie.year})" if movie.year else ""
            print(f"{movie.number:>5}  {movie.display_title()}{year}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
