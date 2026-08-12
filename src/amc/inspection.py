"""Non-destructive format probing and catalog inspection."""

from __future__ import annotations

import csv
import json
import xml.etree.ElementTree as ET
from dataclasses import asdict, dataclass
from pathlib import Path

from .errors import (
    CatalogError,
    CorruptCatalogError,
    Diagnostic,
    UnsupportedFormatError,
    UnsupportedVersionError,
)
from .native import NATIVE_HEADER_SIZE, identify_native_header, read_native_catalog


@dataclass(frozen=True, slots=True)
class CatalogInfo:
    path: str
    format: str
    version: str | int | None
    movies: int | None
    size: int

    def to_dict(self) -> dict[str, str | int | None]:
        return asdict(self)


def inspect_catalog(path: str | Path) -> CatalogInfo:
    """Inspect a supported catalog without modifying it or loading its movie data."""
    path = Path(path)
    try:
        size = path.stat().st_size
        with path.open("rb") as stream:
            prefix = stream.read(4096)
    except OSError:
        raise
    stripped = prefix.lstrip(b"\xef\xbb\xbf\x00\t\r\n ")
    suffix = path.suffix.casefold()

    native_header = prefix[:NATIVE_HEADER_SIZE]
    if prefix.startswith(b" AMC_") or suffix == ".amc":
        version = identify_native_header(native_header, file_size=size)
        return CatalogInfo(str(path), "amc-native", version, None, size)
    if stripped.startswith((b"{", b"[")):
        return _inspect_json(path, size)
    if stripped.startswith(b"<"):
        return _inspect_xml(path, size)
    if suffix == ".csv":
        return _inspect_csv(path, size)
    raise UnsupportedFormatError(f"cannot identify catalog format: {path}")


def validate_catalog(path: str | Path) -> list[Diagnostic]:
    """Return diagnostics instead of raising for recognized validation failures."""
    try:
        info = inspect_catalog(path)
    except CatalogError as error:
        return [Diagnostic(error.code, str(error), offset=error.offset)]
    except OSError as error:
        return [Diagnostic("io_error", str(error))]
    if info.format == "amc-native":
        if info.version in {"1.0", "1.1", "2.1", "3.0"}:
            message = f"recognized legacy native AMC {info.version} header; records were not validated"
        else:
            try:
                catalog = read_native_catalog(path)
            except CatalogError as error:
                return [Diagnostic(error.code, str(error), offset=error.offset)]
            except OSError as error:
                return [Diagnostic("io_error", str(error))]
            message = (
                f"parsed source-derived native AMC {info.version} structure with "
                f"{len(catalog.movies)} movie(s); upstream-fixture verification is pending"
            )
        return [Diagnostic("native_structure_unverified", message, severity="warning")]
    return [
        Diagnostic(
            "catalog_valid",
            f"valid {info.format} catalog with {info.movies} movie(s)",
            severity="info",
        )
    ]


def _inspect_json(path: Path, size: int) -> CatalogInfo:
    try:
        with path.open(encoding="utf-8") as stream:
            value = json.load(stream)
    except (UnicodeError, json.JSONDecodeError) as error:
        raise CorruptCatalogError(f"invalid JSON catalog: {error}", offset=getattr(error, "pos", None)) from error
    if isinstance(value, dict):
        format_name = value.get("format", "json")
        version = value.get("version")
        movies = value.get("movies")
        if format_name not in {"json", "amc-python"}:
            raise UnsupportedFormatError(f"unsupported catalog format: {format_name!r}")
        if format_name == "amc-python" and version != 1:
            raise UnsupportedVersionError(f"unsupported catalog version: {version!r}")
    else:
        format_name, version, movies = "json", None, value
    if not isinstance(movies, list):
        raise CorruptCatalogError("JSON catalog must contain a movie list")
    return CatalogInfo(str(path), format_name, version, len(movies), size)


def _inspect_xml(path: Path, size: int) -> CatalogInfo:
    try:
        count = 0
        root_tag = None
        version = None
        for event, element in ET.iterparse(path, events=("start", "end")):
            if root_tag is None:
                root_tag = element.tag
                version = element.get("Format")
            if event == "end" and element.tag == "Movie":
                count += 1
                element.clear()
    except ET.ParseError as error:
        raise CorruptCatalogError(f"invalid XML catalog: {error}") from error
    if root_tag != "AntMovieCatalog":
        raise UnsupportedFormatError(f"unsupported XML root: {root_tag!r}")
    return CatalogInfo(str(path), "amc-xml", version, count, size)


def _inspect_csv(path: Path, size: int) -> CatalogInfo:
    try:
        with path.open(encoding="utf-8-sig", newline="") as stream:
            reader = csv.reader(stream)
            header = next(reader, None)
            if not header or not any(cell.strip() for cell in header):
                raise CorruptCatalogError("CSV catalog has no header")
            count = sum(1 for row in reader if any(cell.strip() for cell in row))
    except UnicodeError as error:
        raise CorruptCatalogError(f"invalid CSV encoding: {error}") from error
    return CatalogInfo(str(path), "csv", None, count, size)
