"""Command-line interface for managing catalogs."""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import asdict
from pathlib import Path

from .application import CatalogService
from .errors import CatalogError
from .inspection import inspect_catalog, validate_catalog
from .model import Movie
from .native import NativeReadLimits, NativeWriteLimits
from .media import discover_media, movie_from_media
from .scripts import (
    configure_script,
    discover_scripts,
    inspect_script,
    load_script_configuration,
    save_script_configuration,
)

EXIT_SUCCESS = 0
EXIT_INVALID_CATALOG = 1
EXIT_ERROR = 2


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
    loan_out = commands.add_parser("loan-out", help="check out a movie to a borrower")
    loan_out.add_argument("number", type=int)
    loan_out.add_argument("borrower")
    loan_out.add_argument("--include-media-label", action="store_true")
    loan_out.add_argument("--include-native-number", action="store_true")
    loan_in = commands.add_parser("loan-in", help="check in a loaned movie")
    loan_in.add_argument("number", type=int)
    loan_in.add_argument("--include-media-label", action="store_true")
    loan_in.add_argument("--include-native-number", action="store_true")
    loan_history = commands.add_parser("loan-history", help="show loan history")
    loan_history.add_argument("--json", action="store_true", dest="as_json")
    loan_export = commands.add_parser(
        "loan-history-export", help="export upstream-style tab-separated loan history"
    )
    loan_export.add_argument("destination", type=Path)
    loan_export.add_argument("--catalog-name")
    borrower_list = commands.add_parser("borrowers", help="list borrower names")
    borrower_list.add_argument("--json", action="store_true", dest="as_json")
    borrower_add = commands.add_parser("borrower-add", help="add a borrower name")
    borrower_add.add_argument("name")
    borrower_remove = commands.add_parser(
        "borrower-remove", help="remove an unused borrower name"
    )
    borrower_remove.add_argument("name")
    picture_set = commands.add_parser("picture-set", help="link or embed a movie picture")
    picture_set.add_argument("number", type=int)
    picture_set.add_argument("source", type=Path)
    picture_set.add_argument("--embed", action="store_true")
    picture_set.add_argument("--max-bytes", type=int, default=64 * 1024 * 1024)
    picture_set.add_argument("--max-pixels", type=int, default=40_000_000)
    picture_set.add_argument(
        "--crop",
        metavar="X,Y,WIDTH,HEIGHT",
        help="crop an embedded picture before storing it",
    )
    picture_clear = commands.add_parser(
        "picture-clear", help="remove one or more movie pictures"
    )
    picture_clear.add_argument("numbers", type=int, nargs="+")
    picture_export = commands.add_parser("picture-export", help="export a movie picture")
    picture_export.add_argument("number", type=int)
    picture_export.add_argument("destination", type=Path)
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
        "--native-encoding",
        default="cp1252",
        help="codec for native AMC strings (default: cp1252)",
    )
    merge.add_argument("--max-input-bytes", type=int)
    merge.add_argument("--max-movies", type=int)
    merge.add_argument("--max-picture-bytes", type=int)
    merge.add_argument("--max-total-picture-bytes", type=int)
    merge.add_argument("--max-string-bytes", type=int)
    merge.add_argument("--max-custom-fields", type=int)
    merge.add_argument("--max-list-values", type=int)
    merge.add_argument("--max-extras-per-movie", type=int)
    merge.add_argument("--max-total-extras", type=int)
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
        "export-amc",
        help="write an experimental, source-derived AMC 4.2 native catalog",
        description=(
            "Write an experimental AMC 4.2 catalog. Output has not been verified "
            "with upstream AMC; an existing destination is preserved as .bak."
        ),
    )
    native_export.add_argument("destination", type=Path)
    native_export.add_argument("--encoding", default="cp1252")
    native_export.add_argument("--max-output-bytes", type=int)
    native_export.add_argument("--max-string-bytes", type=int)
    native_export.add_argument("--max-picture-bytes", type=int)
    native_export.add_argument("--max-total-picture-bytes", type=int)
    native_export.add_argument("--max-movies", type=int)
    native_export.add_argument("--max-custom-fields", type=int)
    native_export.add_argument("--max-list-values", type=int)
    native_export.add_argument("--max-extras-per-movie", type=int)
    native_export.add_argument("--max-total-extras", type=int)
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
    configure = commands.add_parser(
        "configure-script",
        help="validate legacy script options without executing the script",
    )
    configure.add_argument("path", type=Path)
    configure.add_argument("--option", action="append", default=[], metavar="NAME=INTEGER")
    configure.add_argument("--parameter", action="append", default=[], metavar="NAME=VALUE")
    configure.add_argument("--load", type=Path, metavar="SETTINGS")
    configure.add_argument("--save", type=Path, metavar="SETTINGS")
    return result


def main(argv: list[str] | None = None) -> int:
    args = parser().parse_args(argv)
    try:
        return _run(args)
    except (CatalogError, OSError, TypeError, ValueError, LookupError) as error:
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
    if args.command == "configure-script":
        options = {
            name: int(value)
            for name, value in _assignments(args.option, "script option")
        }
        parameters = dict(_assignments(args.parameter, "script parameter"))
        configured = inspect_script(args.path)
        if args.load:
            configured = load_script_configuration(configured, args.load)
        configured = configure_script(configured, options=options, parameters=parameters)
        if args.save:
            save_script_configuration(configured, args.save)
        print(json.dumps(configured.to_dict(), ensure_ascii=False, sort_keys=True))
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
        CatalogService.convert_to(args.source, args.catalog)
        return EXIT_SUCCESS
    if args.command == "gui":
        from .gui import run

        run(args.catalog)
        return EXIT_SUCCESS
    if args.command == "backup":
        CatalogService(args.catalog).backup(args.destination)
        return EXIT_SUCCESS
    if args.command == "restore":
        CatalogService.restore_to(args.source, args.catalog)
        return EXIT_SUCCESS
    service = CatalogService(args.catalog)
    catalog = service.catalog
    if args.command == "import":
        defaults = NativeReadLimits()
        count = service.import_from(
            args.source,
            collision=args.collision,
            metadata=args.metadata,
            native_encoding=args.native_encoding,
            native_limits=NativeReadLimits(
                max_file_bytes=(
                    defaults.max_file_bytes
                    if args.max_input_bytes is None else args.max_input_bytes
                ),
                max_movies=(
                    defaults.max_movies if args.max_movies is None else args.max_movies
                ),
                max_picture_bytes=(
                    defaults.max_picture_bytes
                    if args.max_picture_bytes is None else args.max_picture_bytes
                ),
                max_total_picture_bytes=(
                    defaults.max_total_picture_bytes
                    if args.max_total_picture_bytes is None
                    else args.max_total_picture_bytes
                ),
                max_total_string_bytes=(
                    defaults.max_total_string_bytes
                    if args.max_string_bytes is None else args.max_string_bytes
                ),
                max_custom_fields=(
                    defaults.max_custom_fields
                    if args.max_custom_fields is None else args.max_custom_fields
                ),
                max_list_values_per_field=(
                    defaults.max_list_values_per_field
                    if args.max_list_values is None else args.max_list_values
                ),
                max_extras_per_movie=(
                    defaults.max_extras_per_movie
                    if args.max_extras_per_movie is None
                    else args.max_extras_per_movie
                ),
                max_total_extras=(
                    defaults.max_total_extras
                    if args.max_total_extras is None else args.max_total_extras
                ),
            ),
        )
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
        service.add_many(movies)
        print(f"Imported {len(movies)} media file(s)")
    elif args.command == "add":
        movie = service.add(Movie(title=args.title, year=args.year, director=args.director))
        print(f"Added #{movie.number}: {movie.display_title()}")
    elif args.command == "remove":
        movie = service.remove(args.number)
        print(f"Removed #{movie.number}: {movie.display_title()}")
    elif args.command == "loan-out":
        movie = service.check_out(
            args.number,
            args.borrower,
            include_media_label=args.include_media_label,
            include_native_number=args.include_native_number,
        )
        print(f"Checked out #{movie.number} to {movie.borrower}")
    elif args.command == "loan-in":
        movie = service.check_in(
            args.number,
            include_media_label=args.include_media_label,
            include_native_number=args.include_native_number,
        )
        print(f"Checked in #{movie.number}: {movie.display_title()}")
    elif args.command == "loan-history":
        events = service.loan_history()
        if args.as_json:
            print(json.dumps([event.to_dict() for event in events], ensure_ascii=False))
        else:
            for event in events:
                print(
                    f"{event.timestamp}  {event.action.upper():>3}  "
                    f"#{event.movie_number} {event.title} — {event.borrower}"
                )
    elif args.command == "loan-history-export":
        service.export_loan_history(
            args.destination, catalog_name=args.catalog_name
        )
    elif args.command == "borrowers":
        names = service.borrowers()
        if args.as_json:
            print(json.dumps(names, ensure_ascii=False))
        else:
            for name in names:
                print(name)
    elif args.command == "borrower-add":
        print(f"Added borrower: {service.add_borrower(args.name)}")
    elif args.command == "borrower-remove":
        print(f"Removed borrower: {service.remove_borrower(args.name)}")
    elif args.command == "picture-set":
        crop = None
        if args.crop is not None:
            try:
                parts = tuple(int(value) for value in args.crop.split(","))
            except ValueError as error:
                raise ValueError("crop must be X,Y,WIDTH,HEIGHT integers") from error
            if len(parts) != 4:
                raise ValueError("crop must be X,Y,WIDTH,HEIGHT integers")
            crop = parts
        movie = service.set_picture(
            args.number,
            args.source,
            embed=args.embed,
            max_bytes=args.max_bytes,
            max_pixels=args.max_pixels,
            crop=crop,
        )
        print(f"Updated picture for #{movie.number}: {movie.picture}")
    elif args.command == "picture-clear":
        movies = service.clear_picture_many(args.numbers)
        for movie in movies:
            print(f"Cleared picture for #{movie.number}")
    elif args.command == "picture-export":
        service.export_picture(args.number, args.destination)
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
        replacement = service.replace(args.number, Movie.from_dict(values))
        print(f"Updated #{replacement.number}: {replacement.display_title()}")
    elif args.command == "export-xml":
        service.export(args.destination, format="xml")
    elif args.command == "export-csv":
        service.export(args.destination, format="csv")
    elif args.command == "export-html":
        service.export(
            args.destination,
            format="html",
            template=args.template,
            row_template=args.row_template,
        )
    elif args.command == "export-amc":
        defaults = NativeWriteLimits()
        service.export(
            args.destination,
            format="amc",
            native_encoding=args.encoding,
            native_limits=NativeWriteLimits(
                max_file_bytes=(
                    defaults.max_file_bytes
                    if args.max_output_bytes is None else args.max_output_bytes
                ),
                max_total_string_bytes=(
                    defaults.max_total_string_bytes
                    if args.max_string_bytes is None else args.max_string_bytes
                ),
                max_picture_bytes=(
                    defaults.max_picture_bytes
                    if args.max_picture_bytes is None else args.max_picture_bytes
                ),
                max_total_picture_bytes=(
                    defaults.max_total_picture_bytes
                    if args.max_total_picture_bytes is None
                    else args.max_total_picture_bytes
                ),
                max_movies=(
                    defaults.max_movies
                    if args.max_movies is None else args.max_movies
                ),
                max_custom_fields=(
                    defaults.max_custom_fields
                    if args.max_custom_fields is None else args.max_custom_fields
                ),
                max_list_values_per_field=(
                    defaults.max_list_values_per_field
                    if args.max_list_values is None else args.max_list_values
                ),
                max_extras_per_movie=(
                    defaults.max_extras_per_movie
                    if args.max_extras_per_movie is None
                    else args.max_extras_per_movie
                ),
                max_total_extras=(
                    defaults.max_total_extras
                    if args.max_total_extras is None else args.max_total_extras
                ),
            ),
        )
    elif args.command == "renumber":
        service.renumber()
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


def _assignments(values: list[str], label: str) -> list[tuple[str, str]]:
    """Split repeatable CLI NAME=VALUE assignments with stable diagnostics."""
    result = []
    names = set()
    for item in values:
        if "=" not in item:
            raise ValueError(f"{label} must use NAME=VALUE")
        name, value = item.split("=", 1)
        normalized = name.strip().casefold()
        if not normalized:
            raise ValueError(f"{label} name cannot be empty")
        if normalized in names:
            raise ValueError(f"duplicate {label}: {name!r}")
        names.add(normalized)
        result.append((name, value))
    return result


if __name__ == "__main__":
    raise SystemExit(main())
