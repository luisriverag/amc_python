#!/usr/bin/env python3
"""Validate compatibility-fixture manifests and their content digests."""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path, PurePosixPath

REQUIRED_TEXT = (
    "id",
    "format",
    "producer",
    "producer_version",
    "created_at",
    "creation_steps",
    "provenance",
    "redistribution",
    "expected_contents",
)
REDISTRIBUTION_VALUES = {"allowed", "not-allowed", "unknown"}
ORIGIN_VALUES = {"upstream-generated", "synthetic", "mutated"}


class ManifestError(ValueError):
    """A fixture manifest is malformed or does not match its files."""


def _safe_relative_path(value: object, field: str) -> PurePosixPath:
    if not isinstance(value, str) or not value:
        raise ManifestError(f"{field} must be a non-empty relative path")
    path = PurePosixPath(value)
    if path.is_absolute() or ".." in path.parts or path == PurePosixPath("."):
        raise ManifestError(f"{field} must be a safe relative path")
    return path


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        while chunk := stream.read(1024 * 1024):
            digest.update(chunk)
    return digest.hexdigest()


def validate_manifest(path: Path) -> dict[str, object]:
    """Validate one manifest and return its decoded document."""
    try:
        document = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        raise ManifestError(f"{path}: cannot read JSON: {error}") from error
    if not isinstance(document, dict):
        raise ManifestError(f"{path}: manifest root must be an object")
    for field in REQUIRED_TEXT:
        if not isinstance(document.get(field), str) or not document[field].strip():
            raise ManifestError(f"{path}: {field} must be a non-empty string")
    origin = document.get("origin")
    if origin not in ORIGIN_VALUES:
        raise ManifestError(f"{path}: origin must be one of {sorted(ORIGIN_VALUES)}")
    redistribution = document["redistribution"]
    if redistribution not in REDISTRIBUTION_VALUES:
        raise ManifestError(
            f"{path}: redistribution must be one of {sorted(REDISTRIBUTION_VALUES)}"
        )
    if origin == "upstream-generated" and redistribution == "unknown":
        raise ManifestError(
            f"{path}: upstream-generated fixtures require a redistribution decision"
        )
    files = document.get("files")
    if not isinstance(files, list) or not files:
        raise ManifestError(f"{path}: files must be a non-empty array")
    seen: set[PurePosixPath] = set()
    for index, entry in enumerate(files):
        prefix = f"{path}: files[{index}]"
        if not isinstance(entry, dict):
            raise ManifestError(f"{prefix} must be an object")
        relative = _safe_relative_path(entry.get("path"), f"{prefix}.path")
        if relative in seen:
            raise ManifestError(f"{prefix}.path duplicates {relative}")
        seen.add(relative)
        expected = entry.get("sha256")
        if (
            not isinstance(expected, str)
            or len(expected) != 64
            or any(character not in "0123456789abcdef" for character in expected)
        ):
            raise ManifestError(f"{prefix}.sha256 must be 64 lowercase hex characters")
        fixture = path.parent / Path(*relative.parts)
        if not fixture.is_file():
            raise ManifestError(f"{prefix}.path does not exist: {relative}")
        actual = _sha256(fixture)
        if actual != expected:
            raise ManifestError(
                f"{prefix}.sha256 mismatch for {relative}: expected {expected}, got {actual}"
            )
    verification = document.get("verification", [])
    if not isinstance(verification, list):
        raise ManifestError(f"{path}: verification must be an array")
    file_names = {str(item) for item in seen}
    for index, entry in enumerate(verification):
        prefix = f"{path}: verification[{index}]"
        if not isinstance(entry, dict):
            raise ManifestError(f"{prefix} must be an object")
        relative = _safe_relative_path(entry.get("path"), f"{prefix}.path")
        if str(relative) not in file_names:
            raise ManifestError(f"{prefix}.path is not listed in files: {relative}")
        if entry.get("format") != "amc-native":
            raise ManifestError(f"{prefix}.format must be 'amc-native'")
        header = entry.get("header")
        if (
            not isinstance(header, str)
            or not header.isascii()
            or len(header.encode("ascii")) != 65
            or not header.startswith(" AMC_")
        ):
            raise ManifestError(f"{prefix}.header must be a 65-byte ASCII AMC header")
        if not isinstance(entry.get("version"), str) or not entry["version"]:
            raise ManifestError(f"{prefix}.version must be a non-empty string")
        movies = entry.get("movies")
        if isinstance(movies, bool) or not isinstance(movies, int) or movies < 0:
            raise ManifestError(f"{prefix}.movies must be a non-negative integer")
        metadata = entry.get("metadata", {})
        if not isinstance(metadata, dict) or any(
            not isinstance(key, str) or not isinstance(value, (str, int, bool, type(None)))
            for key, value in metadata.items()
        ):
            raise ManifestError(f"{prefix}.metadata must contain scalar expectations")
        movie_fields = entry.get("movie_fields", [])
        if not isinstance(movie_fields, list) or any(
            not isinstance(fields, dict)
            or any(
                not isinstance(key, str)
                or not isinstance(value, (str, int, float, bool, type(None)))
                for key, value in fields.items()
            )
            for fields in movie_fields
        ):
            raise ManifestError(f"{prefix}.movie_fields must be an array of scalar objects")
        if len(movie_fields) > movies:
            raise ManifestError(f"{prefix}.movie_fields exceeds declared movie count")
    return document


def validate_directory(root: Path, *, require_manifests: bool = False) -> int:
    """Validate all manifests below *root* and return their count."""
    manifests = sorted(root.rglob("manifest.json")) if root.exists() else []
    if require_manifests and not manifests:
        raise ManifestError(f"{root}: no manifest.json files found")
    identifiers: dict[str, Path] = {}
    for manifest in manifests:
        document = validate_manifest(manifest)
        identifier = str(document["id"])
        if identifier in identifiers:
            raise ManifestError(
                f"{manifest}: duplicate id {identifier!r}; first used by {identifiers[identifier]}"
            )
        identifiers[identifier] = manifest
    return len(manifests)


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description=__doc__)
    result.add_argument("root", nargs="?", type=Path, default=Path("tests/fixtures"))
    result.add_argument("--require-manifests", action="store_true")
    return result


def main(argv: list[str] | None = None) -> int:
    args = parser().parse_args(argv)
    try:
        count = validate_directory(args.root, require_manifests=args.require_manifests)
    except ManifestError as error:
        print(error, file=sys.stderr)
        return 1
    print(f"Validated {count} fixture manifest(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
