import struct
from pathlib import Path

import pytest

from amc.errors import CorruptCatalogError, UnsupportedFormatError, UnsupportedVersionError
from amc.native import NATIVE_HEADERS, identify_native_header, read_native_properties


def _string(value: str) -> bytes:
    encoded = value.encode("cp1252")
    return struct.pack("<i", len(encoded)) + encoded


def _catalog(version: str, *values: str) -> bytes:
    header = next(header for header, item_version in NATIVE_HEADERS.items() if item_version == version)
    return header + b"".join(_string(value) for value in values)


@pytest.mark.parametrize("version", ["3.1", "3.3"])
def test_read_legacy_modern_properties_skips_removed_icq(tmp_path: Path, version: str):
    target = tmp_path / "catalog.amc"
    target.write_bytes(_catalog(version, "Antoine", "a@example.test", "12345", "site", "Résumé"))

    properties = read_native_properties(target)

    assert (properties.version, properties.owner, properties.mail) == (version, "Antoine", "a@example.test")
    assert (properties.site, properties.description) == ("site", "Résumé")
    assert properties.data_offset == target.stat().st_size


@pytest.mark.parametrize("version", ["3.5", "4.0", "4.1", "4.2"])
def test_read_modern_native_catalog_properties(tmp_path: Path, version: str):
    target = tmp_path / "catalog.amc"
    values = ("Owner", "mail", "site", "description")
    payload = _catalog(version, *values)
    if version >= "4.0":
        payload += _string("columns") + _string("gui") + struct.pack("<i", 0)
    target.write_bytes(payload)

    properties = read_native_properties(target)

    assert (properties.owner, properties.mail, properties.site, properties.description) == (
        "Owner", "mail", "site", "description"
    )
    assert properties.data_offset == target.stat().st_size


def test_native_properties_reject_fixed_record_versions(tmp_path: Path):
    target = tmp_path / "legacy.amc"
    target.write_bytes(next(header for header, version in NATIVE_HEADERS.items() if version == "3.0"))
    with pytest.raises(UnsupportedVersionError, match="fixed-record AMC 3.0"):
        read_native_properties(target)


@pytest.mark.parametrize(
    "tail, message, offset",
    [
        (b"", "truncated native string length", 65),
        (struct.pack("<i", -1), "invalid native string length", 65),
        (struct.pack("<i", 5) + b"ab", "truncated native string value", 71),
    ],
)
def test_native_properties_reject_malformed_strings(
    tmp_path: Path, tail: bytes, message: str, offset: int
):
    target = tmp_path / "broken.amc"
    header = next(header for header, version in NATIVE_HEADERS.items() if version == "4.2")
    target.write_bytes(header + tail)
    with pytest.raises(CorruptCatalogError, match=message) as caught:
        read_native_properties(target)
    assert caught.value.offset == offset


def test_known_version_with_damaged_header_is_not_reported_as_future():
    damaged = b" AMC_4.2 " + b"x" * 56
    with pytest.raises(UnsupportedFormatError):
        identify_native_header(damaged)


def _boolean(value: bool) -> bytes:
    return bytes([value])


def test_read_amc_42_custom_field_definition(tmp_path: Path):
    field = b"".join((
        _string("MyTag"), _string("My field"), _string("txt"), _string("List"),
        _string("default"), _string("General;0"), _boolean(True), b";\x00\x00\x00",
        _boolean(True), _boolean(False), _boolean(True), _string("width=100"),
        struct.pack("<i", 2), _string("One"), _string("Two"),
        _boolean(True), _boolean(False), _boolean(True), _boolean(False),
    ))
    target = tmp_path / "fields.amc"
    target.write_bytes(
        _catalog("4.2", "Owner", "mail", "site", "description", "columns", "gui")
        + struct.pack("<i", 1) + _string("MyTag") + field[len(_string("MyTag")):]
    )

    properties = read_native_properties(target)

    assert (properties.column_settings, properties.gui_properties) == ("columns", "gui")
    assert len(properties.custom_fields) == 1
    custom = properties.custom_fields[0]
    assert (custom.tag, custom.name, custom.extension, custom.field_type) == (
        "MyTag", "My field", "txt", "List"
    )
    assert custom.list_values == ("One", "Two")
    assert (custom.multi_values, custom.multi_value_separator) == (True, ";")
    assert (custom.remove_parentheses, custom.patch_values, custom.excluded_in_scripts) == (
        True, False, True
    )
    assert (custom.list_auto_add, custom.list_sort, custom.list_auto_complete, custom.list_use_catalog_values) == (
        True, False, True, False
    )


def test_custom_field_parser_rejects_invalid_count_and_boolean(tmp_path: Path):
    prefix = _catalog("4.2", "", "", "", "", "", "")
    invalid_count = tmp_path / "count.amc"
    invalid_count.write_bytes(prefix + struct.pack("<i", -1))
    with pytest.raises(CorruptCatalogError, match="invalid native custom-field count"):
        read_native_properties(invalid_count)

    invalid_bool = tmp_path / "bool.amc"
    field = b"".join((_string("tag"), _string("name"), _string(""), _string("String"), _string(""), _string(""), b"\x02"))
    invalid_bool.write_bytes(prefix + struct.pack("<i", 1) + field)
    with pytest.raises(CorruptCatalogError, match="invalid native boolean"):
        read_native_properties(invalid_bool)


def _integer(value: int) -> bytes:
    return struct.pack("<i", value)


def _movie_41(custom_value: str = "custom") -> bytes:
    integers = [7, 0, 83, 1985, 142, 1200, 192, 2, 3]
    strings = [
        "DISC-1", "Blu-ray", "Owned", "", "Brazil", "Brazil", "Terry Gilliam",
        "Arnon Milchan", "UK", "Science Fiction", "Jonathan Pryce", "https://example.test",
        "Future imperfect.", "comment", "H264", "AAC", "1920x1080", "23.976",
        "English", "French", "123456",
    ]
    return (
        b"".join(_integer(value) for value in integers)
        + _boolean(True)
        + b"".join(_string(value) for value in strings)
        + _string("cover.jpg") + _integer(3) + b"img" + _string(custom_value)
    )


def test_read_amc_41_movie_record(tmp_path: Path):
    field = b"".join((
        _string("Inventory"), _string("Inventory"), _string(""), _string("String"),
        _string(""), _string(""), _boolean(False), b",\x00\x00\x00",
        _boolean(False), _boolean(False), _boolean(False), _string(""),
    ))
    target = tmp_path / "movie.amc"
    target.write_bytes(
        _catalog("4.1", "Owner", "mail", "site", "description", "", "")
        + _integer(1) + field + _movie_41("A-42")
    )

    from amc.native import read_native_catalog
    result = read_native_catalog(target)

    assert result.properties.owner == "Owner"
    assert len(result.movies) == 1
    movie = result.movies[0]
    assert (movie.number, movie.original_title, movie.year, movie.rating) == (7, "Brazil", 1985, 8.3)
    assert (movie.video_bitrate, movie.framerate, movie.file_size) == (1200, 23.976, 123456)
    assert movie.checked and movie.picture == "cover.jpg"
    assert movie.extras == {
        "Inventory": "A-42", "native_color_tag": 3, "native_picture_base64": "aW1n"
    }


def test_native_movie_reader_rejects_truncated_picture_and_amc_42(tmp_path: Path):
    target = tmp_path / "truncated.amc"
    payload = _catalog("4.1", "", "", "", "", "", "") + _integer(0)
    movie_payload = _movie_41()
    picture_end = movie_payload.index(b"img") + 3
    target.write_bytes(payload + movie_payload[:picture_end - 2])
    from amc.native import read_native_catalog
    with pytest.raises(CorruptCatalogError, match="truncated native picture data"):
        read_native_catalog(target)

    version_42 = tmp_path / "42.amc"
    version_42.write_bytes(_catalog("4.2", "", "", "", "", "", "") + _integer(0))
    assert read_native_catalog(version_42).movies == ()


def _movie_42() -> bytes:
    integers = [8, 10, 20, 75, 91, 2020, 100, 800, 128, 1, 2]
    strings = [
        "MEDIA", "File", "Digital", "", "Title", "Translated", "Director", "Producer",
        "Writer", "Composer", "Country", "Category", "PG", "Actors", "url", "description",
        "comments", "/movie.mkv", "H265", "AAC", "3840x2160", "24", "English", "", "1000",
    ]
    extra = (
        _boolean(True) + _string("trailer") + _string("Trailer") + _string("Video")
        + _string("https://example.test/trailer") + _string("desc") + _string("notes")
        + _string("script") + _string("extra.jpg") + _integer(2) + b"im"
    )
    return (
        b"".join(_integer(value) for value in integers) + _boolean(True)
        + b"".join(_string(value) for value in strings)
        + _string("cover.jpg") + _integer(0) + _integer(1) + extra
    )


def test_read_amc_42_movie_and_extra(tmp_path: Path):
    target = tmp_path / "movie42.amc"
    target.write_bytes(
        _catalog("4.2", "Owner", "mail", "site", "description", "", "")
        + _integer(0) + _movie_42()
    )
    from amc.native import read_native_catalog

    result = read_native_catalog(target)

    movie = result.movies[0]
    assert (movie.number, movie.original_title, movie.rating) == (8, "Title", 9.1)
    assert movie.extras["native_user_rating"] == 7.5
    assert movie.extras["native_writer"] == "Writer"
    assert movie.extras["native_file_path"] == "/movie.mkv"
    assert len(result.movie_extras[0]) == 1
    extra = result.movie_extras[0][0]
    assert (extra.tag, extra.title, extra.category, extra.picture_path, extra.picture_size) == (
        "trailer", "Trailer", "Video", "extra.jpg", 2
    )
    assert extra.checked and extra.created_by == "script"
    assert extra.picture_data == b"im"
    assert movie.extras["native_supplementary_records"][0]["picture_base64"] == "aW0="


def test_amc_42_rejects_truncated_extra_picture(tmp_path: Path):
    target = tmp_path / "broken42.amc"
    payload = (
        _catalog("4.2", "", "", "", "", "", "") + _integer(0) + _movie_42()
    )
    target.write_bytes(payload[:-1])
    from amc.native import read_native_catalog
    with pytest.raises(CorruptCatalogError, match="truncated native extra picture data"):
        read_native_catalog(target)


def test_generic_storage_loads_native_catalog(tmp_path: Path):
    target = tmp_path / "movie.amc"
    field = b"".join((
        _string("Inventory"), _string("Inventory"), _string(""), _string("String"),
        _string(""), _string(""), _boolean(False), b",\x00\x00\x00",
        _boolean(False), _boolean(False), _boolean(False), _string(""),
    ))
    target.write_bytes(
        _catalog("4.1", "", "", "", "", "", "")
        + _integer(1) + field + _movie_41()
    )
    from amc.storage import load

    catalog = load(target)

    assert len(catalog) == 1
    assert next(iter(catalog)).original_title == "Brazil"
    assert catalog.metadata["native"]["version"] == "4.1"


def test_cli_imports_native_catalog_to_json(tmp_path: Path):
    field = b"".join((
        _string("Inventory"), _string("Inventory"), _string(""), _string("String"),
        _string(""), _string(""), _boolean(False), b",\x00\x00\x00",
        _boolean(False), _boolean(False), _boolean(False), _string(""),
    ))
    source = tmp_path / "movie.amc"
    source.write_bytes(
        _catalog("4.1", "", "", "", "", "", "")
        + _integer(1) + field + _movie_41("A-42")
    )
    destination = tmp_path / "catalog.json"
    from amc.cli import main
    from amc.storage import load

    assert main(["-c", str(destination), "import", str(source)]) == 0

    movie = next(iter(load(destination)))
    assert movie.original_title == "Brazil"
    assert movie.extras["Inventory"] == "A-42"
    assert load(destination).metadata["native"]["version"] == "4.1"


def test_generic_storage_detects_native_header_without_amc_extension(tmp_path: Path):
    target = tmp_path / "catalog.data"
    target.write_bytes(
        _catalog("4.1", "", "", "", "", "", "")
        + _integer(0) + _movie_41()[:-len(_string("custom"))]
    )
    from amc.storage import load

    catalog = load(target)

    assert next(iter(catalog)).original_title == "Brazil"
    assert catalog.metadata["native"]["version"] == "4.1"


def test_native_read_limits_reject_file_movie_and_picture_budgets(tmp_path: Path):
    from amc.native import NativeReadLimits, read_native_catalog

    target = tmp_path / "limited.amc"
    target.write_bytes(
        _catalog("4.1", "", "", "", "", "", "")
        + _integer(0) + _movie_41()[:-len(_string("custom"))]
    )

    with pytest.raises(CorruptCatalogError, match="file-size limit"):
        read_native_catalog(
            target, limits=NativeReadLimits(max_file_bytes=target.stat().st_size - 1)
        )
    with pytest.raises(CorruptCatalogError, match="movie-count limit"):
        read_native_catalog(target, limits=NativeReadLimits(max_movies=0))
    with pytest.raises(CorruptCatalogError, match="invalid native picture size"):
        read_native_catalog(target, limits=NativeReadLimits(max_picture_bytes=2))
    with pytest.raises(CorruptCatalogError, match="cumulative picture-size limit"):
        read_native_catalog(
            target, limits=NativeReadLimits(max_total_picture_bytes=2)
        )


def test_native_read_limits_validate_configuration():
    from amc.native import NativeReadLimits

    for values in ({"max_movies": -1}, {"max_picture_bytes": True}):
        with pytest.raises(ValueError, match="non-negative integer"):
            NativeReadLimits(**values)
