"""Read-only primitives for the source-derived native AMC binary format."""

from __future__ import annotations

import base64
import math
import os
import struct
from dataclasses import dataclass
from pathlib import Path
from typing import BinaryIO

from .errors import CorruptCatalogError, UnsupportedFormatError, UnsupportedVersionError

NATIVE_HEADERS: dict[bytes, str] = {
    b" AMC_1.0 ANSYsoft Movie Catalog http://moviecatalog.ansysoft.com ": "1.0",
    b" AMC_1.1 ANSYsoft Movie Catalog http://moviecatalog.ansysoft.com ": "1.1",
    b" AMC_2.1 ANSYsoft Movie Catalog http://moviecatalog.ansysoft.com ": "2.1",
    b" AMC_3.0 Ant Movie Catalog www.buypin.com www.ant.be.tf/software ": "3.0",
    b" AMC_3.1 Ant Movie Catalog 3.1.x   www.buypin.com  www.ant.be.tf ": "3.1",
    b" AMC_3.3 Ant Movie Catalog 3.3.x   www.buypin.com  www.ant.be.tf ": "3.3",
    b" AMC_3.5 Ant Movie Catalog 3.5.x   www.buypin.com    www.antp.be ": "3.5",
    b" AMC_4.0 Ant Movie Catalog 4.0.x   antp/soulsnake    www.antp.be ": "4.0",
    b" AMC_4.1 Ant Movie Catalog 4.1.x   antp/soulsnake    www.antp.be ": "4.1",
    b" AMC_4.2 Ant Movie Catalog 4.2.x   antp/soulsnake    www.antp.be ": "4.2",
}
NATIVE_HEADER_SIZE = 65
_MAX_PROPERTY_BYTES = 16 * 1024 * 1024


_LEGACY_BASE_FIELDS: tuple[tuple[str, str, int], ...] = (
    ("number", "int", 4), ("original_title", "short", 64),
    ("translated_title", "short", 64), ("director", "short", 32),
    ("producer", "short", 32), ("country", "short", 32),
    ("year", "int", 4), ("category", "short", 32), ("length", "int", 4),
    ("actors", "short", 128), ("url", "short", 128),
    ("description", "chars", 1024), ("comments", "short", 128),
    ("video_format", "short", 32), ("file_size_text", "short", 32),
    ("resolution", "short", 16), ("languages", "short", 32),
    ("subtitles", "short", 32),
)
_LEGACY_PROPERTIES: tuple[tuple[str, str, int], ...] = (
    ("owner", "short", 64), ("icq", "short", 16),
    ("site", "short", 128), ("mail", "short", 128),
)


def _legacy_layout(version: str) -> tuple[dict[str, tuple[int, str, int]], int]:
    fields = list(_LEGACY_BASE_FIELDS)
    if version in {"1.1", "2.1", "3.0"}:
        fields.append(("rating", "int", 4))
    if version in {"2.1", "3.0"}:
        fields.extend((("checked", "bool", 1), ("date", "int", 4)))
    if version == "3.0":
        fields.extend((
            ("picture", "short", 4), ("picture_size", "int", 4),
            ("borrower", "short", 32),
        ))
    return _layout(tuple(fields))


def _decode_native_string(raw: bytes, encoding: str) -> str:
    """Decode ANSI text while preserving undefined Windows-1252 byte values."""
    try:
        return raw.decode(encoding)
    except UnicodeDecodeError:
        if encoding.casefold().replace("-", "") not in {"cp1252", "windows1252"}:
            raise
        undefined = {0x81, 0x8D, 0x8F, 0x90, 0x9D}
        return "".join(
            chr(value) if value in undefined else bytes((value,)).decode("cp1252")
            for value in raw
        )


def _legacy_value(record: bytes, spec: tuple[int, str, int], encoding: str) -> object:
    offset, kind, size = spec
    if kind == "int":
        return struct.unpack_from("<i", record, offset)[0]
    if kind == "bool":
        value = record[offset]
        if value not in (0, 1):
            raise CorruptCatalogError(f"invalid legacy native boolean: {value}", offset=offset)
        return bool(value)
    if kind == "short":
        length = record[offset]
        if length > size:
            raise CorruptCatalogError("invalid legacy short-string length", offset=offset)
        raw = record[offset + 1:offset + 1 + length]
    else:
        raw = record[offset:offset + size].split(b"\0", 1)[0].rstrip(b" ")
    try:
        return _decode_native_string(raw, encoding)
    except UnicodeDecodeError as error:
        raise CorruptCatalogError("cannot decode legacy native string", offset=offset) from error


@dataclass(frozen=True, slots=True)
class NativeReadLimits:
    """Resource bounds for untrusted native catalogs."""

    max_file_bytes: int = 1024 * 1024 * 1024
    max_movies: int = 1_000_000
    max_picture_bytes: int = 64 * 1024 * 1024
    max_total_picture_bytes: int = 256 * 1024 * 1024
    max_total_string_bytes: int = 256 * 1024 * 1024
    max_extras_per_movie: int = 10_000
    max_total_extras: int = 100_000
    max_custom_fields: int = 10_000
    max_list_values_per_field: int = 100_000

    def __post_init__(self) -> None:
        for name in (
            "max_file_bytes",
            "max_movies",
            "max_picture_bytes",
            "max_total_picture_bytes",
            "max_total_string_bytes",
            "max_extras_per_movie",
            "max_total_extras",
            "max_custom_fields",
            "max_list_values_per_field",
        ):
            value = getattr(self, name)
            if isinstance(value, bool) or not isinstance(value, int) or value < 0:
                raise ValueError(f"{name} must be a non-negative integer")


@dataclass(frozen=True, slots=True)
class NativeCustomField:
    """A source-derived AMC 4.x custom-field definition."""

    tag: str
    name: str
    extension: str
    field_type: str
    default_value: str
    media_info: str
    multi_values: bool
    multi_value_separator: str
    remove_parentheses: bool
    patch_values: bool
    excluded_in_scripts: bool
    gui_properties: str
    list_values: tuple[str, ...]
    list_auto_add: bool
    list_sort: bool
    list_auto_complete: bool
    list_use_catalog_values: bool


@dataclass(frozen=True, slots=True)
class NativeCatalogProperties:
    """Catalog-level data that precedes modern native movie records."""

    version: str
    owner: str
    mail: str
    site: str
    description: str
    data_offset: int
    column_settings: str = ""
    gui_properties: str = ""
    custom_fields: tuple[NativeCustomField, ...] = ()


def identify_native_header(header: bytes, *, file_size: int | None = None) -> str:
    """Return the version for an exact source-derived native header."""
    if header in NATIVE_HEADERS:
        return NATIVE_HEADERS[header]
    size = len(header) if file_size is None else file_size
    if header.startswith(b" AMC_") and size < NATIVE_HEADER_SIZE:
        raise CorruptCatalogError(
            f"truncated native AMC header: expected {NATIVE_HEADER_SIZE} bytes, found {size}",
            offset=size,
        )
    if header.startswith(b" AMC_"):
        candidate = header[5:8].decode("ascii", errors="replace")
        known_versions = set(NATIVE_HEADERS.values())
        if candidate not in known_versions:
            raise UnsupportedVersionError(f"unsupported native AMC version: {candidate!r}")
    raise UnsupportedFormatError("file does not have a recognized native AMC header")


def read_native_properties(
    path: str | Path,
    *,
    encoding: str = "cp1252",
    limits: NativeReadLimits | None = None,
) -> NativeCatalogProperties:
    """Read catalog properties from native AMC 3.1–4.2 without reading movies."""
    limits = limits or NativeReadLimits()
    path = Path(path)
    file_size = path.stat().st_size
    if file_size > limits.max_file_bytes:
        raise CorruptCatalogError(
            f"native catalog exceeds file-size limit: {file_size} > {limits.max_file_bytes}"
        )
    with path.open("rb") as stream:
        bounded = _BoundedStringStream(stream, limits.max_total_string_bytes)
        return _read_native_properties_stream(bounded, file_size, encoding, limits)


def _read_native_properties_stream(
    stream: BinaryIO, file_size: int, encoding: str, limits: NativeReadLimits
) -> NativeCatalogProperties:
    """Read modern properties from a stream positioned at its native header."""
    header = stream.read(NATIVE_HEADER_SIZE)
    version = identify_native_header(header, file_size=file_size)
    if version in {"1.0", "1.1", "2.1", "3.0"}:
        raise UnsupportedVersionError(
            f"catalog properties for fixed-record AMC {version} are not implemented"
        )
    owner = _read_string(stream, encoding)
    mail = _read_string(stream, encoding)
    if version in {"3.1", "3.3"}:
        _read_string(stream, encoding)  # Removed ICQ property.
    site = _read_string(stream, encoding)
    description = _read_string(stream, encoding)
    column_settings = ""
    gui_properties = ""
    custom_fields: tuple[NativeCustomField, ...] = ()
    if version >= "4.0":
        column_settings = _read_string(stream, encoding)
        gui_properties = _read_string(stream, encoding)
        count = _read_count(stream, "custom-field")
        if count > limits.max_custom_fields:
            raise CorruptCatalogError(
                "native catalog exceeds custom-field limit", offset=stream.tell() - 4
            )
        custom_fields = tuple(
            _read_custom_field(stream, version, encoding, limits) for _ in range(count)
        )
    return NativeCatalogProperties(
        version,
        owner,
        mail,
        site,
        description,
        stream.tell(),
        column_settings,
        gui_properties,
        custom_fields,
    )


class _BoundedStringStream:
    """Delegate binary reads while accounting for decoded string payload bytes."""

    def __init__(self, stream: BinaryIO, limit: int) -> None:
        self.stream = stream
        self.limit = limit
        self.string_bytes = 0

    def read(self, size: int = -1) -> bytes:
        return self.stream.read(size)

    def seek(self, offset: int, whence: int = 0) -> int:
        return self.stream.seek(offset, whence)

    def tell(self) -> int:
        return self.stream.tell()

    def account_string(self, size: int, offset: int) -> None:
        self.string_bytes += size
        if self.string_bytes > self.limit:
            raise CorruptCatalogError(
                "native catalog exceeds cumulative string-size limit", offset=offset
            )


def _read_string(stream: BinaryIO, encoding: str) -> str:
    offset = stream.tell()
    raw_size = stream.read(4)
    if len(raw_size) != 4:
        raise CorruptCatalogError("truncated native string length", offset=offset)
    (size,) = struct.unpack("<i", raw_size)
    if size < 0 or size > _MAX_PROPERTY_BYTES:
        raise CorruptCatalogError(
            f"invalid native string length: {size}", offset=offset
        )
    account = getattr(stream, "account_string", None)
    if account is not None:
        account(size, offset)
    raw_value = stream.read(size)
    if len(raw_value) != size:
        raise CorruptCatalogError("truncated native string value", offset=stream.tell())
    try:
        return _decode_native_string(raw_value, encoding)
    except (LookupError, UnicodeDecodeError) as error:
        raise CorruptCatalogError(
            f"cannot decode native string using {encoding}: {error}", offset=offset + 4
        ) from error


def _read_custom_field(
    stream: BinaryIO,
    version: str,
    encoding: str,
    limits: NativeReadLimits,
) -> NativeCustomField:
    tag = _read_string(stream, encoding)
    name = _read_string(stream, encoding)
    extension = _read_string(stream, encoding) if version >= "4.1" else ""
    field_type = _read_string(stream, encoding)
    default_value = _read_string(stream, encoding)
    media_info = _read_string(stream, encoding) if version >= "4.1" else ""
    multi_values = _read_bool(stream)
    separator = ","
    remove_parentheses = False
    patch_values = False
    if version >= "4.1":
        raw_separator = _read_exact(stream, 4, "multi-value separator")
        separator = _decode_native_string(raw_separator[:1], encoding) if raw_separator[0] else ","
        remove_parentheses = _read_bool(stream)
        patch_values = _read_bool(stream)
    excluded = _read_bool(stream)
    gui_properties = _read_string(stream, encoding)
    list_values: tuple[str, ...] = ()
    list_auto_add = list_sort = list_auto_complete = list_use_catalog_values = False
    if field_type.casefold() == "list":
        count = _read_count(stream, "list-value")
        if count > limits.max_list_values_per_field:
            raise CorruptCatalogError(
                "native custom field exceeds list-value limit", offset=stream.tell() - 4
            )
        list_values = tuple(_read_string(stream, encoding) for _ in range(count))
        if version >= "4.1":
            list_auto_add = _read_bool(stream)
            list_sort = _read_bool(stream)
            list_auto_complete = _read_bool(stream)
            list_use_catalog_values = _read_bool(stream)
    return NativeCustomField(
        tag, name, extension, field_type, default_value, media_info, multi_values,
        separator, remove_parentheses, patch_values, excluded, gui_properties,
        list_values, list_auto_add, list_sort, list_auto_complete,
        list_use_catalog_values,
    )


def _read_exact(stream: BinaryIO, size: int, label: str) -> bytes:
    offset = stream.tell()
    value = stream.read(size)
    if len(value) != size:
        raise CorruptCatalogError(f"truncated native {label}", offset=offset)
    return value


def _read_bool(stream: BinaryIO) -> bool:
    offset = stream.tell()
    value = _read_exact(stream, 1, "boolean")[0]
    if value not in (0, 1):
        raise CorruptCatalogError(f"invalid native boolean: {value}", offset=offset)
    return bool(value)


def _read_count(stream: BinaryIO, label: str) -> int:
    offset = stream.tell()
    (count,) = struct.unpack("<i", _read_exact(stream, 4, f"{label} count"))
    if count < 0 or count > 100_000:
        raise CorruptCatalogError(f"invalid native {label} count: {count}", offset=offset)
    return count


@dataclass(frozen=True, slots=True)
class NativeExtra:
    """An AMC 4.2 supplementary movie record."""

    checked: bool
    tag: str
    title: str
    category: str
    url: str
    description: str
    comments: str
    created_by: str
    picture_path: str
    picture_size: int
    picture_data: bytes = b""


@dataclass(frozen=True, slots=True)
class NativeCatalog:
    """A read-only native catalog result with parsed movie rows."""

    properties: NativeCatalogProperties
    movies: tuple["Movie", ...]
    movie_extras: tuple[tuple[NativeExtra, ...], ...] = ()


def read_native_catalog(
    path: str | Path,
    *,
    encoding: str = "cp1252",
    limits: NativeReadLimits | None = None,
) -> NativeCatalog:
    """Read AMC 3.1–4.2 movie rows and source-derived AMC 4.2 extras."""
    from .model import Movie

    path = Path(path)
    limits = limits or NativeReadLimits()
    file_size = path.stat().st_size
    if file_size > limits.max_file_bytes:
        raise CorruptCatalogError(
            f"native catalog exceeds file-size limit: {file_size} > {limits.max_file_bytes}"
        )
    with path.open("rb") as probe:
        header = probe.read(NATIVE_HEADER_SIZE)
    version = identify_native_header(header, file_size=file_size)
    if version in {"1.0", "1.1", "2.1", "3.0"}:
        return _read_legacy_catalog(path, version, encoding, limits)
    movies: list[Movie] = []
    movie_extras: list[tuple[NativeExtra, ...]] = []
    total_picture_bytes = 0
    total_extras = 0
    with path.open("rb") as stream:
        bounded = _BoundedStringStream(stream, limits.max_total_string_bytes)
        properties = _read_native_properties_stream(bounded, file_size, encoding, limits)
        while bounded.read(1):
            bounded.seek(-1, 1)
            if len(movies) >= limits.max_movies:
                raise CorruptCatalogError(
                    f"native catalog exceeds movie-count limit: {limits.max_movies}",
                    offset=bounded.tell() - 1,
                )
            movie, extras, picture_bytes = _read_movie(
                bounded, properties, encoding, limits
            )
            total_picture_bytes += picture_bytes
            if total_picture_bytes > limits.max_total_picture_bytes:
                raise CorruptCatalogError(
                    "native catalog exceeds cumulative picture-size limit",
                    offset=bounded.tell(),
                )
            total_extras += len(extras)
            if total_extras > limits.max_total_extras:
                raise CorruptCatalogError(
                    "native catalog exceeds cumulative supplementary-record limit",
                    offset=bounded.tell(),
                )
            movies.append(movie)
            movie_extras.append(extras)
    return NativeCatalog(properties, tuple(movies), tuple(movie_extras))


def _read_legacy_catalog(
    path: Path, version: str, encoding: str, limits: NativeReadLimits
) -> NativeCatalog:
    """Read the fixed-record AMC 1.0–3.0 layouts declared in movieclass_old.pas."""
    from .model import Movie

    layout, record_size = _legacy_layout(version)
    movies: list[Movie] = []
    total_picture_bytes = 0
    with path.open("rb") as stream:
        stream.seek(NATIVE_HEADER_SIZE)
        owner = mail = site = ""
        if version in {"2.1", "3.0"}:
            _, property_size = _layout(_LEGACY_PROPERTIES)
            raw_properties = _read_exact(stream, property_size, "legacy properties")
            property_layout, _ = _layout(_LEGACY_PROPERTIES)
            owner = str(_legacy_value(raw_properties, property_layout["owner"], encoding))
            site = str(_legacy_value(raw_properties, property_layout["site"], encoding))
            mail = str(_legacy_value(raw_properties, property_layout["mail"], encoding))
        properties = NativeCatalogProperties(
            version, owner, mail, site, "", stream.tell()
        )
        while stream.read(1):
            stream.seek(-1, 1)
            if len(movies) >= limits.max_movies:
                raise CorruptCatalogError("native catalog exceeds movie-count limit")
            offset = stream.tell()
            record = stream.read(record_size)
            if len(record) != record_size:
                raise CorruptCatalogError("truncated legacy native movie record", offset=offset)
            get = lambda name: _legacy_value(record, layout[name], encoding)
            raw_rating = int(get("rating")) if "rating" in layout else 0
            rating_map = {0: None, 1: 2.0, 2: 4.0, 3: 6.0, 4: 8.0, 5: 9.0}
            rating = rating_map.get(raw_rating)
            extras: dict[str, object] = {}
            raw_date = int(get("date")) if "date" in layout else 0
            if raw_date:
                extras["native_date"] = raw_date
            picture_size = int(get("picture_size")) if "picture_size" in layout else 0
            if picture_size < 0 or picture_size > limits.max_picture_bytes:
                raise CorruptCatalogError("invalid legacy native picture size", offset=offset)
            picture_data = _read_exact(stream, picture_size, "legacy picture data")
            total_picture_bytes += picture_size
            if total_picture_bytes > limits.max_total_picture_bytes:
                raise CorruptCatalogError(
                    "native catalog exceeds cumulative picture-size limit",
                    offset=stream.tell(),
                )
            if picture_data:
                extras["native_picture_base64"] = base64.b64encode(picture_data).decode("ascii")
            file_size_text = str(get("file_size_text"))
            file_size_value = _parse_native_int(file_size_text)
            if file_size_text and file_size_value is None:
                extras["native_file_size_text"] = file_size_text
            raw_number = int(get("number"))
            if raw_number < 0:
                extras["native_movie_number"] = raw_number
            movies.append(Movie(
                number=max(raw_number, 0),
                original_title=str(get("original_title")),
                translated_title=str(get("translated_title")),
                director=str(get("director")), producer=str(get("producer")),
                country=str(get("country")), year=int(get("year")) or None,
                category=str(get("category")), length=int(get("length")) or None,
                actors=str(get("actors")), url=str(get("url")),
                description=str(get("description")), comments=str(get("comments")),
                video_format=str(get("video_format")), file_size=file_size_value,
                resolution=str(get("resolution")), languages=str(get("languages")),
                subtitles=str(get("subtitles")), rating=rating,
                checked=bool(get("checked")) if "checked" in layout else True,
                picture=str(get("picture")) if "picture" in layout else "",
                borrower=str(get("borrower")) if "borrower" in layout else "",
                extras=extras,
            ))
    return NativeCatalog(properties, tuple(movies), tuple(() for _ in movies))


def _layout(
    fields: tuple[tuple[str, str, int], ...]
) -> tuple[dict[str, tuple[int, str, int]], int]:
    result: dict[str, tuple[int, str, int]] = {}
    offset = 0
    for name, kind, size in fields:
        alignment = 4 if kind == "int" else 1
        offset = (offset + alignment - 1) // alignment * alignment
        result[name] = (offset, kind, size)
        offset += size + 1 if kind == "short" else size
    return result, (offset + 3) // 4 * 4


def _read_movie(
    stream: BinaryIO,
    properties: NativeCatalogProperties,
    encoding: str,
    limits: NativeReadLimits,
) -> tuple["Movie", tuple[NativeExtra, ...], int]:
    from .model import Movie

    version = properties.version
    number = _read_int(stream, "movie number")
    date = _read_int(stream, "movie date")
    date_watched = _read_int(stream, "watched date") if version >= "4.2" else 0
    user_rating_raw = _read_int(stream, "user rating") if version >= "4.2" else -1
    rating_raw = _read_int(stream, "movie rating")
    if version < "3.5" and rating_raw != -1:
        rating_raw *= 10
    year = _read_int(stream, "movie year")
    length = _read_int(stream, "movie length")
    video_bitrate = _read_int(stream, "video bitrate")
    audio_bitrate = _read_int(stream, "audio bitrate")
    media_count = _read_int(stream, "media count")
    color_tag = _read_int(stream, "color tag") if version >= "4.1" else None
    checked = _read_bool(stream)
    media_label = _read_string(stream, encoding)
    if version >= "3.3":
        media_type = _read_string(stream, encoding)
        source = _read_string(stream, encoding)
    else:
        media_type = source = ""
    borrower = _read_string(stream, encoding)
    original_title = _read_string(stream, encoding)
    translated_title = _read_string(stream, encoding)
    director = _read_string(stream, encoding)
    producer = _read_string(stream, encoding)
    writer = _read_string(stream, encoding) if version >= "4.2" else ""
    composer = _read_string(stream, encoding) if version >= "4.2" else ""
    country = _read_string(stream, encoding)
    category = _read_string(stream, encoding)
    certification = _read_string(stream, encoding) if version >= "4.2" else ""
    actors = _read_string(stream, encoding)
    url = _read_string(stream, encoding)
    description = _read_string(stream, encoding)
    comments = _read_string(stream, encoding)
    file_path = _read_string(stream, encoding) if version >= "4.2" else ""
    video_format = _read_string(stream, encoding)
    audio_format = _read_string(stream, encoding)
    resolution = _read_string(stream, encoding)
    framerate_text = _read_string(stream, encoding)
    languages = _read_string(stream, encoding)
    subtitles = _read_string(stream, encoding)
    file_size_text = _read_string(stream, encoding)
    picture_path = _read_string(stream, encoding)
    picture_size = _read_int(stream, "picture size")
    if picture_size < 0 or picture_size > limits.max_picture_bytes:
        raise CorruptCatalogError(
            f"invalid native picture size: {picture_size}", offset=stream.tell() - 4
        )
    picture_data = _read_exact(stream, picture_size, "picture data")
    custom_value_items = (
        [(field.tag, _read_string(stream, encoding)) for field in properties.custom_fields]
        if version >= "4.0"
        else []
    )
    custom_values = dict(custom_value_items)
    native_extras = (
        _read_movie_extras(stream, encoding, limits) if version >= "4.2" else ()
    )
    extras: dict[str, object] = dict(custom_values)
    if custom_value_items:
        extras["native_custom_values"] = [
            {"tag": tag, "value": value} for tag, value in custom_value_items
        ]
    if date:
        extras["native_date"] = date
    if date_watched:
        extras["native_date_watched"] = date_watched
    if user_rating_raw >= 0:
        extras["native_user_rating"] = user_rating_raw / 10
    if writer:
        extras["native_writer"] = writer
    if composer:
        extras["native_composer"] = composer
    if certification:
        extras["native_certification"] = certification
    if file_path:
        extras["native_file_path"] = file_path
    if picture_data:
        extras["native_picture_base64"] = base64.b64encode(picture_data).decode("ascii")
    if color_tag is not None:
        extras["native_color_tag"] = color_tag
    framerate = _parse_native_float(framerate_text)
    file_size = _parse_native_int(file_size_text)
    if framerate is None and framerate_text.strip():
        extras["native_framerate_text"] = framerate_text
    if file_size is None and file_size_text.strip():
        extras["native_file_size_text"] = file_size_text
    if number < 0:
        extras["native_movie_number"] = number
    if native_extras:
        extras["native_supplementary_records"] = [
            {
                "checked": item.checked,
                "tag": item.tag,
                "title": item.title,
                "category": item.category,
                "url": item.url,
                "description": item.description,
                "comments": item.comments,
                "created_by": item.created_by,
                "picture_path": item.picture_path,
                "picture_base64": base64.b64encode(item.picture_data).decode("ascii"),
            }
            for item in native_extras
        ]
    movie = Movie(
        number=max(number, 0),
        original_title=original_title,
        translated_title=translated_title,
        director=director,
        producer=producer,
        country=country,
        category=category,
        year=year or None,
        length=length or None,
        rating=None if rating_raw < 0 else rating_raw / 10,
        borrower=borrower,
        media_label=media_label,
        media_type=media_type,
        media_count=media_count or None,
        source=source,
        languages=languages,
        subtitles=subtitles,
        video_format=video_format,
        video_bitrate=video_bitrate or None,
        audio_format=audio_format,
        audio_bitrate=audio_bitrate or None,
        resolution=resolution,
        framerate=framerate,
        file_size=file_size,
        url=url,
        description=description,
        comments=comments,
        actors=actors,
        checked=checked,
        picture=picture_path,
        extras=extras,
    )
    extra_picture_bytes = sum(item.picture_size for item in native_extras)
    return movie, native_extras, picture_size + extra_picture_bytes


def _read_movie_extras(
    stream: BinaryIO, encoding: str, limits: NativeReadLimits
) -> tuple[NativeExtra, ...]:
    count = _read_count(stream, "movie-extra")
    if count > limits.max_extras_per_movie:
        raise CorruptCatalogError(
            "native movie exceeds supplementary-record limit", offset=stream.tell() - 4
        )
    result: list[NativeExtra] = []
    for _ in range(count):
        checked = _read_bool(stream)
        values = [_read_string(stream, encoding) for _ in range(7)]
        picture_path = _read_string(stream, encoding)
        picture_size = _read_int(stream, "extra picture size")
        if picture_size < 0 or picture_size > limits.max_picture_bytes:
            raise CorruptCatalogError(
                f"invalid native extra picture size: {picture_size}", offset=stream.tell() - 4
            )
        picture_data = _read_exact(stream, picture_size, "extra picture data")
        result.append(NativeExtra(checked, *values, picture_path, picture_size, picture_data))
    return tuple(result)


def _read_int(stream: BinaryIO, label: str) -> int:
    return struct.unpack("<i", _read_exact(stream, 4, label))[0]


def _parse_native_float(value: str) -> float | None:
    if not value.strip():
        return None
    try:
        parsed = float(value.replace(",", "."))
    except ValueError:
        return None
    return parsed if math.isfinite(parsed) else None


def _parse_native_int(value: str) -> int | None:
    if not value.strip():
        return None
    try:
        return int(value)
    except ValueError:
        return None


def write_native_catalog(
    catalog: "Catalog",
    path: str | Path,
    *,
    encoding: str = "cp1252",
) -> None:
    """Atomically write a source-derived AMC 4.2 catalog.

    Native-only values retained by :func:`read_native_catalog` are consumed from
    the ``native`` metadata namespace and each movie's ``extras`` mapping.
    """
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    try:
        with temporary.open("wb") as stream:
            stream.write(next(header for header, version in NATIVE_HEADERS.items() if version == "4.2"))
            native = catalog.metadata.get("native", {})
            if not isinstance(native, dict):
                raise TypeError("catalog native metadata must be an object")
            for key in ("owner", "mail", "site", "description"):
                _write_string(stream, native.get(key, ""), encoding, key)
            custom_fields = native.get("custom_fields", [])
            if not isinstance(custom_fields, list):
                raise TypeError("native custom_fields metadata must be a list")
            _write_string(stream, native.get("column_settings", ""), encoding, "column settings")
            _write_string(stream, native.get("gui_properties", ""), encoding, "GUI properties")
            _write_int(stream, len(custom_fields))
            tags: list[str] = []
            for field in custom_fields:
                if not isinstance(field, dict):
                    raise TypeError("each native custom field must be an object")
                tag = _write_custom_field(stream, field, encoding)
                tags.append(tag)
            for movie in catalog:
                _write_movie_42(stream, movie, tags, encoding)
            stream.flush()
            os.fsync(stream.fileno())
        temporary.replace(path)
    finally:
        temporary.unlink(missing_ok=True)


def _write_string(stream: BinaryIO, value: object, encoding: str, label: str) -> None:
    if not isinstance(value, str):
        raise TypeError(f"native {label} must be a string")
    try:
        raw = value.encode(encoding)
    except (LookupError, UnicodeEncodeError) as error:
        raise ValueError(f"cannot encode native {label} using {encoding}: {error}") from error
    if len(raw) > _MAX_PROPERTY_BYTES:
        raise ValueError(f"native {label} exceeds string-size limit")
    _write_int(stream, len(raw))
    stream.write(raw)


def _write_int(stream: BinaryIO, value: object) -> None:
    if isinstance(value, bool) or not isinstance(value, int):
        raise TypeError("native integer value must be an integer")
    try:
        stream.write(struct.pack("<i", value))
    except struct.error as error:
        raise ValueError(f"native integer is outside the signed 32-bit range: {value}") from error


def _write_bool(stream: BinaryIO, value: object, label: str) -> None:
    if not isinstance(value, bool):
        raise TypeError(f"native {label} must be a boolean")
    stream.write(bytes((value,)))


def _write_custom_field(stream: BinaryIO, field: dict[str, object], encoding: str) -> str:
    tag = field.get("tag", "")
    for key in ("tag", "name", "extension", "field_type", "default_value", "media_info"):
        _write_string(stream, field.get(key, ""), encoding, f"custom field {key}")
    _write_bool(stream, field.get("multi_values", False), "custom multi_values")
    separator = field.get("multi_value_separator", ",")
    if not isinstance(separator, str) or len(separator.encode(encoding)) > 1:
        raise ValueError("native custom-field separator must encode to at most one byte")
    stream.write(separator.encode(encoding).ljust(4, b"\0"))
    for key in ("remove_parentheses", "patch_values", "excluded_in_scripts"):
        _write_bool(stream, field.get(key, False), f"custom {key}")
    _write_string(stream, field.get("gui_properties", ""), encoding, "custom GUI properties")
    if str(field.get("field_type", "")).casefold() == "list":
        values = field.get("list_values", [])
        if not isinstance(values, (list, tuple)):
            raise TypeError("native custom-field list_values must be a list")
        _write_int(stream, len(values))
        for value in values:
            _write_string(stream, value, encoding, "custom list value")
        for key in ("list_auto_add", "list_sort", "list_auto_complete", "list_use_catalog_values"):
            _write_bool(stream, field.get(key, False), f"custom {key}")
    return str(tag)


def _retained_int(extras: dict[str, object], key: str, default: int) -> int:
    value = extras.get(key, default)
    if isinstance(value, bool) or not isinstance(value, int):
        raise TypeError(f"movie extra {key} must be an integer")
    return value


def _picture_bytes(extras: dict[str, object], key: str) -> bytes:
    value = extras.get(key, "")
    if not isinstance(value, str):
        raise TypeError(f"movie extra {key} must be a base64 string")
    try:
        return base64.b64decode(value, validate=True) if value else b""
    except ValueError as error:
        raise ValueError(f"movie extra {key} is not valid base64") from error


def _write_movie_42(stream: BinaryIO, movie: "Movie", tags: list[str], encoding: str) -> None:
    extras = movie.extras
    rating = -1 if movie.rating is None else round(movie.rating * 10)
    integers = (
        _retained_int(extras, "native_movie_number", movie.number),
        _retained_int(extras, "native_date", 0),
        _retained_int(extras, "native_date_watched", 0),
        round(float(extras.get("native_user_rating", -0.1)) * 10),
        rating, movie.year or 0, movie.length or 0, movie.video_bitrate or 0,
        movie.audio_bitrate or 0, movie.media_count or 0,
        _retained_int(extras, "native_color_tag", 0),
    )
    for value in integers:
        _write_int(stream, value)
    _write_bool(stream, movie.checked, "movie checked")
    strings = (
        movie.media_label, movie.media_type, movie.source, movie.borrower,
        movie.original_title, movie.translated_title, movie.director, movie.producer,
        extras.get("native_writer", ""), extras.get("native_composer", ""),
        movie.country, movie.category, extras.get("native_certification", ""),
        movie.actors, movie.url, movie.description, movie.comments,
        extras.get("native_file_path", ""), movie.video_format, movie.audio_format,
        movie.resolution,
        extras.get("native_framerate_text", "") if movie.framerate is None else str(movie.framerate),
        movie.languages, movie.subtitles,
        extras.get("native_file_size_text", "") if movie.file_size is None else str(movie.file_size),
    )
    for index, value in enumerate(strings):
        _write_string(stream, value, encoding, f"movie string {index}")
    _write_string(stream, movie.picture, encoding, "movie picture path")
    picture = _picture_bytes(extras, "native_picture_base64")
    _write_int(stream, len(picture))
    stream.write(picture)
    ordered = extras.get("native_custom_values")
    ordered_values: list[object] | None = None
    if isinstance(ordered, list) and len(ordered) == len(tags) and all(
        isinstance(item, dict) and item.get("tag") == tag
        for item, tag in zip(ordered, tags)
    ):
        ordered_values = [item.get("value", "") for item in ordered]
    for index, tag in enumerate(tags):
        value = ordered_values[index] if ordered_values is not None else extras.get(tag, "")
        _write_string(stream, value, encoding, f"custom value {tag}")
    records = extras.get("native_supplementary_records", [])
    if not isinstance(records, list):
        raise TypeError("native supplementary records must be a list")
    _write_int(stream, len(records))
    for record in records:
        if not isinstance(record, dict):
            raise TypeError("each native supplementary record must be an object")
        _write_bool(stream, record.get("checked", False), "supplementary checked")
        for key in ("tag", "title", "category", "url", "description", "comments", "created_by", "picture_path"):
            _write_string(stream, record.get(key, ""), encoding, f"supplementary {key}")
        picture = _picture_bytes(record, "picture_base64")
        _write_int(stream, len(picture))
        stream.write(picture)
