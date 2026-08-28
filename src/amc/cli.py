"""Command-line interface for managing catalogs."""

from __future__ import annotations

import argparse
import json
import os
import sys
from dataclasses import asdict
from pathlib import Path
from typing import overload

from .application import CatalogService
from .catalog import Catalog
from .errors import CatalogError
from .inspection import DEFAULT_MAX_INSPECT_BYTES, inspect_catalog, validate_catalog
from .model import Movie
from .native import NativeReadLimits, NativeWriteLimits
from .media import (
    DEFAULT_DISK_TAG_PATTERN,
    DEFAULT_MEDIA_EXTENSIONS,
    attach_media_pictures,
    discover_media,
    merge_media_parts,
    movie_from_media,
)
from .omdb import (
    DEFAULT_TIMEOUT as DEFAULT_OMDB_TIMEOUT,
    fetch_omdb_record,
    imdb_id_from_url,
    preview_omdb_update,
)
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


@overload
def _parse_crop(text: str) -> tuple[int, int, int, int]: ...
@overload
def _parse_crop(text: None) -> None: ...
def _parse_crop(text: str | None) -> tuple[int, int, int, int] | None:
    """Parse a ``--crop X,Y,WIDTH,HEIGHT`` option into four integers."""
    if text is None:
        return None
    try:
        parts = tuple(int(value) for value in text.split(","))
    except ValueError as error:
        raise ValueError("crop must be X,Y,WIDTH,HEIGHT integers") from error
    if len(parts) != 4:
        raise ValueError("crop must be X,Y,WIDTH,HEIGHT integers")
    return parts


def _parse_picture_assignments(assignments: list[str]) -> dict[int, str | Path]:
    """Parse repeated ``--assign NUMBER=PATH`` options into a mapping."""
    parsed: dict[int, str | Path] = {}
    for assignment in assignments:
        if "=" not in assignment:
            raise ValueError(f"invalid picture assignment: {assignment!r}")
        number_text, path_text = assignment.split("=", 1)
        try:
            number = int(number_text)
        except ValueError as error:
            raise ValueError(f"invalid movie number: {number_text!r}") from error
        if number in parsed:
            raise ValueError(f"movie number assigned more than once: {number}")
        parsed[number] = Path(path_text)
    return parsed


def _parse_picture_crops(crops: list[str]) -> dict[int, tuple[int, int, int, int]]:
    """Parse repeated ``--crop-for NUMBER=X,Y,WIDTH,HEIGHT`` options."""
    parsed: dict[int, tuple[int, int, int, int]] = {}
    for entry in crops:
        if "=" not in entry:
            raise ValueError(f"invalid crop assignment: {entry!r}")
        number_text, crop_text = entry.split("=", 1)
        try:
            number = int(number_text)
        except ValueError as error:
            raise ValueError(f"invalid movie number: {number_text!r}") from error
        if number in parsed:
            raise ValueError(f"movie number cropped more than once: {number}")
        parsed[number] = _parse_crop(crop_text)
    return parsed


def _add_export_scope_arguments(export_parser: argparse.ArgumentParser) -> None:
    """Shared "movies to include" scope and export-time sort, for every export command.

    Matches upstream's Export dialog (`docs/IMPLEMENTATION_PLAN.md` D6):
    "checked" scopes to checked movies the same way the desktop's Checked
    view filter does; "selected"/"visible" have no CLI equivalent since
    there is no interactive selection or search here.
    """
    export_parser.add_argument(
        "--scope",
        choices=("all", "checked"),
        default="all",
        help="movies to include: all movies, or only checked ones (default: all)",
    )
    export_parser.add_argument("--sort-by", help="movie field to sort the export by")
    export_parser.add_argument(
        "--sort-reverse", action="store_true", help="reverse the export sort order"
    )


def _export_scope_movies(catalog: Catalog, scope: str) -> list[Movie] | None:
    """Resolve ``--scope`` to an explicit movie list, or None for the whole catalog."""
    if scope == "all":
        return None
    return [movie for movie in catalog if movie.checked]


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
    borrower_remove = commands.add_parser("borrower-remove", help="remove an unused borrower name")
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
    picture_set_many = commands.add_parser(
        "picture-set-many",
        help="link or embed pictures for multiple movies in one atomic write",
    )
    picture_set_many.add_argument(
        "--assign",
        action="append",
        default=[],
        required=True,
        metavar="NUMBER=PATH",
        help="assign a picture source to a movie number; may be repeated",
    )
    picture_set_many.add_argument("--embed", action="store_true")
    picture_set_many.add_argument("--max-bytes", type=int, default=64 * 1024 * 1024)
    picture_set_many.add_argument("--max-pixels", type=int, default=40_000_000)
    picture_set_many.add_argument(
        "--crop",
        metavar="X,Y,WIDTH,HEIGHT",
        help="crop every embedded picture using the same rectangle, unless "
        "overridden per movie with --crop-for",
    )
    picture_set_many.add_argument(
        "--crop-for",
        action="append",
        default=[],
        metavar="NUMBER=X,Y,WIDTH,HEIGHT",
        help="crop one movie's embedded picture with its own rectangle, "
        "overriding --crop for that movie; may be repeated",
    )
    picture_clear = commands.add_parser("picture-clear", help="remove one or more movie pictures")
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
    media_import = commands.add_parser("import-media", help="add entries from media-file metadata")
    media_import.add_argument("paths", nargs="+", type=Path)
    media_import.add_argument("--recursive", action="store_true")
    media_import.add_argument(
        "--max-depth",
        type=int,
        help="scan at most N directory levels below each input directory (0 = top level)",
    )
    media_import.add_argument(
        "--title-filter-regex",
        help="regular expression removed from each filename-derived title",
    )
    media_import.add_argument(
        "--merge-parts",
        action="store_true",
        help="merge adjacent same-title CD1/CD2-style files into one movie",
    )
    media_import.add_argument(
        "--disk-tag-regex",
        default=DEFAULT_DISK_TAG_PATTERN,
        help="regular expression removed when matching media parts",
    )
    media_import.add_argument(
        "--import-pictures",
        choices=("link", "embed"),
        help="attach same-stem or folder poster images to imported movies",
    )
    media_import.add_argument(
        "--folder-picture-name",
        default="folder",
        help="fallback poster base name used by --import-pictures (default: folder)",
    )
    media_import.add_argument(
        "--extensions",
        help="comma-separated extensions to include, for example mkv,mp4,wav",
    )
    media_import.add_argument(
        "--progress",
        action="store_true",
        help="print 'Inspected N/TOTAL file(s)' to stderr while scanning a large tree",
    )
    media_import.add_argument(
        "--extract",
        choices=("full", "defer", "skip"),
        default="full",
        help="media metadata extraction mode (default: full)",
    )
    merge.add_argument(
        "--metadata",
        choices=("error", "keep", "replace", "namespace"),
        default="error",
        help="policy for conflicting catalog metadata (default: error)",
    )
    export = commands.add_parser("export-xml", help="write an AMC-compatible XML catalog")
    export.add_argument("destination", type=Path)
    _add_export_scope_arguments(export)
    csv_export = commands.add_parser("export-csv", help="write a spreadsheet-compatible CSV")
    csv_export.add_argument("destination", type=Path)
    _add_export_scope_arguments(csv_export)
    html_export = commands.add_parser("export-html", help="write a static HTML catalog")
    html_export.add_argument("destination", type=Path)
    html_export.add_argument("--template", type=Path)
    html_export.add_argument("--row-template", type=Path)
    _add_export_scope_arguments(html_export)
    ant_html_export = commands.add_parser(
        "export-html-template",
        help="render Ant Movie Catalog's own $$TAG_NAME HTML export templates",
        description=(
            "Render a template written for real Ant Movie Catalog's HTML export "
            "($$ITEM_TITLE-style placeholders), not AMC Python's own {{MOVIES}} "
            "template (see 'export-html'). At least one of --full-template/"
            "--individual-template is required."
        ),
    )
    ant_html_export.add_argument("destination", type=Path, help="path for the full-catalog page")
    ant_html_export.add_argument("--full-template", type=Path)
    ant_html_export.add_argument("--individual-template", type=Path)
    ant_html_export.add_argument(
        "--individual-dir",
        type=Path,
        help="directory for one page per movie (default: destination's own directory)",
    )
    ant_html_export.add_argument(
        "--individual-filename",
        default="{number}.html",
        help="filename pattern for individual pages, e.g. '{number}.html' (default)",
    )
    ant_html_export.add_argument("--line-break", default="<br>")
    _add_export_scope_arguments(ant_html_export)
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
    _add_export_scope_arguments(native_export)
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
    inspect.add_argument(
        "--max-input-bytes",
        type=int,
        help="reject files larger than this before parsing (default: 1 TiB)",
    )
    validate = commands.add_parser("validate", help="validate a catalog without modifying it")
    validate.add_argument("path", type=Path)
    validate.add_argument("--json", action="store_true", dest="as_json")
    validate.add_argument(
        "--max-input-bytes",
        type=int,
        help="reject files larger than this before parsing (default: 1 TiB)",
    )
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
    imdb = commands.add_parser(
        "imdb-lookup",
        help="preview or apply an OMDb-sourced IMDb metadata update for a movie",
    )
    imdb.add_argument("number", type=int)
    imdb.add_argument(
        "--api-key",
        help="OMDb API key (default: the OMDB_API_KEY environment variable)",
    )
    imdb.add_argument(
        "--imdb-id",
        help="look up this IMDb title ID (default: extracted from the movie's "
        "URL if it is an imdb.com link, otherwise the movie's title/year)",
    )
    imdb.add_argument("--timeout", type=float, default=DEFAULT_OMDB_TIMEOUT)
    imdb.add_argument(
        "--apply",
        action="store_true",
        help="write the previewed changes to the catalog (default: preview only)",
    )
    return result


def main(argv: list[str] | None = None) -> int:
    args = parser().parse_args(argv)
    try:
        return _run(args)
    # CatalogError/OSError/TypeError/ValueError are the documented service-layer
    # failures; LookupError covers KeyError, Catalog.get()'s (and hence
    # replace/remove/check-out/check-in/set-checked/picture) signal for a movie
    # number that does not exist. See gui.py's _SERVICE_ERRORS for the same
    # boundary on the desktop side.
    except (CatalogError, OSError, TypeError, ValueError, LookupError) as error:
        print(f"amc: {error}", file=sys.stderr)
        return EXIT_ERROR


def _run(args: argparse.Namespace) -> int:
    if args.command == "inspect-script":
        print(json.dumps(inspect_script(args.path).to_dict(), ensure_ascii=False, sort_keys=True))
        return EXIT_SUCCESS
    if args.command == "list-scripts":
        print(
            json.dumps(
                [item.to_dict() for item in discover_scripts(args.directory)],
                ensure_ascii=False,
                sort_keys=True,
            )
        )
        return EXIT_SUCCESS
    if args.command == "configure-script":
        options = {name: int(value) for name, value in _assignments(args.option, "script option")}
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
        max_input_bytes = (
            DEFAULT_MAX_INSPECT_BYTES if args.max_input_bytes is None else args.max_input_bytes
        )
        diagnostics = validate_catalog(args.path, max_file_bytes=max_input_bytes)
        if args.as_json:
            print(
                json.dumps(
                    [asdict(item) for item in diagnostics], ensure_ascii=False, sort_keys=True
                )
            )
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
        max_input_bytes = (
            DEFAULT_MAX_INSPECT_BYTES if args.max_input_bytes is None else args.max_input_bytes
        )
        info = inspect_catalog(args.path, max_file_bytes=max_input_bytes)
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
                    if args.max_input_bytes is None
                    else args.max_input_bytes
                ),
                max_movies=(defaults.max_movies if args.max_movies is None else args.max_movies),
                max_picture_bytes=(
                    defaults.max_picture_bytes
                    if args.max_picture_bytes is None
                    else args.max_picture_bytes
                ),
                max_total_picture_bytes=(
                    defaults.max_total_picture_bytes
                    if args.max_total_picture_bytes is None
                    else args.max_total_picture_bytes
                ),
                max_total_string_bytes=(
                    defaults.max_total_string_bytes
                    if args.max_string_bytes is None
                    else args.max_string_bytes
                ),
                max_custom_fields=(
                    defaults.max_custom_fields
                    if args.max_custom_fields is None
                    else args.max_custom_fields
                ),
                max_list_values_per_field=(
                    defaults.max_list_values_per_field
                    if args.max_list_values is None
                    else args.max_list_values
                ),
                max_extras_per_movie=(
                    defaults.max_extras_per_movie
                    if args.max_extras_per_movie is None
                    else args.max_extras_per_movie
                ),
                max_total_extras=(
                    defaults.max_total_extras
                    if args.max_total_extras is None
                    else args.max_total_extras
                ),
            ),
        )
        print(f"Imported {count} movie(s)")
    elif args.command == "import-media":
        extensions = None
        if args.extensions:
            extensions = (
                DEFAULT_MEDIA_EXTENSIONS
                if args.extensions.strip().casefold() == "default"
                else {item.strip() for item in args.extensions.split(",") if item.strip()}
            )
        paths = discover_media(
            args.paths,
            recursive=args.recursive,
            max_depth=args.max_depth,
            extensions=extensions,
        )
        total = len(paths)
        movies = []
        for index, media_path in enumerate(paths, start=1):
            movies.append(
                movie_from_media(
                    media_path,
                    extraction=args.extract,
                    title_filter_pattern=args.title_filter_regex,
                )
            )
            if args.progress:
                print(f"Inspected {index}/{total} file(s)", file=sys.stderr)
        source_count = len(movies)
        if args.import_pictures:
            movies = attach_media_pictures(
                list(zip(paths, movies)),
                embed=args.import_pictures == "embed",
                folder_picture_name=args.folder_picture_name,
            )
        if args.merge_parts:
            movies = merge_media_parts(
                list(zip(paths, movies)), disk_tag_pattern=args.disk_tag_regex
            )
        service.add_many(movies)
        if args.merge_parts:
            print(f"Imported {len(movies)} movie(s) from {source_count} media file(s)")
        else:
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
        service.export_loan_history(args.destination, catalog_name=args.catalog_name)
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
        movie = service.set_picture(
            args.number,
            args.source,
            embed=args.embed,
            max_bytes=args.max_bytes,
            max_pixels=args.max_pixels,
            crop=_parse_crop(args.crop),
        )
        print(f"Updated picture for #{movie.number}: {movie.picture}")
    elif args.command == "picture-set-many":
        movies = service.set_picture_many(
            _parse_picture_assignments(args.assign),
            embed=args.embed,
            max_bytes=args.max_bytes,
            max_pixels=args.max_pixels,
            crop=_parse_crop(args.crop),
            crops=_parse_picture_crops(args.crop_for),
        )
        for movie in movies:
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
    elif args.command == "imdb-lookup":
        movie = catalog.get(args.number)
        api_key = args.api_key or os.environ.get("OMDB_API_KEY", "")
        imdb_id = args.imdb_id or imdb_id_from_url(movie.url)
        record = fetch_omdb_record(
            api_key=api_key,
            imdb_id=imdb_id,
            title="" if imdb_id else movie.display_title(),
            year=None if imdb_id else movie.year,
            timeout=args.timeout,
        )
        preview = preview_omdb_update(movie, record)
        if not preview.changes:
            print(f"No changes for #{movie.number}: {movie.display_title()}")
        elif args.apply:
            replacement = service.replace(args.number, preview.movie)
            print(f"Updated #{replacement.number}: {replacement.display_title()}")
        else:
            print(f"Preview for #{movie.number}: {movie.display_title()} (use --apply to save)")
        if preview.changes:
            for change in preview.changes:
                print(f"  {change.field}: {change.before!r} -> {change.after!r}")
    elif args.command == "export-xml":
        service.export(
            args.destination,
            format="xml",
            movies=_export_scope_movies(service.catalog, args.scope),
            sort_by=args.sort_by,
            sort_reverse=args.sort_reverse,
        )
    elif args.command == "export-csv":
        service.export(
            args.destination,
            format="csv",
            movies=_export_scope_movies(service.catalog, args.scope),
            sort_by=args.sort_by,
            sort_reverse=args.sort_reverse,
        )
    elif args.command == "export-html":
        service.export(
            args.destination,
            format="html",
            template=args.template,
            row_template=args.row_template,
            movies=_export_scope_movies(service.catalog, args.scope),
            sort_by=args.sort_by,
            sort_reverse=args.sort_reverse,
        )
    elif args.command == "export-html-template":
        written = service.export_html_template(
            args.destination,
            full_template=args.full_template,
            individual_template=args.individual_template,
            individual_dir=args.individual_dir,
            individual_filename=args.individual_filename,
            line_break=args.line_break,
            movies=_export_scope_movies(service.catalog, args.scope),
            sort_by=args.sort_by,
            sort_reverse=args.sort_reverse,
        )
        print(f"Wrote {len(written)} file(s)")
    elif args.command == "export-amc":
        write_defaults = NativeWriteLimits()
        service.export(
            args.destination,
            format="amc",
            native_encoding=args.encoding,
            native_limits=NativeWriteLimits(
                max_file_bytes=(
                    write_defaults.max_file_bytes
                    if args.max_output_bytes is None
                    else args.max_output_bytes
                ),
                max_total_string_bytes=(
                    write_defaults.max_total_string_bytes
                    if args.max_string_bytes is None
                    else args.max_string_bytes
                ),
                max_picture_bytes=(
                    write_defaults.max_picture_bytes
                    if args.max_picture_bytes is None
                    else args.max_picture_bytes
                ),
                max_total_picture_bytes=(
                    write_defaults.max_total_picture_bytes
                    if args.max_total_picture_bytes is None
                    else args.max_total_picture_bytes
                ),
                max_movies=(
                    write_defaults.max_movies if args.max_movies is None else args.max_movies
                ),
                max_custom_fields=(
                    write_defaults.max_custom_fields
                    if args.max_custom_fields is None
                    else args.max_custom_fields
                ),
                max_list_values_per_field=(
                    write_defaults.max_list_values_per_field
                    if args.max_list_values is None
                    else args.max_list_values
                ),
                max_extras_per_movie=(
                    write_defaults.max_extras_per_movie
                    if args.max_extras_per_movie is None
                    else args.max_extras_per_movie
                ),
                max_total_extras=(
                    write_defaults.max_total_extras
                    if args.max_total_extras is None
                    else args.max_total_extras
                ),
            ),
            movies=_export_scope_movies(service.catalog, args.scope),
            sort_by=args.sort_by,
            sort_reverse=args.sort_reverse,
        )
    elif args.command == "renumber":
        service.renumber()
    elif args.command == "stats":
        statistics = catalog.statistics()
        if args.as_json:
            print(json.dumps(statistics, ensure_ascii=False, sort_keys=True))
        else:
            for stat_label, stat_value in statistics.items():
                print(
                    f"{stat_label.replace('_', ' ').title()}: "
                    f"{stat_value if stat_value is not None else '-'}"
                )
    elif args.command == "duplicates":
        groups = catalog.duplicates()
        if args.as_json:
            print(
                json.dumps(
                    [[movie.to_dict() for movie in group] for group in groups], ensure_ascii=False
                )
            )
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
