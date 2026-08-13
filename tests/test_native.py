import struct
from pathlib import Path

import pytest

from amc.errors import CorruptCatalogError, UnsupportedFormatError, UnsupportedVersionError
from amc.native import (
    NATIVE_HEADERS,
    NativeReadLimits,
    identify_native_header,
    read_native_properties,
)


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


def test_custom_field_parser_applies_definition_and_list_limits(tmp_path: Path):
    from amc.native import NativeReadLimits

    prefix = _catalog("4.2", "", "", "", "", "", "")
    definitions = tmp_path / "definitions.amc"
    definitions.write_bytes(prefix + struct.pack("<i", 1))
    with pytest.raises(CorruptCatalogError, match="custom-field limit"):
        read_native_properties(
            definitions, limits=NativeReadLimits(max_custom_fields=0)
        )

    list_field = b"".join((
        _string("tag"), _string("name"), _string(""), _string("List"),
        _string(""), _string(""), _boolean(False), b",\x00\x00\x00",
        _boolean(False), _boolean(False), _boolean(False), _string(""),
        struct.pack("<i", 1),
    ))
    values = tmp_path / "values.amc"
    values.write_bytes(prefix + struct.pack("<i", 1) + list_field)
    with pytest.raises(CorruptCatalogError, match="list-value limit"):
        read_native_properties(
            values, limits=NativeReadLimits(max_list_values_per_field=0)
        )


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
        "Inventory": "A-42",
        "native_custom_values": [{"tag": "Inventory", "value": "A-42"}],
        "native_color_tag": 3,
        "native_picture_base64": "aW1n",
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


def test_native_42_to_json_roundtrip_preserves_native_only_data(tmp_path: Path):
    """Lock retention of native-only values before genuine fixture verification."""
    field = b"".join((
        _string("Inventory"), _string("Inventory"), _string("txt"),
        _string("String"), _string("default"), _string("General;0"),
        _boolean(False), b",\x00\x00\x00", _boolean(False), _boolean(False),
        _boolean(True), _string("width=100"),
    ))
    movie = _movie_42()
    extra_offset = movie.rfind(_boolean(True) + _string("trailer"))
    assert extra_offset > 4
    movie_with_custom_value = (
        movie[: extra_offset - 4] + _string("A-42") + movie[extra_offset - 4 :]
    )
    source = tmp_path / "native.amc"
    source.write_bytes(
        _catalog("4.2", "Owner", "mail", "site", "description", "columns", "gui")
        + _integer(1)
        + field
        + movie_with_custom_value
    )

    from amc.storage import load, save

    imported = load(source)
    first_json = tmp_path / "first.json"
    second_json = tmp_path / "second.json"
    save(imported, first_json)
    restored = load(first_json)
    save(restored, second_json)

    imported_movie = next(iter(imported))
    restored_movie = next(iter(restored))
    assert restored.metadata == imported.metadata
    assert restored_movie.to_dict() == imported_movie.to_dict()
    assert restored_movie.extras["Inventory"] == "A-42"
    assert restored_movie.extras["native_supplementary_records"][0][
        "picture_base64"
    ] == "aW0="
    assert restored.metadata["native"]["custom_fields"][0]["field_type"] == "String"
    assert second_json.read_text(encoding="utf-8") == first_json.read_text(encoding="utf-8")


def test_native_reader_retains_unrepresentable_numeric_text(tmp_path: Path):
    """Do not silently discard native scalar text the common model cannot parse."""
    movie = _movie_42()
    movie = movie.replace(_string("24"), _string("not-a-rate"), 1)
    movie = movie.replace(_string("1000"), _string("1,000 KB"), 1)
    target = tmp_path / "numeric-text.amc"
    target.write_bytes(
        _catalog("4.2", "", "", "", "", "", "") + _integer(0) + movie
    )

    from amc.native import read_native_catalog

    parsed = read_native_catalog(target).movies[0]
    assert parsed.framerate is None
    assert parsed.file_size is None
    assert parsed.extras["native_framerate_text"] == "not-a-rate"
    assert parsed.extras["native_file_size_text"] == "1,000 KB"


def test_native_reader_retains_negative_movie_number(tmp_path: Path):
    movie = _movie_42()
    movie = _integer(-7) + movie[4:]
    target = tmp_path / "negative-number.amc"
    target.write_bytes(
        _catalog("4.2", "", "", "", "", "", "") + _integer(0) + movie
    )

    from amc.native import read_native_catalog

    parsed = read_native_catalog(target).movies[0]
    assert parsed.number == 0
    assert parsed.extras["native_movie_number"] == -7


def test_native_reader_retains_duplicate_custom_field_values_in_order(tmp_path: Path):
    def field(name: str) -> bytes:
        return b"".join((
            _string("Duplicate"), _string(name), _string(""), _string("String"),
            _string(""), _string(""), _boolean(False), b",\x00\x00\x00",
            _boolean(False), _boolean(False), _boolean(False), _string(""),
        ))

    movie = _movie_41("first") + _string("second")
    # _movie_41 places its one custom value at the end, so both definitions consume
    # the two adjacent values above.
    target = tmp_path / "duplicates.amc"
    target.write_bytes(
        _catalog("4.1", "", "", "", "", "", "")
        + _integer(2)
        + field("First")
        + field("Second")
        + movie
    )

    from amc.native import read_native_catalog

    extras = read_native_catalog(target).movies[0].extras
    assert extras["Duplicate"] == "second"
    assert extras["native_custom_values"] == [
        {"tag": "Duplicate", "value": "first"},
        {"tag": "Duplicate", "value": "second"},
    ]


def test_native_reader_retains_custom_value_that_collides_with_reserved_key(
    tmp_path: Path,
):
    field = b"".join((
        _string("native_writer"), _string("Legacy writer field"), _string(""),
        _string("String"), _string(""), _string(""), _boolean(False),
        b",\x00\x00\x00", _boolean(False), _boolean(False), _boolean(False),
        _string(""),
    ))
    movie = _movie_42()
    extra_offset = movie.rfind(_boolean(True) + _string("trailer"))
    movie = movie[: extra_offset - 4] + _string("custom writer") + movie[extra_offset - 4 :]
    target = tmp_path / "reserved-collision.amc"
    target.write_bytes(
        _catalog("4.2", "", "", "", "", "", "")
        + _integer(1)
        + field
        + movie
    )

    from amc.native import read_native_catalog

    extras = read_native_catalog(target).movies[0].extras
    assert extras["native_writer"] == "Writer"
    assert extras["native_custom_values"] == [
        {"tag": "native_writer", "value": "custom writer"}
    ]


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
    with pytest.raises(CorruptCatalogError, match="cumulative string-size limit"):
        read_native_catalog(
            target, limits=NativeReadLimits(max_total_string_bytes=10)
        )


def test_native_property_read_applies_cumulative_string_budget(tmp_path: Path):
    from amc.native import NativeReadLimits

    target = tmp_path / "properties.amc"
    target.write_bytes(_catalog("3.5", "owner", "mail", "site", "description"))

    with pytest.raises(CorruptCatalogError, match="cumulative string-size limit"):
        read_native_properties(
            target, limits=NativeReadLimits(max_total_string_bytes=13)
        )


def test_native_read_limits_supplementary_records(tmp_path: Path):
    from amc.native import NativeReadLimits, read_native_catalog

    target = tmp_path / "extras.amc"
    target.write_bytes(
        _catalog("4.2", "", "", "", "", "", "")
        + _integer(0)
        + _movie_42()
    )

    with pytest.raises(CorruptCatalogError, match="movie exceeds supplementary-record"):
        read_native_catalog(target, limits=NativeReadLimits(max_extras_per_movie=0))
    with pytest.raises(
        CorruptCatalogError, match="cumulative supplementary-record limit"
    ):
        read_native_catalog(target, limits=NativeReadLimits(max_total_extras=0))


def test_native_read_limits_validate_configuration():
    from amc.native import NativeReadLimits

    for values in (
        {"max_movies": -1},
        {"max_picture_bytes": True},
        {"max_total_string_bytes": -1},
        {"max_extras_per_movie": True},
        {"max_total_extras": -1},
        {"max_custom_fields": True},
        {"max_list_values_per_field": -1},
    ):
        with pytest.raises(ValueError, match="non-negative integer"):
            NativeReadLimits(**values)


def test_every_truncation_of_empty_amc_42_fails_with_catalog_error(tmp_path: Path):
    """Exercise every byte boundary in a complete source-derived empty catalog."""
    from amc.errors import CatalogError
    from amc.native import read_native_catalog

    complete = _catalog("4.2", "owner", "mail", "site", "description", "", "")
    complete += _integer(0)
    target = tmp_path / "truncated.amc"

    for length in range(len(complete)):
        target.write_bytes(complete[:length])
        with pytest.raises(CatalogError) as caught:
            read_native_catalog(target)
        if isinstance(caught.value, CorruptCatalogError) and caught.value.offset is not None:
            assert 0 <= caught.value.offset <= length

    target.write_bytes(complete)
    assert read_native_catalog(target).movies == ()


def test_every_truncation_of_amc_42_movie_fails_deterministically(tmp_path: Path):
    """Ensure partial movie data never becomes a silently accepted shorter catalog."""
    from amc.native import read_native_catalog

    prefix = _catalog("4.2", "", "", "", "", "", "") + _integer(0)
    movie = _movie_42()
    target = tmp_path / "truncated-movie.amc"

    for length in range(1, len(movie)):
        target.write_bytes(prefix + movie[:length])
        with pytest.raises(CorruptCatalogError) as caught:
            read_native_catalog(target)
        if caught.value.offset is not None:
            assert len(prefix) <= caught.value.offset <= len(prefix) + length

    target.write_bytes(prefix + movie)
    assert len(read_native_catalog(target).movies) == 1


def _legacy_record(version: str, values: dict[str, object]) -> bytes:
    from amc.native import _legacy_layout

    layout, size = _legacy_layout(version)
    record = bytearray(size)
    for name, value in values.items():
        offset, kind, maximum = layout[name]
        if kind == "int":
            struct.pack_into("<i", record, offset, int(value))
        elif kind == "bool":
            record[offset] = int(bool(value))
        elif kind == "short":
            encoded = str(value).encode("cp1252")
            assert len(encoded) <= maximum
            record[offset] = len(encoded)
            record[offset + 1:offset + 1 + len(encoded)] = encoded
        else:
            encoded = str(value).encode("cp1252")
            record[offset:offset + len(encoded)] = encoded
    return bytes(record)


def _legacy_properties(**values: str) -> bytes:
    from amc.native import _LEGACY_PROPERTIES, _layout

    layout, size = _layout(_LEGACY_PROPERTIES)
    record = bytearray(size)
    for name, value in values.items():
        offset, _, maximum = layout[name]
        encoded = value.encode("cp1252")
        assert len(encoded) <= maximum
        record[offset] = len(encoded)
        record[offset + 1:offset + 1 + len(encoded)] = encoded
    return bytes(record)


def test_read_fixed_record_amc_30_catalog(tmp_path: Path):
    from amc.native import read_native_catalog

    record = _legacy_record("3.0", {
        "number": 7, "original_title": "Brazil", "translated_title": "Brazil",
        "director": "Terry Gilliam", "producer": "Arnon Milchan",
        "country": "UK", "year": 1985, "category": "Science Fiction",
        "length": 142, "actors": "Jonathan Pryce", "url": "https://example.test",
        "description": "Future imperfect.", "comments": "comment",
        "video_format": "DivX", "file_size_text": "123456",
        "resolution": "640x480", "languages": "English", "subtitles": "French",
        "rating": 4, "checked": True, "date": 730000, "picture": ".jpg",
        "picture_size": 3, "borrower": "Sam",
    })
    target = tmp_path / "legacy.amc"
    header = next(key for key, value in NATIVE_HEADERS.items() if value == "3.0")
    target.write_bytes(
        header + _legacy_properties(owner="Owner", mail="mail", site="site")
        + record + b"img"
    )
    result = read_native_catalog(target)
    movie = result.movies[0]
    assert (result.properties.owner, result.properties.mail) == ("Owner", "mail")
    assert (movie.number, movie.original_title, movie.rating, movie.borrower) == (
        7, "Brazil", 8.0, "Sam"
    )
    assert movie.extras["native_picture_base64"] == "aW1n"

    with pytest.raises(CorruptCatalogError, match="cumulative picture-size limit"):
        read_native_catalog(
            target, limits=NativeReadLimits(max_total_picture_bytes=2)
        )


def test_fixed_record_reader_rejects_truncation_and_retains_negative_number(
    tmp_path: Path,
):
    from amc.native import read_native_catalog

    header = next(key for key, value in NATIVE_HEADERS.items() if value == "1.0")
    record = _legacy_record("1.0", {"number": -3, "original_title": "Legacy"})
    target = tmp_path / "legacy.amc"
    target.write_bytes(header + record)
    movie = read_native_catalog(target).movies[0]
    assert movie.number == 0
    assert movie.extras["native_movie_number"] == -3
    target.write_bytes(header + record[:-1])
    with pytest.raises(CorruptCatalogError, match="truncated legacy native movie"):
        read_native_catalog(target)


@pytest.mark.parametrize("version", ["1.0", "1.1", "2.1"])
def test_read_older_fixed_record_catalogs(tmp_path: Path, version: str):
    from amc.native import read_native_catalog

    values: dict[str, object] = {
        "number": 1, "original_title": "Legacy", "year": 2000,
    }
    if version != "1.0":
        values["rating"] = 5
    if version in {"2.1"}:
        values.update({"checked": False, "date": 0})
    header = next(key for key, item in NATIVE_HEADERS.items() if item == version)
    properties = _legacy_properties(owner="Owner") if version == "2.1" else b""
    target = tmp_path / f"{version}.amc"
    target.write_bytes(header + properties + _legacy_record(version, values))
    movie = read_native_catalog(target).movies[0]
    assert movie.original_title == "Legacy"
    assert movie.rating == (None if version == "1.0" else 9.0)


def test_write_native_42_round_trip_retained_data(tmp_path: Path):
    from amc.catalog import Catalog
    from amc.model import Movie
    from amc.native import read_native_catalog, write_native_catalog

    field = {
        "tag": "Mood", "name": "Mood", "extension": "", "field_type": "List",
        "default_value": "Calm", "media_info": "", "multi_values": True,
        "multi_value_separator": ";", "remove_parentheses": False,
        "patch_values": False, "excluded_in_scripts": False,
        "gui_properties": "", "list_values": ["Calm", "Tense"],
        "list_auto_add": True, "list_sort": True,
        "list_auto_complete": False, "list_use_catalog_values": True,
    }
    movie = Movie(
        number=4, original_title="Brazil", year=1985, rating=8.5,
        framerate=24.0, file_size=123, checked=True, picture="cover.jpg",
        extras={
            "native_date": 730000, "native_writer": "Tom Stoppard",
            "native_color_tag": 3, "native_picture_base64": "aW1n",
            "native_custom_values": [{"tag": "Mood", "value": "Tense"}],
            "native_supplementary_records": [{
                "checked": True, "tag": "Bonus", "title": "Interview",
                "category": "Extra", "url": "", "description": "Behind scenes",
                "comments": "", "created_by": "Owner", "picture_path": "extra.jpg",
                "picture_base64": "eA==",
            }],
        },
    )
    catalog = Catalog([movie], metadata={"native": {
        "owner": "Owner", "mail": "mail@example.test", "site": "site",
        "description": "Catalog", "column_settings": "columns",
        "gui_properties": "gui", "custom_fields": [field],
    }})
    target = tmp_path / "catalog.amc"

    write_native_catalog(catalog, target)
    result = read_native_catalog(target)

    assert result.properties.version == "4.2"
    assert result.properties.owner == "Owner"
    assert result.properties.custom_fields[0].list_values == ("Calm", "Tense")
    restored = result.movies[0]
    assert (restored.original_title, restored.rating, restored.extras["Mood"]) == (
        "Brazil", 8.5, "Tense"
    )
    assert restored.extras["native_picture_base64"] == "aW1n"
    assert result.movie_extras[0][0].title == "Interview"
    assert result.movie_extras[0][0].picture_data == b"x"


def test_native_writer_is_atomic_on_encoding_failure(tmp_path: Path):
    from amc.catalog import Catalog
    from amc.model import Movie
    from amc.native import write_native_catalog

    target = tmp_path / "catalog.amc"
    target.write_bytes(b"existing")

    with pytest.raises(ValueError, match="cannot encode"):
        write_native_catalog(Catalog([Movie(number=1, original_title="snowman ☃")]), target)

    assert target.read_bytes() == b"existing"
    assert not (tmp_path / ".catalog.amc.tmp").exists()
