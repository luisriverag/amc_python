#!/usr/bin/env python3
"""Build and smoke-test an installed AMC Python wheel in an isolated environment."""

from __future__ import annotations

import os
import subprocess
import sys
import tarfile
import tempfile
import venv
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FORBIDDEN_SDIST_PARTS = {
    ("src", "original"),
    ("src", "original_compressed"),
    ("src", "antcomponents"),
    ("src", "components_compressed"),
}


def run(command: list[str], *, environment: dict[str, str] | None = None) -> None:
    """Run one packaging check from the repository root."""
    print(f"+ {' '.join(command)}", flush=True)
    subprocess.run(command, cwd=ROOT, env=environment, check=True)


def run_with_output(
    command: list[str], expected: str, *, environment: dict[str, str] | None = None
) -> None:
    """Run an installed command and require its exact standard output."""
    print(f"+ {' '.join(command)}", flush=True)
    result = subprocess.run(
        command,
        cwd=ROOT,
        env=environment,
        check=True,
        capture_output=True,
        text=True,
    )
    if result.stdout != expected:
        raise RuntimeError(f"unexpected output from {' '.join(command)}: {result.stdout!r}")


def environment_python(environment: Path) -> Path:
    """Return the interpreter path for a virtual environment on this platform."""
    directory = "Scripts" if os.name == "nt" else "bin"
    executable = "python.exe" if os.name == "nt" else "python"
    return environment / directory / executable


def environment_script(environment: Path, name: str) -> Path:
    """Return an installed console-script path for the current platform."""
    directory = "Scripts" if os.name == "nt" else "bin"
    executable = f"{name}.exe" if os.name == "nt" else name
    return environment / directory / executable


def validate_sdist(path: Path) -> None:
    """Reject source distributions containing retained historical evidence trees."""
    with tarfile.open(path, "r:gz") as archive:
        members = archive.getmembers()
    if not members:
        raise RuntimeError("source distribution is empty")
    roots = {Path(member.name).parts[0] for member in members if member.name}
    if len(roots) != 1:
        raise RuntimeError("source distribution must have one top-level directory")
    root = next(iter(roots))
    relative_names = []
    for member in members:
        parts = Path(member.name).parts
        if not parts or parts[0] != root or ".." in parts or Path(member.name).is_absolute():
            raise RuntimeError(f"unsafe source-distribution member: {member.name}")
        relative = parts[1:]
        relative_names.append(relative)
        if any(relative[: len(prefix)] == prefix for prefix in FORBIDDEN_SDIST_PARTS):
            raise RuntimeError(f"source distribution contains historical evidence: {member.name}")
    required = {("LICENSE",), ("README.md",), ("pyproject.toml",), ("src", "amc")}
    missing = sorted(
        "/".join(prefix)
        for prefix in required
        if not any(name[: len(prefix)] == prefix for name in relative_names)
    )
    if missing:
        raise RuntimeError(f"source distribution is missing: {', '.join(missing)}")


def main() -> int:
    """Build a wheel, install it without dependencies, and run its CLI entry point."""
    with tempfile.TemporaryDirectory(prefix="amc-package-check-") as temporary:
        workspace = Path(temporary)
        wheelhouse = workspace / "wheelhouse"
        dist = workspace / "dist"
        environment = workspace / "venv"
        wheelhouse.mkdir()
        run([sys.executable, "-m", "build", "--sdist", "--outdir", str(dist), "."])
        sdists = list(dist.glob("amc_python-*.tar.gz"))
        if len(sdists) != 1:
            raise RuntimeError(f"expected one AMC Python source distribution, found {len(sdists)}")
        validate_sdist(sdists[0])
        run(
            [
                sys.executable,
                "-m",
                "pip",
                "wheel",
                ".",
                "--no-deps",
                "--wheel-dir",
                str(wheelhouse),
            ]
        )
        wheels = list(wheelhouse.glob("amc_python-*.whl"))
        if len(wheels) != 1:
            raise RuntimeError(f"expected one AMC Python wheel, found {len(wheels)}")
        venv.EnvBuilder(with_pip=True).create(environment)
        python = environment_python(environment)
        run([str(python), "-m", "pip", "install", str(wheels[0])])
        clean_environment = os.environ.copy()
        clean_environment.pop("PYTHONPATH", None)
        run([str(python), "-m", "amc.cli", "--help"], environment=clean_environment)
        run(
            [str(environment_script(environment, "amc")), "--help"],
            environment=clean_environment,
        )
        run(
            [str(python), "-c", "import tkinter; import amc.gui"],
            environment=clean_environment,
        )
        run(
            [
                str(python),
                "-c",
                "from importlib.metadata import entry_points; "
                "assert any(e.name == 'amc-gui' for e in entry_points(group='console_scripts'))",
            ],
            environment=clean_environment,
        )
        run(
            [str(environment_script(environment, "amc-gui")), "--help"],
            environment=clean_environment,
        )
        run(
            [str(environment_script(environment, "amc-web")), "--help"],
            environment=clean_environment,
        )
        run_with_output(
            [
                str(environment_script(environment, "amc")),
                "--catalog",
                str(workspace / "missing.json"),
                "list",
                "--json",
            ],
            "[]\n",
            environment=clean_environment,
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
