#!/usr/bin/env python3
"""Run the repository's canonical, dependency-light local checks."""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def run(command: list[str], *, environment: dict[str, str] | None = None) -> None:
    """Run one check from the repository root and fail immediately on error."""
    print(f"+ {' '.join(command)}", flush=True)
    subprocess.run(command, cwd=ROOT, env=environment, check=True)


def _pytest_command() -> list[str]:
    """Wrap the test run under a virtual X server when one is available.

    `tests/test_gui_display.py` builds real Tk widget trees and skips itself
    wherever no working display exists, so this is purely additive: it lets
    the one documented canonical command also exercise real-display GUI
    coverage on a Linux machine with Xvfb installed (this repository's own
    development container included), without requiring a display anywhere
    else — Windows and displayless Linux both fall back to the plain command,
    where that file's tests skip themselves instead of failing.
    """
    command = [sys.executable, "-m", "coverage", "run", "-m", "pytest", "-q"]
    if sys.platform.startswith("linux") and "DISPLAY" not in os.environ and shutil.which(
        "xvfb-run"
    ):
        return ["xvfb-run", "-a", *command]
    return command


def main() -> int:
    """Run tests, bytecode compilation, CLI smoke checking, and diff validation."""
    run([sys.executable, "-m", "ruff", "check", "src", "tests", "tools"])
    run(_pytest_command())
    run([sys.executable, "-m", "coverage", "report"])
    run([sys.executable, "-m", "compileall", "-q", "src", "tests", "tools"])
    run([sys.executable, "tools/validate_fixtures.py"])
    run([sys.executable, "tools/check_license_inventory.py"])
    environment = os.environ.copy()
    source = str(ROOT / "src")
    environment["PYTHONPATH"] = os.pathsep.join(
        item for item in (source, environment.get("PYTHONPATH", "")) if item
    )
    run([sys.executable, "tools/verify_fixtures.py"], environment=environment)
    run(
        [sys.executable, "-m", "amc.cli", "--help"],
        environment=environment,
    )
    run(["git", "diff", "--check"])
    run(["git", "diff", "--cached", "--check"])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
