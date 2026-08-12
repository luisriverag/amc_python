"""Read-only primitives for the source-derived native AMC binary format."""

from __future__ import annotations

import base64
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


@dataclass(frozen=True, slots=True)
class NativeReadLimits:
    """Resource bounds for untrusted native catalogs."""

    max_file_bytes: int = 1024 * 1024 * 1024
    max_movies: int = 1_000_000
    max_picture_bytes: int = 64 * 1024 * 1024
    max_total_picture_bytes: int = 256 * 1024 * 1024

    def __post_init__(self) -> None:
        for name in (
            "max_file_bytes", "max_movies", "max_picture_bytes",
            "max_total_picture_bytes",
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
    path: str | Path, *, encoding: str = "cp1252"
) -> NativeCatalogProperties:
    """Read catalog properties from native AMC 3.1–4.2 without reading movies."""
    with Path(path).open("rb") as stream:
        header = stream.read(NATIVE_HEADER_SIZE)
        version = identify_native_header(header, file_size=Path(path).stat().st_size)
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
            custom_fields = tuple(
                _read_custom_field(stream, version, encoding) for _ in range(count)
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
    raw_value = stream.read(size)
    if len(raw_value) != size:
        raise CorruptCatalogError("truncated native string value", offset=stream.tell())
    try:
        return raw_value.decode(encoding)
    except (LookupError, UnicodeDecodeError) as error:
        raise CorruptCatalogError(
            f"cannot decode native string using {encoding}: {error}", offset=offset + 4
        ) from error


def _read_custom_field(stream: BinaryIO, version: str, encoding: str) -> NativeCustomField:
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
        separator = raw_separator[:1].decode(encoding) if raw_separator[0] else ","
        remove_parentheses = _read_bool(stream)
        patch_values = _read_bool(stream)
    excluded = _read_bool(stream)
    gui_properties = _read_string(stream, encoding)
    list_values: tuple[str, ...] = ()
    list_auto_add = list_sort = list_auto_complete = list_use_catalog_values = False
    if field_type.casefold() == "list":
        count = _read_count(stream, "list-value")
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
    properties = read_native_properties(path, encoding=encoding)
    movies: list[Movie] = []
    movie_extras: list[tuple[NativeExtra, ...]] = []
    total_picture_bytes = 0
    with path.open("rb") as stream:
        stream.seek(properties.data_offset)
        while stream.read(1):
            stream.seek(-1, 1)
            if len(movies) >= limits.max_movies:
                raise CorruptCatalogError(
                    f"native catalog exceeds movie-count limit: {limits.max_movies}",
                    offset=stream.tell() - 1,
                )
            movie, extras, picture_bytes = _read_movie(
                stream, properties, encoding, limits
            )
            total_picture_bytes += picture_bytes
            if total_picture_bytes > limits.max_total_picture_bytes:
                raise CorruptCatalogError(
                    "native catalog exceeds cumulative picture-size limit",
                    offset=stream.tell(),
                )
            movies.append(movie)
            movie_extras.append(extras)
    return NativeCatalog(properties, tuple(movies), tuple(movie_extras))


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
    custom_values = {
        field.tag: _read_string(stream, encoding) for field in properties.custom_fields
    } if version >= "4.0" else {}
    native_extras = (
        _read_movie_extras(stream, encoding, limits) if version >= "4.2" else ()
    )
    extras: dict[str, object] = dict(custom_values)
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
        return float(value.replace(",", "."))
    except ValueError:
        return None


def _parse_native_int(value: str) -> int | None:
    if not value.strip():
        return None
    try:
        return int(value)
    except ValueError:
        return None
