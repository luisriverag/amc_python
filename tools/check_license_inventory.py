#!/usr/bin/env python3
"""Verify that every retained third-party evidence file has an audit entry."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MANIFEST = ROOT / "docs/upstream/license-inventory.json"
TREES = (ROOT / "src/original/Common", ROOT / "src/antcomponents")


def validate() -> list[str]:
    """Return human-readable errors for an incomplete or stale inventory."""
    errors: list[str] = []
    data = json.loads(MANIFEST.read_text(encoding="utf-8"))
    entries = data.get("files")
    if not isinstance(entries, list):
        return ["files must be a list"]
    paths: list[str] = []
    for index, entry in enumerate(entries):
        if not isinstance(entry, dict):
            errors.append(f"files[{index}] must be an object")
            continue
        path = entry.get("path")
        status = entry.get("status")
        if not isinstance(path, str) or not path:
            errors.append(f"files[{index}].path must be a non-empty string")
            continue
        paths.append(path)
        if status not in {"notice", "companion", "unresolved"}:
            errors.append(f"{path}: invalid status {status!r}")
        if not isinstance(entry.get("basis"), str) or not entry["basis"].strip():
            errors.append(f"{path}: basis must be a non-empty string")

    if paths != sorted(paths):
        errors.append("files must be sorted by path")
    duplicates = sorted({path for path in paths if paths.count(path) > 1})
    if duplicates:
        errors.append(f"duplicate paths: {', '.join(duplicates)}")
    actual = {
        path.relative_to(ROOT).as_posix()
        for tree in TREES
        for path in tree.rglob("*")
        if path.is_file()
    }
    recorded = set(paths)
    if missing := sorted(actual - recorded):
        errors.append(f"unrecorded files: {', '.join(missing)}")
    if stale := sorted(recorded - actual):
        errors.append(f"missing files: {', '.join(stale)}")
    return errors


def main() -> int:
    """Print validation errors and return a command-line status."""
    errors = validate()
    if errors:
        for error in errors:
            print(f"license inventory: {error}")
        return 1
    print("license inventory: all retained Common and antcomponents files recorded")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
