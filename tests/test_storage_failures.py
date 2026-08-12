"""Failure-path tests for atomic interchange writers."""

import csv
import xml.etree.ElementTree as ET
from pathlib import Path

import pytest

from amc import Catalog, Movie
from amc.storage import save_csv, save_xml


@pytest.mark.parametrize("writer", [save_csv, save_xml])
def test_interchange_writer_preserves_destination_on_serialization_failure(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, writer
):
    """A codec failure must not replace or leave debris beside the destination."""
    suffix = ".csv" if writer is save_csv else ".xml"
    target = tmp_path / f"catalog{suffix}"
    target.write_text("previous contents", encoding="utf-8")

    if writer is save_csv:
        def fail(_self, _row):
            raise RuntimeError("injected CSV serialization failure")

        monkeypatch.setattr(csv.DictWriter, "writerow", fail)
    else:
        def fail(_self, _file, **_kwargs):
            raise RuntimeError("injected XML serialization failure")

        monkeypatch.setattr(ET.ElementTree, "write", fail)

    with pytest.raises(RuntimeError, match="injected .* serialization failure"):
        writer(Catalog([Movie(title="Alien")]), target)

    assert target.read_text(encoding="utf-8") == "previous contents"
    assert not target.with_name(f".{target.name}.tmp").exists()


def test_interchange_writer_creates_no_destination_on_failure(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
):
    target = tmp_path / "new.xml"

    def fail(_self, _file, **_kwargs):
        raise RuntimeError("injected XML serialization failure")

    monkeypatch.setattr(ET.ElementTree, "write", fail)
    with pytest.raises(RuntimeError, match="injected XML serialization failure"):
        save_xml(Catalog([Movie(title="Alien")]), target)

    assert not target.exists()
    assert not target.with_name(f".{target.name}.tmp").exists()


def test_atomic_writer_preserves_destination_when_replace_fails(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
):
    target = tmp_path / "catalog.csv"
    target.write_text("previous contents", encoding="utf-8")

    def fail(_self, _target):
        raise OSError("injected replacement failure")

    monkeypatch.setattr(Path, "replace", fail)
    with pytest.raises(OSError, match="injected replacement failure"):
        save_csv(Catalog([Movie(title="Alien")]), target)

    assert target.read_text(encoding="utf-8") == "previous contents"
    assert not target.with_name(f".{target.name}.tmp").exists()
