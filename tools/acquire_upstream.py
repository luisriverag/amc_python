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


def download(url: str, destination: Path) -> dict[str, object]:
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
        temporary.replace(destination)
    finally:
        temporary.unlink(missing_ok=True)
    return {
        "url": url,
        "retrieved_at": datetime.now(timezone.utc).isoformat(),
        "size": size,
        "sha256": digest.hexdigest(),
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


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description=__doc__)
    result.add_argument("--url", default=DEFAULT_URL)
    result.add_argument("--output", type=Path, default=Path("upstream/amc_sources.rar"))
    result.add_argument("--extract-to", type=Path)
    result.add_argument("--metadata", type=Path, default=Path("upstream/archive.json"))
    result.add_argument("--inventory", type=Path, default=Path("upstream/inventory.json"))
    return result


def main(argv: list[str] | None = None) -> int:
    args = parser().parse_args(argv)
    metadata = download(args.url, args.output)
    if args.extract_to:
        metadata["extractor"] = extract(args.output, args.extract_to)
        files = inventory(args.extract_to)
        args.inventory.parent.mkdir(parents=True, exist_ok=True)
        args.inventory.write_text(json.dumps(files, indent=2) + "\n", encoding="utf-8")
        metadata["files"] = len(files)
    args.metadata.parent.mkdir(parents=True, exist_ok=True)
    args.metadata.write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8")
    print(f"Downloaded {metadata['size']} bytes; SHA-256 {metadata['sha256']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
