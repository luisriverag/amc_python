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
from .media import discover_media, movie_from_media
from .scripts import discover_scripts, inspect_script
from .storage import copy_catalog, load, save, save_csv, save_html, save_native, save_xml

EXIT_SUCCESS = 0
EXIT_INVALID_CATALOG = 1
EXIT_ERROR = 2


def _catalog(path: Path) -> Catalog:
    return load(path) if path.exists() else Catalog()


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(prog="amc", description="Portable Ant Movie Catalog")
    result.add_argument("--catalog", "-c", type=Path, default=Path("catalog.json"))
    commands = result.add_subparsers(dest="command", required=True)
    listing = commands.add_parser("list", help="list movies")
    listing.add_argument("--json", action="store_true", dest="as_json")
    find = commands.add_parser("search", help="search movie metadata")
    find.add_argument("query")
    find.add_argument("--json", action="store_true", dest="as_json")
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
    edit.add_argument(
        "--set",
        action="append",
        default=[],
        metavar="FIELD=JSON",
        help="set any movie field using a JSON value; may be repeated",
    )
    convert = commands.add_parser("import-xml", help="convert an AMC XML export to JSON")
    convert.add_argument("source", type=Path)
    merge = commands.add_parser("import", help="merge a JSON, XML, or CSV catalog")
    merge.add_argument("source", type=Path)
    merge.add_argument(
        "--collision",
        choices=("error", "skip", "replace", "renumber"),
        default="renumber",
        help="policy for duplicate movie numbers (default: renumber)",
    )
    media_import = commands.add_parser(
        "import-media", help="add entries from media-file metadata"
    )
    media_import.add_argument("paths", nargs="+", type=Path)
    media_import.add_argument("--recursive", action="store_true")
    media_import.add_argument(
        "--extensions",
        help="comma-separated extensions to include, for example mkv,mp4,wav",
    )
    merge.add_argument(
        "--metadata",
        choices=("error", "keep", "replace", "namespace"),
        default="error",
        help="policy for conflicting catalog metadata (default: error)",
    )
    export = commands.add_parser("export-xml", help="write an AMC-compatible XML catalog")
    export.add_argument("destination", type=Path)
    csv_export = commands.add_parser("export-csv", help="write a spreadsheet-compatible CSV")
    csv_export.add_argument("destination", type=Path)
    html_export = commands.add_parser("export-html", help="write a static HTML catalog")
    html_export.add_argument("destination", type=Path)
    html_export.add_argument("--template", type=Path)
    html_export.add_argument("--row-template", type=Path)
    native_export = commands.add_parser(
        "export-amc", help="write a source-derived AMC 4.2 native catalog"
    )
    native_export.add_argument("destination", type=Path)
    commands.add_parser("renumber", help="assign consecutive movie numbers")
    backup = commands.add_parser("backup", help="copy the catalog to a validated backup")
    backup.add_argument("destination", type=Path)
    restore = commands.add_parser("restore", help="replace the catalog from a validated backup")
    restore.add_argument("source", type=Path)
    stats = commands.add_parser("stats", help="show catalog statistics")
    stats.add_argument("--json", action="store_true", dest="as_json")
    duplicates = commands.add_parser("duplicates", help="find duplicate title/year groups")
    duplicates.add_argument("--json", action="store_true", dest="as_json")
    commands.add_parser("gui", help="open the desktop catalog manager")
    inspect = commands.add_parser("inspect", help="identify a catalog without modifying it")
    inspect.add_argument("path", type=Path)
    inspect.add_argument("--json", action="store_true", dest="as_json")
    validate = commands.add_parser("validate", help="validate a catalog without modifying it")
    validate.add_argument("path", type=Path)
    validate.add_argument("--json", action="store_true", dest="as_json")
    script = commands.add_parser(
        "inspect-script", help="inspect legacy script metadata without executing it"
    )
    script.add_argument("path", type=Path)
    scripts = commands.add_parser(
        "list-scripts", help="list legacy script metadata without executing scripts"
    )
    scripts.add_argument("directory", type=Path)
    return result


def main(argv: list[str] | None = None) -> int:
    args = parser().parse_args(argv)
    try:
        return _run(args)
    except (CatalogError, OSError, TypeError, ValueError, KeyError) as error:
        print(f"amc: {error}", file=sys.stderr)
        return EXIT_ERROR


def _run(args: argparse.Namespace) -> int:
    if args.command == "inspect-script":
        print(json.dumps(inspect_script(args.path).to_dict(), ensure_ascii=False, sort_keys=True))
        return EXIT_SUCCESS
    if args.command == "list-scripts":
        print(json.dumps(
            [item.to_dict() for item in discover_scripts(args.directory)],
            ensure_ascii=False,
            sort_keys=True,
        ))
        return EXIT_SUCCESS
    if args.command == "validate":
        diagnostics = validate_catalog(args.path)
        if args.as_json:
            print(json.dumps([asdict(item) for item in diagnostics], ensure_ascii=False, sort_keys=True))
        else:
            for item in diagnostics:
                location = f" at byte {item.offset}" if item.offset is not None else ""
                print(f"{item.severity.upper()} {item.code}{location}: {item.message}")
        return (
            EXIT_INVALID_CATALOG
            if any(item.severity == "error" for item in diagnostics)
            else EXIT_SUCCESS
        )
    if args.command == "inspect":
        info = inspect_catalog(args.path)
        if args.as_json:
            print(json.dumps(info.to_dict(), ensure_ascii=False, sort_keys=True))
        else:
            for label, value in info.to_dict().items():
                print(f"{label.replace('_', ' ').title()}: {value if value is not None else '-'}")
        return EXIT_SUCCESS
    if args.command == "import-xml":
        save(load(args.source), args.catalog)
        return EXIT_SUCCESS
    if args.command == "gui":
        from .gui import run

        run(args.catalog)
        return EXIT_SUCCESS
    if args.command == "backup":
        copy_catalog(args.catalog, args.destination)
        return EXIT_SUCCESS
    if args.command == "restore":
        copy_catalog(args.source, args.catalog)
        return EXIT_SUCCESS
    catalog = _catalog(args.catalog)
    if args.command == "import":
        count = catalog.merge(
            load(args.source), collision=args.collision, metadata=args.metadata
        )
        save(catalog, args.catalog)
        print(f"Imported {count} movie(s)")
    elif args.command == "import-media":
        extensions = (
            {item.strip() for item in args.extensions.split(",") if item.strip()}
            if args.extensions
            else None
        )
        paths = discover_media(
            args.paths, recursive=args.recursive, extensions=extensions
        )
        movies = [movie_from_media(path) for path in paths]
        for movie in movies:
            catalog.add(movie)
        save(catalog, args.catalog)
        print(f"Imported {len(movies)} media file(s)")
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
        values = movie.to_dict()
        for field in ("title", "year", "director"):
            value = getattr(args, field)
            if value is not None:
                values[field] = value
        for assignment in args.set:
            if "=" not in assignment:
                raise ValueError(f"invalid field assignment: {assignment!r}")
            field, raw_value = assignment.split("=", 1)
            if field not in values or field == "number":
                raise ValueError(f"unknown or immutable movie field: {field}")
            try:
                values[field] = json.loads(raw_value)
            except json.JSONDecodeError as error:
                raise ValueError(
                    f"invalid JSON value for movie field {field}: {error.msg}"
                ) from error
        replacement = catalog.replace(args.number, Movie.from_dict(values))
        save(catalog, args.catalog)
        print(f"Updated #{replacement.number}: {replacement.display_title()}")
    elif args.command == "export-xml":
        save_xml(catalog, args.destination)
    elif args.command == "export-csv":
        save_csv(catalog, args.destination)
    elif args.command == "export-html":
        save_html(
            catalog,
            args.destination,
            template=args.template,
            row_template=args.row_template,
        )
    elif args.command == "export-amc":
        save_native(catalog, args.destination)
    elif args.command == "renumber":
        catalog.renumber()
        save(catalog, args.catalog)
    elif args.command == "stats":
        statistics = catalog.statistics()
        if args.as_json:
            print(json.dumps(statistics, ensure_ascii=False, sort_keys=True))
        else:
            for label, value in statistics.items():
                print(f"{label.replace('_', ' ').title()}: {value if value is not None else '-'}")
    elif args.command == "duplicates":
        groups = catalog.duplicates()
        if args.as_json:
            print(json.dumps([
                [movie.to_dict() for movie in group] for group in groups
            ], ensure_ascii=False))
        else:
            for group in groups:
                print(", ".join(f"#{movie.number} {movie.display_title()}" for movie in group))
    else:
        movies = catalog.search(args.query) if args.command == "search" else list(catalog)
        if args.as_json:
            print(json.dumps([movie.to_dict() for movie in movies], ensure_ascii=False))
        else:
            for movie in movies:
                year = f" ({movie.year})" if movie.year else ""
                print(f"{movie.number:>5}  {movie.display_title()}{year}")
    return EXIT_SUCCESS


if __name__ == "__main__":
    raise SystemExit(main())
