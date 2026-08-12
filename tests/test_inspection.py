import json
from pathlib import Path

import pytest

from amc.cli import main
from amc.errors import CorruptCatalogError, UnsupportedFormatError, UnsupportedVersionError
from amc.inspection import inspect_catalog, validate_catalog


def test_inspect_json_xml_and_csv(tmp_path: Path):
    json_path = tmp_path / "catalog.data"
    json_path.write_text('{"format":"amc-python","version":1,"movies":[{},{}]}', encoding="utf-8")
    assert inspect_catalog(json_path).to_dict() | {"path": "ignored", "size": 0} == {
        "path": "ignored", "format": "amc-python", "version": 1, "movies": 2, "size": 0,
    }

    xml_path = tmp_path / "catalog.xml"
    xml_path.write_text('<AntMovieCatalog Format="4.2"><Catalog><Movie/><Movie/></Catalog></AntMovieCatalog>', encoding="utf-8")
    assert (inspect_catalog(xml_path).format, inspect_catalog(xml_path).version, inspect_catalog(xml_path).movies) == ("amc-xml", "4.2", 2)

    csv_path = tmp_path / "catalog.csv"
    csv_path.write_text("Title,Year\nAlien,1979\n\nAliens,1986\n", encoding="utf-8")
    assert (inspect_catalog(csv_path).format, inspect_catalog(csv_path).movies) == ("csv", 2)


def test_inspection_rejects_corrupt_unknown_future_and_native(tmp_path: Path):
    malformed = tmp_path / "broken.json"
    malformed.write_text("{", encoding="utf-8")
    with pytest.raises(CorruptCatalogError):
        inspect_catalog(malformed)

    unknown = tmp_path / "unknown.bin"
    unknown.write_bytes(b"not a catalog")
    with pytest.raises(UnsupportedFormatError):
        inspect_catalog(unknown)

    future = tmp_path / "future.json"
    future.write_text('{"format":"amc-python","version":2,"movies":[]}', encoding="utf-8")
    with pytest.raises(UnsupportedVersionError):
        inspect_catalog(future)

    native = tmp_path / "native.amc"
    native.write_bytes(b"not actually a native catalog")
    with pytest.raises(UnsupportedFormatError, match="recognized native AMC header"):
        inspect_catalog(native)


def test_cli_inspect_json_output(tmp_path: Path, capsys):
    target = tmp_path / "catalog.json"
    target.write_text("[]", encoding="utf-8")
    assert main(["inspect", str(target), "--json"]) == 0
    output = json.loads(capsys.readouterr().out)
    assert (output["format"], output["movies"], output["size"]) == ("json", 0, 2)


def test_validation_returns_stable_diagnostics(tmp_path: Path):
    valid = tmp_path / "valid.json"
    valid.write_text("[]", encoding="utf-8")
    assert validate_catalog(valid)[0].code == "catalog_valid"
    assert validate_catalog(valid)[0].severity == "info"

    broken = tmp_path / "broken.json"
    broken.write_text("{", encoding="utf-8")
    diagnostic = validate_catalog(broken)[0]
    assert (diagnostic.code, diagnostic.severity, diagnostic.offset) == ("corrupt_catalog", "error", 1)

    missing = validate_catalog(tmp_path / "missing.json")[0]
    assert missing.code == "io_error"


def test_cli_validate_exit_codes_and_json(tmp_path: Path, capsys):
    valid = tmp_path / "valid.csv"
    valid.write_text("Title\nAlien\n", encoding="utf-8")
    assert main(["validate", str(valid), "--json"]) == 0
    assert json.loads(capsys.readouterr().out)[0]["code"] == "catalog_valid"

    broken = tmp_path / "broken.json"
    broken.write_text("{", encoding="utf-8")
    assert main(["validate", str(broken)]) == 1
    assert "ERROR corrupt_catalog at byte 1" in capsys.readouterr().out


_NATIVE_HEADERS = {
    "1.0": b" AMC_1.0 ANSYsoft Movie Catalog http://moviecatalog.ansysoft.com ",
    "1.1": b" AMC_1.1 ANSYsoft Movie Catalog http://moviecatalog.ansysoft.com ",
    "2.1": b" AMC_2.1 ANSYsoft Movie Catalog http://moviecatalog.ansysoft.com ",
    "3.0": b" AMC_3.0 Ant Movie Catalog www.buypin.com www.ant.be.tf/software ",
    "3.1": b" AMC_3.1 Ant Movie Catalog 3.1.x   www.buypin.com  www.ant.be.tf ",
    "3.3": b" AMC_3.3 Ant Movie Catalog 3.3.x   www.buypin.com  www.ant.be.tf ",
    "3.5": b" AMC_3.5 Ant Movie Catalog 3.5.x   www.buypin.com    www.antp.be ",
    "4.0": b" AMC_4.0 Ant Movie Catalog 4.0.x   antp/soulsnake    www.antp.be ",
    "4.1": b" AMC_4.1 Ant Movie Catalog 4.1.x   antp/soulsnake    www.antp.be ",
    "4.2": b" AMC_4.2 Ant Movie Catalog 4.2.x   antp/soulsnake    www.antp.be ",
}


@pytest.mark.parametrize(("version", "header"), _NATIVE_HEADERS.items())
def test_inspect_recognizes_source_derived_native_headers(
    tmp_path: Path, version: str, header: bytes
):
    target = tmp_path / f"catalog-{version}.bin"
    target.write_bytes(header)

    info = inspect_catalog(target)

    assert (info.format, info.version, info.movies, info.size) == (
        "amc-native", version, None, len(header)
    )


def test_native_inspection_rejects_truncated_unknown_and_false_extension(tmp_path: Path):
    truncated = tmp_path / "truncated.amc"
    truncated.write_bytes(b" AMC_4.2")
    with pytest.raises(CorruptCatalogError, match="truncated native AMC header") as caught:
        inspect_catalog(truncated)
    assert caught.value.offset == len(b" AMC_4.2")

    future = tmp_path / "future.amc"
    future.write_bytes(b" AMC_9.9 " + b"x" * 56)
    with pytest.raises(UnsupportedVersionError, match="9.9"):
        inspect_catalog(future)

    false_extension = tmp_path / "not-native.amc"
    false_extension.write_bytes(b"not a catalog")
    with pytest.raises(UnsupportedFormatError, match="recognized native AMC header"):
        inspect_catalog(false_extension)


def test_native_validation_reports_source_verification_warning(tmp_path: Path):
    target = tmp_path / "catalog.amc"
    target.write_bytes(
        _NATIVE_HEADERS["4.2"]
        + b"\x00\x00\x00\x00" * 7
    )

    diagnostic = validate_catalog(target)[0]

    assert (diagnostic.code, diagnostic.severity, diagnostic.offset) == (
        "native_structure_unverified", "warning", None
    )
    assert "upstream-fixture verification is pending" in diagnostic.message


def test_cli_inspect_native_header_json(tmp_path: Path, capsys):
    target = tmp_path / "catalog.amc"
    target.write_bytes(_NATIVE_HEADERS["4.2"] + b"\x00\x00\x00\x00" * 7)

    assert main(["inspect", str(target), "--json"]) == 0
    output = json.loads(capsys.readouterr().out)
    assert (output["format"], output["version"], output["movies"]) == (
        "amc-native", "4.2", None
    )


def test_native_validation_returns_corruption_diagnostic_instead_of_raising(tmp_path: Path):
    target = tmp_path / "broken.amc"
    target.write_bytes(_NATIVE_HEADERS["4.2"] + b"\x00\x00")

    diagnostic = validate_catalog(target)[0]

    assert (diagnostic.code, diagnostic.severity, diagnostic.offset) == (
        "corrupt_catalog", "error", 65
    )
    assert "truncated native string length" in diagnostic.message
