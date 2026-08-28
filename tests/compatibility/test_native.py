import os
import random
import stat
import struct
from pathlib import Path

import pytest

from amc.errors import CorruptCatalogError, UnsupportedFormatError, UnsupportedVersionError
from amc.native import (
    NATIVE_HEADER_SIZE,
    NATIVE_HEADERS,
    NativeReadLimits,
    _legacy_layout,
    identify_native_header,
    read_native_catalog,
    read_native_properties,
)

REAL_NATIVE_FIXTURES = Path(__file__).parent.parent / "fixtures" / "native-empty-one-movie"


def _string(value: str) -> bytes:
    encoded = value.encode("cp1252")
    return struct.pack("<i", len(encoded)) + encoded


def _catalog(version: str, *values: str) -> bytes:
    header = next(
        header for header, item_version in NATIVE_HEADERS.items() if item_version == version
    )
    return header + b"".join(_string(value) for value in values)


@pytest.mark.parametrize("version", ["3.1", "3.3"])
def test_read_legacy_modern_properties_skips_removed_icq(tmp_path: Path, version: str):
    target = tmp_path / "catalog.amc"
    target.write_bytes(_catalog(version, "Antoine", "a@example.test", "12345", "site", "Résumé"))

    properties = read_native_properties(target)

    assert (properties.version, properties.owner, properties.mail) == (
        version,
        "Antoine",
        "a@example.test",
    )
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
        "Owner",
        "mail",
        "site",
        "description",
    )
    assert properties.data_offset == target.stat().st_size


def test_native_properties_reject_fixed_record_versions(tmp_path: Path):
    target = tmp_path / "legacy.amc"
    target.write_bytes(
        next(header for header, version in NATIVE_HEADERS.items() if version == "3.0")
    )
    with pytest.raises(UnsupportedVersionError, match="fixed-record AMC 3.0"):
        read_native_properties(target)


def test_legacy_catalog_applies_picture_and_borrower_sidecars(tmp_path: Path):
    target = tmp_path / "movies.amc"
    header = next(key for key, value in NATIVE_HEADERS.items() if value == "1.1")
    layout, size = _legacy_layout("1.1")
    record = bytearray(size)
    struct.pack_into("<i", record, layout["number"][0], 7)
    record[layout["original_title"][0]] = 5
    record[layout["original_title"][0] + 1 : layout["original_title"][0] + 6] = b"Alien"
    target.write_bytes(header + record)
    (tmp_path / "movies_7.gif").write_bytes(b"GIF89a")
    (tmp_path / "movies.amcl").write_text("[Ripley]\n7=\n", encoding="cp1252")

    catalog = read_native_catalog(target)

    assert (catalog.movies[0].picture, catalog.movies[0].borrower) == ("movies_7.gif", "Ripley")


def test_legacy_movie_reader_wraps_invalid_movie_values_as_corrupt_catalog_error(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
):
    """A structural parse failure while building the Movie value must return a
    CorruptCatalogError diagnostic, not an unwrapped exception escaping
    validate_catalog and becoming a generic CLI usage error."""
    target = tmp_path / "movies.amc"
    header = next(key for key, value in NATIVE_HEADERS.items() if value == "1.0")
    _, size = _legacy_layout("1.0")
    target.write_bytes(header + bytes(size))

    def fail(*_args: object, **_kwargs: object) -> None:
        raise ValueError("rating must be between 0 and 10")

    monkeypatch.setattr("amc.model.Movie", fail)

    with pytest.raises(CorruptCatalogError, match="invalid legacy native movie value"):
        read_native_catalog(target)


def test_legacy_catalog_rejects_invalid_borrower_sidecar_number(tmp_path: Path):
    target = tmp_path / "movies.amc"
    header = next(key for key, value in NATIVE_HEADERS.items() if value == "1.0")
    _, size = _legacy_layout("1.0")
    target.write_bytes(header + bytes(size))
    (tmp_path / "movies.amcl").write_text("[Ripley]\nnot-a-number=\n", encoding="cp1252")

    with pytest.raises(CorruptCatalogError, match="invalid movie number"):
        read_native_catalog(target)


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
    """`field_type` uses the literal Pascal enum identifier upstream's own
    `ConvertFieldTypeToString` writes (`Movie Catalog/movieclass.pas`) --
    `ftList`, not bare `List`. This test originally synthesized the bare
    form, which the buggy reader/writer's own `== "list"` check happened to
    accept -- a self-consistent but wrong assumption a genuine AMC-produced
    catalog (an official sample shipped with the application) exposed, see
    `docs/PORT_AUDIT.md` finding 39."""
    field = b"".join(
        (
            _string("MyTag"),
            _string("My field"),
            _string("txt"),
            _string("ftList"),
            _string("default"),
            _string("General;0"),
            _boolean(True),
            b";\x00\x00\x00",
            _boolean(True),
            _boolean(False),
            _boolean(True),
            _string("width=100"),
            struct.pack("<i", 2),
            _string("One"),
            _string("Two"),
            _boolean(True),
            _boolean(False),
            _boolean(True),
            _boolean(False),
        )
    )
    target = tmp_path / "fields.amc"
    target.write_bytes(
        _catalog("4.2", "Owner", "mail", "site", "description", "columns", "gui")
        + struct.pack("<i", 1)
        + _string("MyTag")
        + field[len(_string("MyTag")) :]
    )

    properties = read_native_properties(target)

    assert (properties.column_settings, properties.gui_properties) == ("columns", "gui")
    assert len(properties.custom_fields) == 1
    custom = properties.custom_fields[0]
    assert (custom.tag, custom.name, custom.extension, custom.field_type) == (
        "MyTag",
        "My field",
        "txt",
        "ftList",
    )
    assert custom.list_values == ("One", "Two")
    assert (custom.multi_values, custom.multi_value_separator) == (True, ";")
    assert (custom.remove_parentheses, custom.patch_values, custom.excluded_in_scripts) == (
        True,
        False,
        True,
    )
    assert (
        custom.list_auto_add,
        custom.list_sort,
        custom.list_auto_complete,
        custom.list_use_catalog_values,
    ) == (True, False, True, False)


def test_custom_field_parser_rejects_invalid_count_and_boolean(tmp_path: Path):
    prefix = _catalog("4.2", "", "", "", "", "", "")
    invalid_count = tmp_path / "count.amc"
    invalid_count.write_bytes(prefix + struct.pack("<i", -1))
    with pytest.raises(CorruptCatalogError, match="invalid native custom-field count"):
        read_native_properties(invalid_count)

    invalid_bool = tmp_path / "bool.amc"
    field = b"".join(
        (
            _string("tag"),
            _string("name"),
            _string(""),
            _string("String"),
            _string(""),
            _string(""),
            b"\x02",
        )
    )
    invalid_bool.write_bytes(prefix + struct.pack("<i", 1) + field)
    with pytest.raises(CorruptCatalogError, match="invalid native boolean"):
        read_native_properties(invalid_bool)


def test_custom_field_parser_applies_definition_and_list_limits(tmp_path: Path):
    from amc.native import NativeReadLimits

    prefix = _catalog("4.2", "", "", "", "", "", "")
    definitions = tmp_path / "definitions.amc"
    definitions.write_bytes(prefix + struct.pack("<i", 1))
    with pytest.raises(CorruptCatalogError, match="custom-field limit"):
        read_native_properties(definitions, limits=NativeReadLimits(max_custom_fields=0))

    list_field = b"".join(
        (
            _string("tag"),
            _string("name"),
            _string(""),
            _string("ftList"),
            _string(""),
            _string(""),
            _boolean(False),
            b",\x00\x00\x00",
            _boolean(False),
            _boolean(False),
            _boolean(False),
            _string(""),
            struct.pack("<i", 1),
        )
    )
    values = tmp_path / "values.amc"
    values.write_bytes(prefix + struct.pack("<i", 1) + list_field)
    with pytest.raises(CorruptCatalogError, match="list-value limit"):
        read_native_properties(values, limits=NativeReadLimits(max_list_values_per_field=0))


def _integer(value: int) -> bytes:
    return struct.pack("<i", value)


def _movie_41(custom_value: str = "custom") -> bytes:
    integers = [7, 0, 83, 1985, 142, 1200, 192, 2, 3]
    strings = [
        "DISC-1",
        "Blu-ray",
        "Owned",
        "",
        "Brazil",
        "Brazil",
        "Terry Gilliam",
        "Arnon Milchan",
        "UK",
        "Science Fiction",
        "Jonathan Pryce",
        "https://example.test",
        "Future imperfect.",
        "comment",
        "H264",
        "AAC",
        "1920x1080",
        "23.976",
        "English",
        "French",
        "123456",
    ]
    return (
        b"".join(_integer(value) for value in integers)
        + _boolean(True)
        + b"".join(_string(value) for value in strings)
        + _string("cover.jpg")
        + _integer(3)
        + b"img"
        + _string(custom_value)
    )


def test_read_amc_41_movie_record(tmp_path: Path):
    field = b"".join(
        (
            _string("Inventory"),
            _string("Inventory"),
            _string(""),
            _string("String"),
            _string(""),
            _string(""),
            _boolean(False),
            b",\x00\x00\x00",
            _boolean(False),
            _boolean(False),
            _boolean(False),
            _string(""),
        )
    )
    target = tmp_path / "movie.amc"
    target.write_bytes(
        _catalog("4.1", "Owner", "mail", "site", "description", "", "")
        + _integer(1)
        + field
        + _movie_41("A-42")
    )

    from amc.native import read_native_catalog

    result = read_native_catalog(target)

    assert result.properties.owner == "Owner"
    assert len(result.movies) == 1
    movie = result.movies[0]
    assert (movie.number, movie.original_title, movie.year, movie.rating) == (
        7,
        "Brazil",
        1985,
        8.3,
    )
    assert (movie.video_bitrate, movie.framerate, movie.file_size) == (1200, 23.976, 123456)
    assert movie.checked and movie.picture == "cover.jpg"
    assert movie.extras == {
        "Inventory": "A-42",
        "native_custom_values": [{"tag": "Inventory", "value": "A-42"}],
        "native_movie_number": 7,
        "native_picture_base64": "aW1n",
    }
    assert movie.color_tag == 3


def test_native_movie_reader_rejects_truncated_picture_and_amc_42(tmp_path: Path):
    target = tmp_path / "truncated.amc"
    payload = _catalog("4.1", "", "", "", "", "", "") + _integer(0)
    movie_payload = _movie_41()
    picture_end = movie_payload.index(b"img") + 3
    target.write_bytes(payload + movie_payload[: picture_end - 2])
    from amc.native import read_native_catalog

    with pytest.raises(CorruptCatalogError, match="truncated native picture data"):
        read_native_catalog(target)

    version_42 = tmp_path / "42.amc"
    version_42.write_bytes(_catalog("4.2", "", "", "", "", "", "") + _integer(0))
    assert read_native_catalog(version_42).movies == ()


def test_modern_movie_reader_wraps_invalid_movie_values_as_corrupt_catalog_error(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
):
    """Same guarantee as the legacy reader: a structural parse failure while
    building the Movie value returns a CorruptCatalogError diagnostic rather
    than an unwrapped exception escaping validate_catalog."""
    target = tmp_path / "movie.amc"
    target.write_bytes(_catalog("4.2", "", "", "", "", "", "") + _integer(0) + _movie_42())

    def fail(*_args: object, **_kwargs: object) -> None:
        raise ValueError("rating must be between 0 and 10")

    monkeypatch.setattr("amc.model.Movie", fail)

    with pytest.raises(CorruptCatalogError, match="invalid native movie value"):
        read_native_catalog(target)


def _movie_42() -> bytes:
    integers = [8, 10, 20, 75, 91, 2020, 100, 800, 128, 1, 2]
    strings = [
        "MEDIA",
        "File",
        "Digital",
        "",
        "Title",
        "Translated",
        "Director",
        "Producer",
        "Writer",
        "Composer",
        "Country",
        "Category",
        "PG",
        "Actors",
        "url",
        "description",
        "comments",
        "/movie.mkv",
        "H265",
        "AAC",
        "3840x2160",
        "24",
        "English",
        "",
        "1000",
    ]
    extra = (
        _boolean(True)
        + _string("trailer")
        + _string("Trailer")
        + _string("Video")
        + _string("https://example.test/trailer")
        + _string("desc")
        + _string("notes")
        + _string("script")
        + _string("extra.jpg")
        + _integer(2)
        + b"im"
    )
    return (
        b"".join(_integer(value) for value in integers)
        + _boolean(True)
        + b"".join(_string(value) for value in strings)
        + _string("cover.jpg")
        + _integer(0)
        + _integer(1)
        + extra
    )


def test_read_amc_42_movie_and_extra(tmp_path: Path):
    target = tmp_path / "movie42.amc"
    target.write_bytes(
        _catalog("4.2", "Owner", "mail", "site", "description", "", "") + _integer(0) + _movie_42()
    )
    from amc.native import read_native_catalog

    result = read_native_catalog(target)

    movie = result.movies[0]
    assert (movie.number, movie.original_title, movie.rating) == (8, "Title", 9.1)
    assert (movie.user_rating, movie.color_tag) == (7.5, 2)
    assert (movie.writer, movie.composer, movie.certification) == ("Writer", "Composer", "PG")
    assert movie.file_path == "/movie.mkv"
    assert len(result.movie_extras[0]) == 1
    extra = result.movie_extras[0][0]
    assert (extra.tag, extra.title, extra.category, extra.picture_path, extra.picture_size) == (
        "trailer",
        "Trailer",
        "Video",
        "extra.jpg",
        2,
    )
    assert extra.checked and extra.created_by == "script"
    assert extra.picture_data == b"im"
    assert movie.extras["native_supplementary_records"][0]["picture_base64"] == "aW0="


def _blank_movie_42() -> bytes:
    """A movie record with every -1-sentinelled integer field left at its
    genuine default: `iYear`/`iLength`/`iVideoBitrate`/`iAudioBitrate`/
    `iDisks` (this port's `media_count`) are each initialized to `-1` in
    upstream's own `TMovie.Reset` (`Movie Catalog/movieclass.pas`), matching
    a genuine blank one-movie AMC 4.1/4.2 catalog contributed by a user for
    local debugging (not committed to the repository)."""
    integers = [1, 46262, 0, -1, -1, -1, -1, -1, -1, -1, 0]
    strings = [""] * 25
    return (
        b"".join(_integer(value) for value in integers)
        + _boolean(True)
        + b"".join(_string(value) for value in strings)
        + _string("")
        + _integer(0)
        + _integer(0)
    )


def test_read_amc_42_movie_preserves_undefined_year_length_and_bitrates(tmp_path: Path):
    """`_read_movie` previously mapped these five fields with `value or
    None`, which only substitutes `None` for `0` -- not upstream's actual
    `-1` "no value" sentinel confirmed above, so a genuinely blank movie's
    year/length/bitrates/disk-count read back as the literal integer `-1`
    instead of `None`. `rating`/`user_rating` already used the correct
    `None if value < 0 else value` pattern; this brings the other five
    fields in line with it."""
    target = tmp_path / "blank-movie.amc"
    target.write_bytes(_catalog("4.2", "", "", "", "", "", "") + _integer(0) + _blank_movie_42())

    movie = read_native_catalog(target).movies[0]

    assert (movie.year, movie.length, movie.media_count) == (None, None, None)
    assert (movie.video_bitrate, movie.audio_bitrate) == (None, None)


def test_write_amc_42_movie_encodes_unset_year_length_and_bitrates_as_negative_one(
    tmp_path: Path,
):
    """The writer's inverse bug: `movie.year or 0` wrote the plain integer
    `0` for an unset field instead of upstream's own `-1` sentinel, so a
    Python-exported catalog would not present the same "no value" state a
    genuine AMC catalog does if reopened in upstream AMC (0 is a very
    different displayed year/length/bitrate/disk-count than "none entered
    yet"). Fixed to mirror `rating`'s existing `-1`-when-`None` write."""
    from amc.catalog import Catalog
    from amc.model import Movie
    from amc.native import read_native_catalog, write_native_catalog

    catalog = Catalog([Movie(number=1)])
    target = tmp_path / "unset-fields.amc"

    write_native_catalog(catalog, target)

    reread = read_native_catalog(target).movies[0]
    assert (reread.year, reread.length, reread.media_count) == (None, None, None)
    assert (reread.video_bitrate, reread.audio_bitrate) == (None, None)


@pytest.mark.parametrize("version", ["3.5", "4.1", "4.2"])
def test_reads_a_genuine_empty_native_catalog(version: str):
    """Genuine empty catalogs from real, separately installed Ant Movie
    Catalog 3.5/4.1/4.2 (tests/fixtures/native-empty-one-movie/
    manifest.json) -- the first native-format fixtures this port has ever
    had permission to commit, and the first spanning more than one version
    at once."""
    catalog = read_native_catalog(REAL_NATIVE_FIXTURES / f"empty-{version}.amc")
    assert catalog.properties.version == version
    assert catalog.movies == ()


@pytest.mark.parametrize("version", ["4.1", "4.2"])
def test_reads_a_genuine_one_movie_native_catalog_with_every_optional_field_unset(
    version: str,
):
    """The regression case for finding 38: a genuine, never-edited blank
    movie added in real AMC and immediately saved. Before the fix, this
    movie's year/length/media_count/video_bitrate/audio_bitrate read back as
    the literal integer -1 (upstream's own sentinel) instead of `None`."""
    catalog = read_native_catalog(REAL_NATIVE_FIXTURES / f"one-movie-{version}.amc")

    assert len(catalog.movies) == 1
    movie = catalog.movies[0]
    assert (movie.title, movie.original_title) == ("", "")
    assert (movie.year, movie.length, movie.media_count) == (None, None, None)
    assert (movie.video_bitrate, movie.audio_bitrate) == (None, None)
    assert movie.checked is True


@pytest.mark.parametrize(
    "name",
    ["empty-3.5.amc", "empty-4.1.amc", "empty-4.2.amc", "one-movie-4.1.amc", "one-movie-4.2.amc"],
)
def test_genuine_native_fixture_round_trips_through_this_ports_writer(name: str, tmp_path: Path):
    """Writing back a genuinely upstream-produced catalog and rereading it
    must reproduce identical movies -- the strongest round-trip check
    available without a genuine AMC installation to reopen the result in."""
    from amc.catalog import Catalog
    from amc.native import write_native_catalog

    original = read_native_catalog(REAL_NATIVE_FIXTURES / name)
    target = tmp_path / "roundtrip.amc"

    write_native_catalog(Catalog(original.movies), target)

    reread = read_native_catalog(target)
    assert [m.to_dict() for m in reread.movies] == [m.to_dict() for m in original.movies]


def test_amc_42_rejects_truncated_extra_picture(tmp_path: Path):
    target = tmp_path / "broken42.amc"
    payload = _catalog("4.2", "", "", "", "", "", "") + _integer(0) + _movie_42()
    target.write_bytes(payload[:-1])
    from amc.native import read_native_catalog

    with pytest.raises(CorruptCatalogError, match="truncated native extra picture data"):
        read_native_catalog(target)


def test_generic_storage_loads_native_catalog(tmp_path: Path):
    target = tmp_path / "movie.amc"
    field = b"".join(
        (
            _string("Inventory"),
            _string("Inventory"),
            _string(""),
            _string("String"),
            _string(""),
            _string(""),
            _boolean(False),
            b",\x00\x00\x00",
            _boolean(False),
            _boolean(False),
            _boolean(False),
            _string(""),
        )
    )
    target.write_bytes(_catalog("4.1", "", "", "", "", "", "") + _integer(1) + field + _movie_41())
    from amc.storage import load

    catalog = load(target)

    assert len(catalog) == 1
    assert next(iter(catalog)).original_title == "Brazil"
    assert catalog.metadata["native"]["version"] == "4.1"


def test_cli_imports_native_catalog_to_json(tmp_path: Path):
    field = b"".join(
        (
            _string("Inventory"),
            _string("Inventory"),
            _string(""),
            _string("String"),
            _string(""),
            _string(""),
            _boolean(False),
            b",\x00\x00\x00",
            _boolean(False),
            _boolean(False),
            _boolean(False),
            _string(""),
        )
    )
    source = tmp_path / "movie.amc"
    source.write_bytes(
        _catalog("4.1", "", "", "", "", "", "") + _integer(1) + field + _movie_41("A-42")
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
    field = b"".join(
        (
            _string("Inventory"),
            _string("Inventory"),
            _string("txt"),
            _string("String"),
            _string("default"),
            _string("General;0"),
            _boolean(False),
            b",\x00\x00\x00",
            _boolean(False),
            _boolean(False),
            _boolean(True),
            _string("width=100"),
        )
    )
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
    assert restored_movie.extras["native_supplementary_records"][0]["picture_base64"] == "aW0="
    assert restored.metadata["native"]["custom_fields"][0]["field_type"] == "String"
    assert second_json.read_text(encoding="utf-8") == first_json.read_text(encoding="utf-8")


def test_native_reader_retains_unrepresentable_numeric_text(tmp_path: Path):
    """Do not silently discard native scalar text the common model cannot parse."""
    movie = _movie_42()
    movie = movie.replace(_string("24"), _string("not-a-rate"), 1)
    movie = movie.replace(_string("1000"), _string("1,000 KB"), 1)
    target = tmp_path / "numeric-text.amc"
    target.write_bytes(_catalog("4.2", "", "", "", "", "", "") + _integer(0) + movie)

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
    target.write_bytes(_catalog("4.2", "", "", "", "", "", "") + _integer(0) + movie)

    from amc.native import read_native_catalog

    parsed = read_native_catalog(target).movies[0]
    assert parsed.number == 0
    assert parsed.extras["native_movie_number"] == -7


def test_native_reader_retains_duplicate_custom_field_values_in_order(tmp_path: Path):
    def field(name: str) -> bytes:
        return b"".join(
            (
                _string("Duplicate"),
                _string(name),
                _string(""),
                _string("String"),
                _string(""),
                _string(""),
                _boolean(False),
                b",\x00\x00\x00",
                _boolean(False),
                _boolean(False),
                _boolean(False),
                _string(""),
            )
        )

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
    field = b"".join(
        (
            _string("native_writer"),
            _string("Legacy writer field"),
            _string(""),
            _string("String"),
            _string(""),
            _string(""),
            _boolean(False),
            b",\x00\x00\x00",
            _boolean(False),
            _boolean(False),
            _boolean(False),
            _string(""),
        )
    )
    movie = _movie_42()
    extra_offset = movie.rfind(_boolean(True) + _string("trailer"))
    movie = movie[: extra_offset - 4] + _string("custom writer") + movie[extra_offset - 4 :]
    target = tmp_path / "reserved-collision.amc"
    target.write_bytes(_catalog("4.2", "", "", "", "", "", "") + _integer(1) + field + movie)

    from amc.native import read_native_catalog

    parsed = read_native_catalog(target).movies[0]
    extras = parsed.extras
    assert parsed.writer == "Writer"
    assert extras["native_writer"] == "custom writer"
    assert extras["native_custom_values"] == [{"tag": "native_writer", "value": "custom writer"}]


def test_generic_storage_detects_native_header_without_amc_extension(tmp_path: Path):
    target = tmp_path / "catalog.data"
    target.write_bytes(
        _catalog("4.1", "", "", "", "", "", "")
        + _integer(0)
        + _movie_41()[: -len(_string("custom"))]
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
        + _integer(0)
        + _movie_41()[: -len(_string("custom"))]
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
        read_native_catalog(target, limits=NativeReadLimits(max_total_picture_bytes=2))
    with pytest.raises(CorruptCatalogError, match="cumulative string-size limit"):
        read_native_catalog(target, limits=NativeReadLimits(max_total_string_bytes=10))


def test_native_property_read_applies_cumulative_string_budget(tmp_path: Path):
    from amc.native import NativeReadLimits

    target = tmp_path / "properties.amc"
    target.write_bytes(_catalog("3.5", "owner", "mail", "site", "description"))

    with pytest.raises(CorruptCatalogError, match="cumulative string-size limit"):
        read_native_properties(target, limits=NativeReadLimits(max_total_string_bytes=13))


def test_native_reader_preserves_undefined_cp1252_bytes(tmp_path: Path):
    target = tmp_path / "ansi-byte.amc"
    raw_owner = b"Owner\x90Name"
    target.write_bytes(
        next(header for header, version in NATIVE_HEADERS.items() if version == "4.2")
        + _integer(len(raw_owner))
        + raw_owner
        + _string("") * 5
        + _integer(0)
    )

    assert read_native_properties(target).owner == "Owner\x90Name"


def test_native_writer_round_trips_undefined_cp1252_bytes(tmp_path: Path):
    """The reader losslessly preserves cp1252's five undefined byte positions
    (0x81/0x8D/0x8F/0x90/0x9D) by decoding them to the identically-numbered
    code point (see the test above). A genuine AMC 4.2 native catalog
    contributed by a user for local debugging turned out to contain one of
    these bytes in a real movie's string field, and writing it straight back
    out with plain str.encode("cp1252") failed outright -- cp1252 has no
    encoding for that code point at all, even though decoding it is exactly
    how it got there. The writer must invert the same preservation the
    reader performs, not just tolerate whatever cp1252 already covers."""
    from amc.catalog import Catalog
    from amc.model import Movie
    from amc.native import read_native_catalog, write_native_catalog

    original = "Director\x90Name"
    catalog = Catalog([Movie(number=1, director=original)])
    target = tmp_path / "undefined-byte.amc"

    write_native_catalog(catalog, target)
    result = read_native_catalog(target)

    assert result.movies[0].director == original


def test_native_read_limits_supplementary_records(tmp_path: Path):
    from amc.native import NativeReadLimits, read_native_catalog

    target = tmp_path / "extras.amc"
    target.write_bytes(_catalog("4.2", "", "", "", "", "", "") + _integer(0) + _movie_42())

    with pytest.raises(CorruptCatalogError, match="movie exceeds supplementary-record"):
        read_native_catalog(target, limits=NativeReadLimits(max_extras_per_movie=0))
    with pytest.raises(CorruptCatalogError, match="cumulative supplementary-record limit"):
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


@pytest.mark.parametrize("version", ["1.0", "1.1", "2.1", "3.0"])
def test_every_legacy_movie_truncation_fails_deterministically(tmp_path: Path, version: str):
    """Reject every partial fixed record instead of silently dropping its bytes."""
    from amc.native import read_native_catalog

    header = next(key for key, item in NATIVE_HEADERS.items() if item == version)
    properties = _legacy_properties(owner="Owner") if version in {"2.1", "3.0"} else b""
    record = _legacy_record(
        version,
        {
            "number": 1,
            "original_title": "Legacy",
            **({"picture_size": 3} if version == "3.0" else {}),
        },
    )
    picture = b"img" if version == "3.0" else b""
    prefix = header + properties
    complete = prefix + record + picture
    target = tmp_path / f"truncated-{version}.amc"

    for length in range(1, len(record) + len(picture)):
        target.write_bytes(prefix + (record + picture)[:length])
        with pytest.raises(CorruptCatalogError) as caught:
            read_native_catalog(target)
        if caught.value.offset is not None:
            assert len(prefix) <= caught.value.offset <= len(prefix) + length

    target.write_bytes(complete)
    assert len(read_native_catalog(target).movies) == 1


def test_seeded_native_byte_mutations_have_bounded_public_outcomes(tmp_path: Path):
    """Broaden corrupt-input coverage without accepting internal exceptions."""
    from amc.errors import CatalogError
    from amc.native import NativeReadLimits, read_native_catalog

    complete = _catalog("4.2", "owner", "mail", "site", "description", "", "")
    complete += _integer(0) + _movie_42()
    target = tmp_path / "mutated.amc"
    generator = random.Random(42)
    limits = NativeReadLimits(
        max_file_bytes=len(complete),
        max_movies=4,
        max_picture_bytes=1024,
        max_total_picture_bytes=2048,
        max_total_string_bytes=4096,
        max_extras_per_movie=4,
        max_total_extras=8,
        max_custom_fields=4,
        max_list_values_per_field=8,
    )

    for _ in range(250):
        mutated = bytearray(complete)
        offset = generator.randrange(NATIVE_HEADER_SIZE, len(mutated))
        mutated[offset] ^= generator.randrange(1, 256)
        target.write_bytes(mutated)
        try:
            result = read_native_catalog(target, limits=limits)
        except CatalogError as error:
            if isinstance(error, CorruptCatalogError) and error.offset is not None:
                assert 0 <= error.offset <= len(mutated)
        else:
            assert len(result.movies) <= limits.max_movies


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
            record[offset + 1 : offset + 1 + len(encoded)] = encoded
        else:
            encoded = str(value).encode("cp1252")
            record[offset : offset + len(encoded)] = encoded
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
        record[offset + 1 : offset + 1 + len(encoded)] = encoded
    return bytes(record)


def test_read_fixed_record_amc_30_catalog(tmp_path: Path):
    from amc.native import read_native_catalog

    record = _legacy_record(
        "3.0",
        {
            "number": 7,
            "original_title": "Brazil",
            "translated_title": "Brazil",
            "director": "Terry Gilliam",
            "producer": "Arnon Milchan",
            "country": "UK",
            "year": 1985,
            "category": "Science Fiction",
            "length": 142,
            "actors": "Jonathan Pryce",
            "url": "https://example.test",
            "description": "Future imperfect.",
            "comments": "comment",
            "video_format": "DivX",
            "file_size_text": "123456",
            "resolution": "640x480",
            "languages": "English",
            "subtitles": "French",
            "rating": 4,
            "checked": True,
            "date": 730000,
            "picture": ".jpg",
            "picture_size": 3,
            "borrower": "Sam",
        },
    )
    target = tmp_path / "legacy.amc"
    header = next(key for key, value in NATIVE_HEADERS.items() if value == "3.0")
    target.write_bytes(
        header + _legacy_properties(owner="Owner", mail="mail", site="site") + record + b"img"
    )
    result = read_native_catalog(target)
    movie = result.movies[0]
    assert (result.properties.owner, result.properties.mail) == ("Owner", "mail")
    assert (movie.number, movie.original_title, movie.rating, movie.borrower) == (
        7,
        "Brazil",
        8.0,
        "Sam",
    )
    assert movie.extras["native_picture_base64"] == "aW1n"

    with pytest.raises(CorruptCatalogError, match="cumulative picture-size limit"):
        read_native_catalog(target, limits=NativeReadLimits(max_total_picture_bytes=2))


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
        "number": 1,
        "original_title": "Legacy",
        "year": 2000,
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
        "tag": "Mood",
        "name": "Mood",
        "extension": "",
        "field_type": "ftList",
        "default_value": "Calm",
        "media_info": "",
        "multi_values": True,
        "multi_value_separator": ";",
        "remove_parentheses": False,
        "patch_values": False,
        "excluded_in_scripts": False,
        "gui_properties": "",
        "list_values": ["Calm", "Tense"],
        "list_auto_add": True,
        "list_sort": True,
        "list_auto_complete": False,
        "list_use_catalog_values": True,
    }
    movie = Movie(
        number=4,
        original_title="Brazil",
        year=1985,
        rating=8.5,
        user_rating=7.5,
        color_tag=0,
        framerate=24.0,
        file_size=123,
        checked=True,
        picture="cover.jpg",
        writer="Tom Stoppard",
        composer="Michael Kamen",
        certification="R",
        file_path="/movies/brazil.mkv",
        extras={
            "native_date": 730000,
            "native_color_tag": 3,
            "native_picture_base64": "aW1n",
            "native_custom_values": [{"tag": "Mood", "value": "Tense"}],
            "native_supplementary_records": [
                {
                    "checked": True,
                    "tag": "Bonus",
                    "title": "Interview",
                    "category": "Extra",
                    "url": "",
                    "description": "Behind scenes",
                    "comments": "",
                    "created_by": "Owner",
                    "picture_path": "extra.jpg",
                    "picture_base64": "eA==",
                }
            ],
        },
    )
    catalog = Catalog(
        [movie],
        metadata={
            "native": {
                "owner": "Owner",
                "mail": "mail@example.test",
                "site": "site",
                "description": "Catalog",
                "column_settings": "columns",
                "gui_properties": "gui",
                "custom_fields": [field],
            }
        },
    )
    target = tmp_path / "catalog.amc"

    write_native_catalog(catalog, target)
    result = read_native_catalog(target)

    assert result.properties.version == "4.2"
    assert result.properties.owner == "Owner"
    assert result.properties.custom_fields[0].list_values == ("Calm", "Tense")
    restored = result.movies[0]
    assert (restored.original_title, restored.rating, restored.extras["Mood"]) == (
        "Brazil",
        8.5,
        "Tense",
    )
    assert (restored.writer, restored.composer, restored.certification) == (
        "Tom Stoppard",
        "Michael Kamen",
        "R",
    )
    assert restored.file_path == "/movies/brazil.mkv"
    assert (restored.user_rating, restored.color_tag) == (7.5, 0)
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
    assert not target.with_suffix(".bak").exists()
    assert not (tmp_path / ".catalog.amc.tmp").exists()


def test_native_writer_backs_up_existing_destination(tmp_path: Path):
    from amc.catalog import Catalog
    from amc.model import Movie
    from amc.native import read_native_catalog, write_native_catalog

    target = tmp_path / "catalog.amc"
    backup = target.with_suffix(".bak")
    target.write_bytes(b"previous catalog")
    backup.write_bytes(b"older backup")

    write_native_catalog(Catalog([Movie(original_title="Alien")]), target)

    assert backup.read_bytes() == b"previous catalog"
    assert read_native_catalog(target).movies[0].original_title == "Alien"
    assert not (tmp_path / ".catalog.bak.tmp").exists()


@pytest.mark.skipif(os.name == "nt", reason="Windows cannot fsync directory handles")
def test_native_writer_fsyncs_backup_and_catalog_directory_entries(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
):
    from amc.catalog import Catalog
    from amc.native import write_native_catalog

    target = tmp_path / "catalog.amc"
    target.write_bytes(b"previous catalog")
    original_fsync = os.fsync
    directory_syncs = 0

    def count_directory_syncs(descriptor: int) -> None:
        nonlocal directory_syncs
        if stat.S_ISDIR(os.fstat(descriptor).st_mode):
            directory_syncs += 1
        original_fsync(descriptor)

    monkeypatch.setattr("amc.native.os.fsync", count_directory_syncs)
    write_native_catalog(Catalog(), target)

    assert directory_syncs == 2


def test_native_writer_preserves_destination_when_backup_fails(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
):
    from amc.catalog import Catalog
    from amc.native import write_native_catalog

    target = tmp_path / "catalog.amc"
    backup = target.with_suffix(".bak")
    target.write_bytes(b"trusted catalog")
    backup.write_bytes(b"trusted older backup")

    def fail_copy(*args: object, **kwargs: object) -> None:
        raise OSError("injected backup failure")

    monkeypatch.setattr("amc.native.shutil.copyfileobj", fail_copy)
    with pytest.raises(OSError, match="injected backup failure"):
        write_native_catalog(Catalog(), target)

    assert target.read_bytes() == b"trusted catalog"
    assert backup.read_bytes() == b"trusted older backup"
    assert not (tmp_path / ".catalog.amc.tmp").exists()
    assert not (tmp_path / ".catalog.bak.tmp").exists()


def test_native_writer_preserves_destination_when_serialization_is_interrupted(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
):
    from amc.catalog import Catalog
    from amc.model import Movie
    from amc.native import _BoundedWriter, write_native_catalog

    target = tmp_path / "catalog.amc"
    backup = target.with_suffix(".bak")
    target.write_bytes(b"trusted catalog")
    backup.write_bytes(b"trusted older backup")
    original_write = _BoundedWriter.write
    calls = 0

    def interrupt_write(self: _BoundedWriter, data: bytes) -> int:
        nonlocal calls
        calls += 1
        if calls == 5:
            raise OSError("injected write interruption")
        return original_write(self, data)

    monkeypatch.setattr(_BoundedWriter, "write", interrupt_write)
    with pytest.raises(OSError, match="injected write interruption"):
        write_native_catalog(Catalog([Movie(original_title="Alien")]), target)

    assert target.read_bytes() == b"trusted catalog"
    assert backup.read_bytes() == b"trusted older backup"
    assert not (tmp_path / ".catalog.amc.tmp").exists()


def test_native_writer_preserves_destination_when_replacement_is_interrupted(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
):
    from amc.catalog import Catalog
    from amc.native import write_native_catalog

    target = tmp_path / "catalog.amc"
    backup = target.with_suffix(".bak")
    target.write_bytes(b"trusted catalog")
    original_replace = Path.replace

    def interrupt_catalog_replace(self: Path, destination: Path) -> Path:
        if destination == target:
            raise OSError("injected replacement interruption")
        return original_replace(self, destination)

    monkeypatch.setattr(Path, "replace", interrupt_catalog_replace)
    with pytest.raises(OSError, match="injected replacement interruption"):
        write_native_catalog(Catalog(), target)

    assert target.read_bytes() == b"trusted catalog"
    assert backup.read_bytes() == b"trusted catalog"
    assert not (tmp_path / ".catalog.amc.tmp").exists()
    assert not (tmp_path / ".catalog.bak.tmp").exists()


def test_native_writer_limits_preserve_existing_destination(tmp_path: Path):
    from amc.catalog import Catalog
    from amc.model import Movie
    from amc.native import NativeWriteLimits, write_native_catalog

    target = tmp_path / "catalog.amc"
    target.write_bytes(b"existing")
    catalog = Catalog([Movie(original_title="Alien")])

    with pytest.raises(ValueError, match="movie-count limit"):
        write_native_catalog(catalog, target, limits=NativeWriteLimits(max_movies=0))
    with pytest.raises(ValueError, match="output-size limit"):
        write_native_catalog(catalog, target, limits=NativeWriteLimits(max_file_bytes=64))

    assert target.read_bytes() == b"existing"
    assert not (tmp_path / ".catalog.amc.tmp").exists()


def test_native_writer_limits_cumulative_encoded_strings(tmp_path: Path):
    from amc.catalog import Catalog
    from amc.model import Movie
    from amc.native import NativeWriteLimits, write_native_catalog

    target = tmp_path / "strings.amc"
    target.write_bytes(b"existing")
    catalog = Catalog([Movie(original_title="Alien")])

    with pytest.raises(ValueError, match="cumulative string-size limit"):
        write_native_catalog(
            catalog,
            target,
            limits=NativeWriteLimits(max_total_string_bytes=4),
        )

    assert target.read_bytes() == b"existing"
    assert not (tmp_path / ".strings.amc.tmp").exists()


def test_native_writer_counts_encoded_bytes_not_characters(tmp_path: Path):
    from amc.catalog import Catalog
    from amc.model import Movie
    from amc.native import NativeWriteLimits, write_native_catalog

    catalog = Catalog([Movie(original_title="é")])

    with pytest.raises(ValueError, match="cumulative string-size limit"):
        write_native_catalog(
            catalog,
            tmp_path / "utf8.amc",
            encoding="utf-8",
            limits=NativeWriteLimits(max_total_string_bytes=1),
        )


def test_native_writer_limits_custom_fields_and_list_values(tmp_path: Path):
    from amc.catalog import Catalog
    from amc.native import NativeWriteLimits, write_native_catalog

    field = {"tag": "Mood", "field_type": "ftList", "list_values": ["Calm"]}
    catalog = Catalog(metadata={"native": {"custom_fields": [field]}})

    with pytest.raises(ValueError, match="custom-field limit"):
        write_native_catalog(
            catalog,
            tmp_path / "fields.amc",
            limits=NativeWriteLimits(max_custom_fields=0),
        )
    with pytest.raises(ValueError, match="list-value limit"):
        write_native_catalog(
            catalog,
            tmp_path / "values.amc",
            limits=NativeWriteLimits(max_list_values_per_field=0),
        )


def test_native_writer_limits_pictures_and_supplementary_records(tmp_path: Path):
    from amc.catalog import Catalog
    from amc.model import Movie
    from amc.native import NativeWriteLimits, write_native_catalog

    movie = Movie(
        extras={
            "native_picture_base64": "aW1n",
            "native_supplementary_records": [{"picture_base64": "eA=="}],
        }
    )
    catalog = Catalog([movie])

    with pytest.raises(ValueError, match="picture-size limit"):
        write_native_catalog(
            catalog,
            tmp_path / "picture.amc",
            limits=NativeWriteLimits(max_picture_bytes=2),
        )
    with pytest.raises(ValueError, match="cumulative picture-size limit"):
        write_native_catalog(
            catalog,
            tmp_path / "pictures.amc",
            limits=NativeWriteLimits(max_total_picture_bytes=3),
        )
    with pytest.raises(ValueError, match="supplementary-record limit"):
        write_native_catalog(
            catalog,
            tmp_path / "extras.amc",
            limits=NativeWriteLimits(max_extras_per_movie=0),
        )


def test_native_write_limits_validate_configuration():
    from amc.native import NativeWriteLimits

    with pytest.raises(ValueError, match="max_file_bytes"):
        NativeWriteLimits(max_file_bytes=-1)
    with pytest.raises(ValueError, match="max_movies"):
        NativeWriteLimits(max_movies=True)


@pytest.mark.parametrize(
    ("metadata", "message"),
    [
        ({"native": []}, "native metadata must be an object"),
        ({"native": {"custom_fields": {}}}, "custom_fields metadata must be a list"),
        ({"native": {"custom_fields": ["Mood"]}}, "custom field must be an object"),
        ({"native": {"custom_fields": [{"multi_values": 1}]}}, "must be a boolean"),
        (
            {"native": {"custom_fields": [{"field_type": "ftList", "list_values": "Calm"}]}},
            "list_values must be a list",
        ),
    ],
)
def test_native_writer_rejects_malformed_metadata_atomically(
    tmp_path: Path, metadata: dict[str, object], message: str
):
    from amc.catalog import Catalog
    from amc.native import write_native_catalog

    target = tmp_path / "metadata.amc"
    target.write_bytes(b"trusted")

    with pytest.raises(TypeError, match=message):
        write_native_catalog(Catalog(metadata=metadata), target)

    assert target.read_bytes() == b"trusted"
    assert not (tmp_path / ".metadata.amc.tmp").exists()


@pytest.mark.parametrize("value", ["5", True])
def test_native_writer_rejects_invalid_retained_user_rating_atomically(
    tmp_path: Path, value: object
):
    from amc.catalog import Catalog
    from amc.model import Movie
    from amc.native import write_native_catalog

    target = tmp_path / "rating.amc"
    target.write_bytes(b"trusted")

    with pytest.raises((TypeError, ValueError), match="native_user_rating"):
        write_native_catalog(Catalog([Movie(extras={"native_user_rating": value})]), target)

    assert target.read_bytes() == b"trusted"


def test_native_writer_reports_unencodable_custom_separator(tmp_path: Path):
    from amc.catalog import Catalog
    from amc.native import write_native_catalog

    catalog = Catalog(
        metadata={
            "native": {
                "custom_fields": [
                    {
                        "tag": "Mood",
                        "multi_value_separator": "☃",
                    }
                ]
            }
        }
    )

    with pytest.raises(ValueError, match="cannot encode native custom-field separator"):
        write_native_catalog(catalog, tmp_path / "separator.amc")
