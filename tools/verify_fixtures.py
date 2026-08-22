#!/usr/bin/env python3
"""Verify declared native-catalog facts for compatibility fixtures."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from amc.inspection import inspect_catalog
from amc.native import NATIVE_HEADER_SIZE, read_native_catalog
from amc.storage import load

from validate_fixtures import ManifestError, validate_manifest


def verify_directory(root: Path, *, require_expectations: bool = False) -> int:
    """Verify every manifest expectation below *root* and return its count."""
    count = 0
    for manifest in sorted(root.rglob("manifest.json")) if root.exists() else []:
        document = validate_manifest(manifest)
        expectations = document.get("verification", [])
        if not isinstance(expectations, list):
            raise ManifestError(f"{manifest}: verification must be an array")
        for entry in expectations:
            fixture = manifest.parent / str(entry["path"])
            actual_header = fixture.read_bytes()[:NATIVE_HEADER_SIZE]
            expected_header = entry["header"].encode("ascii")
            if actual_header != expected_header:
                raise ManifestError(f"{fixture}: native header does not match declared bytes")
            info = inspect_catalog(fixture)
            if info.format != entry["format"]:
                raise ManifestError(
                    f"{fixture}: expected format {entry['format']}, got {info.format}"
                )
            if str(info.version) != entry["version"]:
                raise ManifestError(
                    f"{fixture}: expected version {entry['version']}, got {info.version}"
                )
            movies = len(read_native_catalog(fixture).movies)
            if movies != entry["movies"]:
                raise ManifestError(f"{fixture}: expected {entry['movies']} movie(s), got {movies}")
            converted = load(fixture)
            native_metadata = converted.metadata.get("native", {})
            if not isinstance(native_metadata, dict):
                native_metadata = {}
            for field, expected in entry.get("metadata", {}).items():
                actual = native_metadata.get(field)
                if actual != expected:
                    raise ManifestError(
                        f"{fixture}: metadata {field!r} expected {expected!r}, got {actual!r}"
                    )
            converted_movies = list(converted)
            for index, expected_fields in enumerate(entry.get("movie_fields", [])):
                actual_fields = converted_movies[index].to_dict()
                for field, expected in expected_fields.items():
                    if field not in actual_fields:
                        raise ManifestError(f"{fixture}: movie {index} has unknown field {field!r}")
                    actual = actual_fields[field]
                    if actual != expected:
                        raise ManifestError(
                            f"{fixture}: movie {index} field {field!r} expected "
                            f"{expected!r}, got {actual!r}"
                        )
            count += 1
    if require_expectations and not count:
        raise ManifestError(f"{root}: no fixture verification expectations found")
    return count


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description=__doc__)
    result.add_argument("root", nargs="?", type=Path, default=Path("tests/fixtures"))
    result.add_argument("--require-expectations", action="store_true")
    return result


def main(argv: list[str] | None = None) -> int:
    args = parser().parse_args(argv)
    try:
        count = verify_directory(args.root, require_expectations=args.require_expectations)
    except (ManifestError, OSError, ValueError) as error:
        print(error, file=sys.stderr)
        return 1
    print(f"Verified {count} native fixture expectation(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
