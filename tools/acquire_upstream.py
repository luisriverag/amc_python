#!/usr/bin/env python3
"""Acquire and inventory the upstream AMC source archive reproducibly."""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import subprocess
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

DEFAULT_URL = "https://update.antp.be/amc/amc_sources.rar"
CHUNK_SIZE = 1024 * 1024


def download(
    url: str, destination: Path, expected_sha256: str | None = None
) -> dict[str, object]:
    """Stream *url* to a temporary file and atomically install it."""
    destination.parent.mkdir(parents=True, exist_ok=True)
    temporary = destination.with_suffix(destination.suffix + ".part")
    digest = hashlib.sha256()
    size = 0
    request = urllib.request.Request(url, headers={"User-Agent": "amc-python-source-acquirer/1"})
    try:
        with urllib.request.urlopen(request, timeout=60) as response, temporary.open("wb") as stream:
            while chunk := response.read(CHUNK_SIZE):
                stream.write(chunk)
                digest.update(chunk)
                size += len(chunk)
        actual_sha256 = digest.hexdigest()
        if expected_sha256 and actual_sha256 != expected_sha256.lower():
            raise ValueError(
                f"archive SHA-256 mismatch: expected {expected_sha256.lower()}, "
                f"got {actual_sha256}"
            )
        temporary.replace(destination)
    finally:
        temporary.unlink(missing_ok=True)
    return {
        "url": url,
        "retrieved_at": datetime.now(timezone.utc).isoformat(),
        "size": size,
        "sha256": actual_sha256,
        "archive": destination.name,
    }


def extract(archive: Path, destination: Path) -> str:
    """Extract with the first available supported RAR program."""
    destination.mkdir(parents=True, exist_ok=True)
    commands = (
        ("unrar", ["unrar", "x", "-o+", str(archive), str(destination)]),
        ("7z", ["7z", "x", "-y", f"-o{destination}", str(archive)]),
        ("bsdtar", ["bsdtar", "-xf", str(archive), "-C", str(destination)]),
    )
    for executable, command in commands:
        if shutil.which(executable):
            subprocess.run(command, check=True)
            return executable
    raise RuntimeError("RAR extraction requires unrar, 7z, or bsdtar")


def inventory(root: Path) -> list[dict[str, object]]:
    """Return deterministic file metadata without interpreting upstream source."""
    entries = []
    for path in sorted(item for item in root.rglob("*") if item.is_file()):
        data = path.read_bytes()
        entries.append({
            "path": path.relative_to(root).as_posix(),
            "size": len(data),
            "sha256": hashlib.sha256(data).hexdigest(),
        })
    return entries


def compare_inventories(
    acquired: list[dict[str, object]], snapshot: list[dict[str, object]]
) -> dict[str, object]:
    """Compare an acquired tree with a snapshot without claiming equivalence."""
    acquired_by_path = {str(entry["path"]): entry for entry in acquired}
    snapshot_by_path = {str(entry["path"]): entry for entry in snapshot}
    acquired_paths = set(acquired_by_path)
    snapshot_paths = set(snapshot_by_path)
    shared_paths = acquired_paths & snapshot_paths
    changed = sorted(
        path
        for path in shared_paths
        if acquired_by_path[path]["sha256"] != snapshot_by_path[path]["sha256"]
    )
    matched = sorted(shared_paths - set(changed))
    return {
        "equivalent": not changed and acquired_paths == snapshot_paths,
        "matched": matched,
        "changed": changed,
        "missing_from_snapshot": sorted(acquired_paths - snapshot_paths),
        "unexpected_in_snapshot": sorted(snapshot_paths - acquired_paths),
    }


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description=__doc__)
    result.add_argument("--url", default=DEFAULT_URL)
    result.add_argument(
        "--expected-sha256",
        type=str.lower,
        help="reject the download unless it has this SHA-256 digest",
    )
    result.add_argument("--output", type=Path, default=Path("upstream/amc_sources.rar"))
    result.add_argument("--extract-to", type=Path)
    result.add_argument("--metadata", type=Path, default=Path("upstream/archive.json"))
    result.add_argument("--inventory", type=Path, default=Path("upstream/inventory.json"))
    result.add_argument(
        "--compare-to",
        type=Path,
        help="compare the extracted archive with this checked-in snapshot tree",
    )
    result.add_argument(
        "--comparison",
        type=Path,
        default=Path("upstream/comparison.json"),
        help="where to write the machine-readable snapshot comparison",
    )
    return result


def main(argv: list[str] | None = None) -> int:
    args = parser().parse_args(argv)
    if args.compare_to and not args.extract_to:
        raise ValueError("--compare-to requires --extract-to")
    if args.expected_sha256 and (
        len(args.expected_sha256) != 64
        or any(character not in "0123456789abcdef" for character in args.expected_sha256)
    ):
        raise ValueError("--expected-sha256 must be exactly 64 hexadecimal characters")
    metadata = download(args.url, args.output, args.expected_sha256)
    if args.extract_to:
        metadata["extractor"] = extract(args.output, args.extract_to)
        files = inventory(args.extract_to)
        args.inventory.parent.mkdir(parents=True, exist_ok=True)
        args.inventory.write_text(json.dumps(files, indent=2) + "\n", encoding="utf-8")
        metadata["files"] = len(files)
        if args.compare_to:
            comparison = compare_inventories(files, inventory(args.compare_to))
            comparison["acquired_root"] = str(args.extract_to)
            comparison["snapshot_root"] = str(args.compare_to)
            args.comparison.parent.mkdir(parents=True, exist_ok=True)
            args.comparison.write_text(
                json.dumps(comparison, indent=2) + "\n", encoding="utf-8"
            )
            metadata["snapshot_equivalent"] = comparison["equivalent"]
    args.metadata.parent.mkdir(parents=True, exist_ok=True)
    args.metadata.write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8")
    print(f"Downloaded {metadata['size']} bytes; SHA-256 {metadata['sha256']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
