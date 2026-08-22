import hashlib
import importlib.util
import json
from pathlib import Path


SPEC = importlib.util.spec_from_file_location(
    "validate_fixtures", Path("tools/validate_fixtures.py")
)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
SPEC.loader.exec_module(MODULE)


def manifest_for(name, digest):
    return {
        "id": "amc-4.2.3.2-empty",
        "origin": "upstream-generated",
        "format": "AMC native 4.2",
        "producer": "Ant Movie Catalog",
        "producer_version": "4.2.3.2",
        "created_at": "2026-08-12T00:00:00Z",
        "creation_steps": "Save a new empty catalog.",
        "provenance": "Created using an authenticated upstream installation.",
        "redistribution": "allowed",
        "expected_contents": "No movie records.",
        "files": [{"path": name, "sha256": digest}],
    }


def write_manifest(directory, document):
    directory.mkdir(parents=True, exist_ok=True)
    path = directory / "manifest.json"
    path.write_text(json.dumps(document), encoding="utf-8")
    return path


def test_validate_manifest_accepts_matching_fixture(tmp_path):
    payload = b"AMC_4.2 Ant Movie Catalog 4.2.x www.antp.be"
    (tmp_path / "empty.amc").write_bytes(payload)
    path = write_manifest(tmp_path, manifest_for("empty.amc", hashlib.sha256(payload).hexdigest()))
    assert MODULE.validate_manifest(path)["producer_version"] == "4.2.3.2"


def test_validate_manifest_requires_exact_native_header_expectation(tmp_path):
    payload = b" AMC_4.2 Ant Movie Catalog 4.2.x   antp/soulsnake    www.antp.be "
    (tmp_path / "empty.amc").write_bytes(payload)
    document = manifest_for("empty.amc", hashlib.sha256(payload).hexdigest())
    document["verification"] = [
        {
            "path": "empty.amc",
            "format": "amc-native",
            "header": "AMC 4.2",
            "version": "4.2",
            "movies": 0,
        }
    ]
    path = write_manifest(tmp_path, document)

    try:
        MODULE.validate_manifest(path)
    except MODULE.ManifestError as error:
        assert "65-byte ASCII AMC header" in str(error)
    else:
        raise AssertionError("accepted an abbreviated native header expectation")


def test_validate_manifest_rejects_digest_mismatch(tmp_path):
    (tmp_path / "empty.amc").write_bytes(b"changed")
    path = write_manifest(tmp_path, manifest_for("empty.amc", "0" * 64))
    try:
        MODULE.validate_manifest(path)
    except MODULE.ManifestError as error:
        assert "sha256 mismatch" in str(error)
    else:
        raise AssertionError("accepted a fixture with the wrong digest")


def test_validate_manifest_rejects_path_escape(tmp_path):
    path = write_manifest(tmp_path, manifest_for("../outside.amc", "0" * 64))
    try:
        MODULE.validate_manifest(path)
    except MODULE.ManifestError as error:
        assert "safe relative path" in str(error)
    else:
        raise AssertionError("accepted an escaping fixture path")


def test_upstream_fixture_requires_redistribution_decision(tmp_path):
    document = manifest_for("empty.amc", "0" * 64)
    document["redistribution"] = "unknown"
    path = write_manifest(tmp_path, document)
    try:
        MODULE.validate_manifest(path)
    except MODULE.ManifestError as error:
        assert "require a redistribution decision" in str(error)
    else:
        raise AssertionError("accepted unresolved upstream redistribution")


def test_directory_rejects_duplicate_ids(tmp_path):
    payload = b"catalog"
    digest = hashlib.sha256(payload).hexdigest()
    for name in ("one", "two"):
        directory = tmp_path / name
        directory.mkdir()
        (directory / "catalog.amc").write_bytes(payload)
        write_manifest(directory, manifest_for("catalog.amc", digest))
    try:
        MODULE.validate_directory(tmp_path)
    except MODULE.ManifestError as error:
        assert "duplicate id" in str(error)
    else:
        raise AssertionError("accepted duplicate fixture identifiers")


def test_main_can_require_at_least_one_manifest(tmp_path, capsys):
    assert MODULE.main([str(tmp_path), "--require-manifests"]) == 1
    assert "no manifest.json files found" in capsys.readouterr().err
