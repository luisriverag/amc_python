"""Failure-path tests for atomic interchange writers."""

import csv
import os
import stat
from concurrent.futures import ThreadPoolExecutor
from threading import Barrier
import xml.etree.ElementTree as ET
from pathlib import Path

import pytest

from amc import Catalog, Movie
from amc.storage import copy_catalog, load, save, save_csv, save_html, save_xml


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


@pytest.mark.skipif(os.name == "nt", reason="Windows cannot fsync directory handles")
@pytest.mark.parametrize(
    ("writer", "suffix"),
    [(save, ".json"), (save_csv, ".csv"), (save_xml, ".xml"), (save_html, ".html")],
)
def test_atomic_writer_fsyncs_destination_directory_entry(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, writer, suffix
):
    """A crash right after rename must not lose the rename on a durable filesystem,
    matching the directory-entry fsync the native writer already performs."""
    target = tmp_path / f"catalog{suffix}"
    original_fsync = os.fsync
    directory_syncs = 0

    def count_directory_syncs(descriptor: int) -> None:
        nonlocal directory_syncs
        if stat.S_ISDIR(os.fstat(descriptor).st_mode):
            directory_syncs += 1
        original_fsync(descriptor)

    monkeypatch.setattr("amc.native.os.fsync", count_directory_syncs)
    writer(Catalog([Movie(title="Alien")]), target)

    assert directory_syncs == 1


@pytest.mark.skipif(os.name == "nt", reason="Windows cannot fsync directory handles")
def test_copy_catalog_fsyncs_destination_directory_entry(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
):
    source = tmp_path / "source.json"
    destination = tmp_path / "destination.json"
    save(Catalog([Movie(title="Alien")]), source)
    original_fsync = os.fsync
    directory_syncs = 0

    def count_directory_syncs(descriptor: int) -> None:
        nonlocal directory_syncs
        if stat.S_ISDIR(os.fstat(descriptor).st_mode):
            directory_syncs += 1
        original_fsync(descriptor)

    monkeypatch.setattr("amc.native.os.fsync", count_directory_syncs)
    copy_catalog(source, destination)

    assert directory_syncs == 1


def test_concurrent_atomic_writers_use_independent_temporary_files(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
):
    """Two writers reaching replacement together must not clobber a shared temp file."""
    target = tmp_path / "catalog.json"
    barrier = Barrier(2)
    from amc import storage

    original_replace = storage.replace_and_sync_directory

    def replace_together(source: Path, destination: Path) -> None:
        barrier.wait(timeout=5)
        original_replace(source, destination)

    monkeypatch.setattr(storage, "replace_and_sync_directory", replace_together)
    catalogs = [Catalog([Movie(title="Alien")]), Catalog([Movie(title="Aliens")])]
    with ThreadPoolExecutor(max_workers=2) as executor:
        list(executor.map(lambda catalog: save(catalog, target), catalogs))

    assert list(load(target))[0].title in {"Alien", "Aliens"}
    assert not list(tmp_path.glob(".catalog.json.*.tmp"))


def test_atomic_writer_never_overwrites_or_removes_preexisting_staging_path(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
):
    """Even a UUID collision must not treat another writer's staging file as ours."""
    target = tmp_path / "catalog.json"
    target.write_text('{"version": 1, "movies": []}', encoding="utf-8")
    staging = tmp_path / ".catalog.json.forced.tmp"
    staging.write_bytes(b"another writer")
    monkeypatch.setattr("amc.storage.unique_temporary_path", lambda _path: staging)

    with pytest.raises(FileExistsError):
        save(Catalog([Movie(title="Alien")]), target)

    assert staging.read_bytes() == b"another writer"
    assert len(load(target)) == 0


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


@pytest.mark.parametrize(
    ("writer", "suffix"),
    [(save, ".json"), (save_csv, ".csv"), (save_xml, ".xml"), (save_html, ".html")],
)
def test_atomic_writer_preserves_destination_when_parent_directory_denies_access(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, writer, suffix
):
    """A read-only or permission-denied destination directory must propagate an
    unwrapped OSError/PermissionError and leave any existing destination and
    temp-file state exactly as it was — the same documented, undecorated
    diagnostic shape as every other atomic-writer failure in the package."""
    target = tmp_path / f"catalog{suffix}"
    target.write_text("previous contents", encoding="utf-8")

    def deny(_self, **_kwargs):
        raise PermissionError("injected permission denial creating parent directory")

    monkeypatch.setattr(Path, "mkdir", deny)
    with pytest.raises(PermissionError, match="injected permission denial"):
        writer(Catalog([Movie(title="Alien")]), target)

    assert target.read_text(encoding="utf-8") == "previous contents"
    assert not target.with_name(f".{target.name}.tmp").exists()


@pytest.mark.parametrize(
    ("writer", "suffix"),
    [(save, ".json"), (save_csv, ".csv"), (save_xml, ".xml"), (save_html, ".html")],
)
def test_atomic_writer_preserves_destination_when_temp_file_creation_is_denied(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, writer, suffix
):
    """A directory that permits mkdir/exist_ok but denies file creation (a
    read-only directory that already exists) must behave the same way: an
    unwrapped PermissionError, an untouched destination, and no temp-file
    debris — open() never got far enough to create one."""
    target = tmp_path / f"catalog{suffix}"
    target.write_text("previous contents", encoding="utf-8")
    original_open = Path.open

    def deny_temp_file(self: Path, *args: object, **kwargs: object):
        if self.name.startswith("."):
            raise PermissionError("injected permission denial creating temp file")
        return original_open(self, *args, **kwargs)

    monkeypatch.setattr(Path, "open", deny_temp_file)
    with pytest.raises(PermissionError, match="injected permission denial"):
        writer(Catalog([Movie(title="Alien")]), target)

    assert target.read_text(encoding="utf-8") == "previous contents"
    assert not target.with_name(f".{target.name}.tmp").exists()


def test_native_writer_preserves_destination_when_parent_directory_denies_access(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
):
    from amc.native import write_native_catalog

    target = tmp_path / "catalog.amc"
    target.write_bytes(b"previous catalog")

    def deny(_self, **_kwargs):
        raise PermissionError("injected permission denial creating parent directory")

    monkeypatch.setattr(Path, "mkdir", deny)
    with pytest.raises(PermissionError, match="injected permission denial"):
        write_native_catalog(Catalog(), target)

    assert target.read_bytes() == b"previous catalog"
    assert not target.with_name(f".{target.name}.tmp").exists()


def test_copy_catalog_preserves_destination_when_parent_directory_denies_access(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
):
    source = tmp_path / "source.json"
    destination = tmp_path / "sub" / "destination.json"
    save(Catalog([Movie(title="Alien")]), source)

    def deny(_self, **_kwargs):
        raise PermissionError("injected permission denial creating parent directory")

    monkeypatch.setattr(Path, "mkdir", deny)
    with pytest.raises(PermissionError, match="injected permission denial"):
        copy_catalog(source, destination)

    assert not destination.exists()
    assert not destination.with_name(f".{destination.name}.tmp").exists()
