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
    native.write_bytes(b"unknown until upstream is available")
    with pytest.raises(UnsupportedVersionError, match="upstream-derived"):
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
