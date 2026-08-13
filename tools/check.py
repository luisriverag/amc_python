#!/usr/bin/env python3
"""Run the repository's canonical, dependency-light local checks."""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def run(command: list[str], *, environment: dict[str, str] | None = None) -> None:
    """Run one check from the repository root and fail immediately on error."""
    print(f"+ {' '.join(command)}", flush=True)
    subprocess.run(command, cwd=ROOT, env=environment, check=True)


def main() -> int:
    """Run tests, bytecode compilation, CLI smoke checking, and diff validation."""
    run([sys.executable, "-m", "pytest", "-q"])
    run([sys.executable, "-m", "compileall", "-q", "src", "tests", "tools"])
    run([sys.executable, "tools/validate_fixtures.py"])
    environment = os.environ.copy()
    source = str(ROOT / "src")
    environment["PYTHONPATH"] = os.pathsep.join(
        item for item in (source, environment.get("PYTHONPATH", "")) if item
    )
    run(
        [sys.executable, "-m", "amc.cli", "--help"],
        environment=environment,
    )
    run(["git", "diff", "--check"])
    run(["git", "diff", "--cached", "--check"])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
