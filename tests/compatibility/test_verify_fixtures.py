import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

from amc.catalog import Catalog
from amc.model import Movie
from amc.native import write_native_catalog


AMC_42_HEADER = " AMC_4.2 Ant Movie Catalog 4.2.x   antp/soulsnake    www.antp.be "


def verifier_environment() -> dict[str, str]:
    environment = os.environ.copy()
    environment["PYTHONPATH"] = str(Path("src").resolve())
    return environment


def test_verifier_checks_declared_native_version_and_movie_count(tmp_path: Path):
    fixture = tmp_path / "one.amc"
    write_native_catalog(Catalog([Movie(original_title="Alien")]), fixture)
    manifest = {
        "id": "synthetic-verifier-test",
        "origin": "synthetic",
        "format": "AMC native 4.2",
        "producer": "AMC Python test writer",
        "producer_version": "0.1.0",
        "created_at": "2026-08-14T00:00:00Z",
        "creation_steps": "Created by the test with write_native_catalog.",
        "provenance": "Ephemeral test output; not an upstream compatibility fixture.",
        "redistribution": "allowed",
        "expected_contents": "One synthetic movie named Alien.",
        "files": [
            {
                "path": fixture.name,
                "sha256": hashlib.sha256(fixture.read_bytes()).hexdigest(),
            }
        ],
        "verification": [
            {
                "path": fixture.name,
                "format": "amc-native",
                "header": AMC_42_HEADER,
                "version": "4.2",
                "movies": 1,
                "metadata": {"version": "4.2", "owner": ""},
                "movie_fields": [{"original_title": "Alien", "number": 1}],
            }
        ],
    }
    (tmp_path / "manifest.json").write_text(json.dumps(manifest), encoding="utf-8")

    result = subprocess.run(
        [sys.executable, "tools/verify_fixtures.py", str(tmp_path)],
        text=True,
        capture_output=True,
        check=False,
        env=verifier_environment(),
    )

    assert (result.returncode, result.stdout.strip()) == (
        0,
        "Verified 1 native fixture expectation(s)",
    )


def test_verifier_reports_missing_expectations(tmp_path: Path):
    result = subprocess.run(
        [
            sys.executable,
            "tools/verify_fixtures.py",
            str(tmp_path),
            "--require-expectations",
        ],
        text=True,
        capture_output=True,
        check=False,
        env=verifier_environment(),
    )

    assert result.returncode == 1
    assert "no fixture verification expectations" in result.stderr
