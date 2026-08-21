import hashlib
import importlib.util
import json
import threading
import zipfile
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

import pytest


SPEC = importlib.util.spec_from_file_location("acquire_upstream", Path("tools/acquire_upstream.py"))
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
SPEC.loader.exec_module(MODULE)


def test_download_streams_archive_and_records_provenance(tmp_path: Path):
    payload = b"Rar! synthetic test payload"

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            self.send_response(200)
            self.end_headers()
            self.wfile.write(payload)

        def log_message(self, *_args):
            pass

    server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
    thread = threading.Thread(target=server.serve_forever)
    thread.start()
    try:
        destination = tmp_path / "source.rar"
        result = MODULE.download(f"http://127.0.0.1:{server.server_port}/source.rar", destination)
    finally:
        server.shutdown()
        thread.join()
        server.server_close()

    assert destination.read_bytes() == payload
    assert result["size"] == len(payload)
    assert result["sha256"] == hashlib.sha256(payload).hexdigest()
    assert not (tmp_path / "source.rar.part").exists()


def test_download_rejects_wrong_digest_without_replacing_archive(tmp_path: Path):
    source = tmp_path / "source.rar"
    source.write_bytes(b"new archive")
    destination = tmp_path / "archive.rar"
    destination.write_bytes(b"trusted archive")

    try:
        MODULE.download(source.as_uri(), destination, "0" * 64)
    except ValueError as error:
        assert "archive SHA-256 mismatch" in str(error)
    else:
        raise AssertionError("download accepted the wrong digest")

    assert destination.read_bytes() == b"trusted archive"
    assert not (tmp_path / "archive.rar.part").exists()


def test_download_accepts_expected_digest_case_insensitively(tmp_path: Path):
    payload = b"verified archive"
    source = tmp_path / "source.rar"
    source.write_bytes(payload)
    expected = hashlib.sha256(payload).hexdigest().upper()

    result = MODULE.download(source.as_uri(), tmp_path / "archive.rar", expected)

    assert result["sha256"] == expected.lower()


def test_inventory_is_sorted_and_content_addressed(tmp_path: Path):
    (tmp_path / "z.pas").write_text("unit Z;", encoding="utf-8")
    (tmp_path / "dir").mkdir()
    (tmp_path / "dir" / "a.dfm").write_text("object A", encoding="utf-8")
    entries = MODULE.inventory(tmp_path)
    assert [entry["path"] for entry in entries] == ["dir/a.dfm", "z.pas"]
    assert all(len(entry["sha256"]) == 64 for entry in entries)


def test_extract_zip_and_strip_wrapper_directory(tmp_path: Path):
    archive = tmp_path / "source.zip"
    with zipfile.ZipFile(archive, "w") as stream:
        stream.writestr("wrapper/unit.pas", "unit Example;")
    destination = tmp_path / "expanded"

    assert MODULE.extract(archive, destination) == "zipfile"
    root = MODULE.comparison_root(destination, True)

    assert root == destination / "wrapper"
    assert MODULE.inventory(root)[0]["path"] == "unit.pas"


def test_extract_zip_rejects_path_traversal(tmp_path: Path):
    archive = tmp_path / "unsafe.zip"
    with zipfile.ZipFile(archive, "w") as stream:
        stream.writestr("../escaped.pas", "unit Escaped;")

    with pytest.raises(ValueError, match="escapes extraction directory"):
        MODULE.extract(archive, tmp_path / "expanded")

    assert not (tmp_path / "escaped.pas").exists()


def test_extract_rar_tries_next_available_tool_after_failure(tmp_path: Path, monkeypatch):
    archive = tmp_path / "source.rar"
    archive.write_bytes(b"not a zip")
    calls = []

    monkeypatch.setattr(MODULE.shutil, "which", lambda executable: f"/bin/{executable}")

    def run(command, *, check):
        calls.append(command[0])
        if command[0] == "unrar":
            raise MODULE.subprocess.CalledProcessError(2, command)

    monkeypatch.setattr(MODULE.subprocess, "run", run)

    assert MODULE.extract(archive, tmp_path / "expanded") == "unar"
    assert calls == ["unrar", "unar"]


def test_extract_rar_reports_all_available_tool_failures(tmp_path: Path, monkeypatch):
    archive = tmp_path / "source.rar"
    archive.write_bytes(b"not a zip")
    monkeypatch.setattr(
        MODULE.shutil, "which", lambda executable: f"/bin/{executable}"
    )

    def fail(command, *, check):
        raise MODULE.subprocess.CalledProcessError(2, command)

    monkeypatch.setattr(MODULE.subprocess, "run", fail)

    with pytest.raises(RuntimeError, match="unrar exited.*bsdtar exited"):
        MODULE.extract(archive, tmp_path / "expanded")


def test_strip_root_requires_one_wrapper_directory(tmp_path: Path):
    (tmp_path / "one").mkdir()
    (tmp_path / "two").mkdir()

    with pytest.raises(ValueError, match="exactly one top-level directory"):
        MODULE.comparison_root(tmp_path, True)


def test_compare_inventories_reports_every_difference(tmp_path: Path):
    acquired = tmp_path / "acquired"
    snapshot = tmp_path / "snapshot"
    acquired.mkdir()
    snapshot.mkdir()
    (acquired / "same.pas").write_text("same", encoding="utf-8")
    (snapshot / "same.pas").write_text("same", encoding="utf-8")
    (acquired / "changed.pas").write_text("upstream", encoding="utf-8")
    (snapshot / "changed.pas").write_text("snapshot", encoding="utf-8")
    (acquired / "missing.pas").write_text("missing", encoding="utf-8")
    (snapshot / "extra.pas").write_text("extra", encoding="utf-8")

    result = MODULE.compare_inventories(
        MODULE.inventory(acquired), MODULE.inventory(snapshot)
    )

    assert result == {
        "equivalent": False,
        "matched": ["same.pas"],
        "changed": ["changed.pas"],
        "missing_from_snapshot": ["missing.pas"],
        "unexpected_in_snapshot": ["extra.pas"],
    }


def test_compare_inventories_identifies_equivalent_trees(tmp_path: Path):
    (tmp_path / "unit.pas").write_text("unit Example;", encoding="utf-8")
    entries = MODULE.inventory(tmp_path)
    result = MODULE.compare_inventories(entries, entries)
    assert result["equivalent"] is True
    assert result["matched"] == ["unit.pas"]


def test_compare_to_requires_extraction_directory(tmp_path: Path):
    source = tmp_path / "source.rar"
    source.write_bytes(b"archive")
    try:
        MODULE.main(["--url", source.as_uri(), "--compare-to", str(tmp_path)])
    except ValueError as error:
        assert str(error) == "--compare-to requires --extract-to"
    else:
        raise AssertionError("main accepted a comparison without extraction")


def test_strip_root_requires_extraction_directory(tmp_path: Path):
    source = tmp_path / "source.zip"
    source.write_bytes(b"archive")

    with pytest.raises(ValueError, match="--strip-root requires --extract-to"):
        MODULE.main(["--url", source.as_uri(), "--strip-root"])


def test_main_compares_zip_inside_wrapper_directory(tmp_path: Path):
    source = tmp_path / "source.zip"
    with zipfile.ZipFile(source, "w") as stream:
        stream.writestr("wrapper/unit.pas", "unit Example;")
    snapshot = tmp_path / "snapshot"
    snapshot.mkdir()
    (snapshot / "unit.pas").write_text("unit Example;", encoding="utf-8")
    comparison = tmp_path / "comparison.json"

    assert MODULE.main([
        "--url", source.as_uri(),
        "--output", str(tmp_path / "copy.zip"),
        "--extract-to", str(tmp_path / "expanded"),
        "--strip-root",
        "--compare-to", str(snapshot),
        "--comparison", str(comparison),
        "--metadata", str(tmp_path / "archive.json"),
        "--inventory", str(tmp_path / "inventory.json"),
    ]) == 0

    result = json.loads(comparison.read_text(encoding="utf-8"))
    assert result["equivalent"] is True
    assert result["matched"] == ["unit.pas"]


def test_main_rejects_invalid_expected_digest_before_download(tmp_path: Path):
    destination = tmp_path / "archive.rar"
    try:
        MODULE.main([
            "--url",
            (tmp_path / "missing.rar").as_uri(),
            "--output",
            str(destination),
            "--expected-sha256",
            "not-a-digest",
        ])
    except ValueError as error:
        assert str(error) == (
            "--expected-sha256 must be exactly 64 hexadecimal characters"
        )
    else:
        raise AssertionError("main accepted an invalid digest")
    assert not destination.exists()


def test_main_writes_machine_readable_archive_metadata(tmp_path: Path):
    source = tmp_path / "source.rar"
    source.write_bytes(b"archive")
    metadata = tmp_path / "archive.json"
    assert MODULE.main(["--url", source.as_uri(), "--output", str(tmp_path / "copy.rar"), "--metadata", str(metadata)]) == 0
    document = json.loads(metadata.read_text(encoding="utf-8"))
    assert document["url"] == source.as_uri()
    assert document["archive"] == "copy.rar"
